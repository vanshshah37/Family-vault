import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_vault.dart';
import '../models/user_profile.dart';
import '../models/vault_join_request.dart';
import '../models/vault_member.dart';
import '../utils/vault_id_generator.dart';

/// Thrown internally when a generated Vault ID candidate already exists.
/// Never escapes [VaultRepository.createVault] — it's caught there and
/// triggers a retry with a fresh candidate.
class _VaultIdCollisionException implements Exception {}

/// Thrown when [VaultRepository.createVault] could not find a free
/// Vault ID within the retry budget. Effectively never expected to occur
/// in practice given the ~40 bits of entropy per candidate.
class VaultIdExhaustedException implements Exception {
  const VaultIdExhaustedException(this.attempts);
  final int attempts;

  @override
  String toString() =>
      'Could not generate a unique Vault ID after $attempts attempts.';
}

/// Bundles a [FamilyVault] with the current user's own [VaultMember]
/// document for that vault. This is a query-result shape only — it is
/// not a stored schema entity, so it lives here rather than in
/// `lib/models/`.
class VaultMembership {
  const VaultMembership({required this.vault, required this.member});
  final FamilyVault vault;
  final VaultMember member;
}

/// The only allowed boundary between UI and the Phase 11 cloud data
/// plane (`users` / `vaults` / `vaults/{id}/members` /
/// `vaults/{id}/joinRequests`).
///
/// Mirrors [EntryRepository]'s existing role exactly: no screen imports
/// `cloud_firestore` directly — only this class does. This repository
/// has nothing to do with the local SQLite `entries` table; that
/// boundary ([EntryRepository] / [DatabaseService]) is untouched by
/// Phase 11.
class VaultRepository {
  VaultRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _maxVaultIdAttempts = 5;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _vaults =>
      _firestore.collection('vaults');

  // ---------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------

  /// Writes (or overwrites) the signed-in user's profile document. Safe
  /// to call on every sign-in — `set` with merge keeps `createdAt` from
  /// being clobbered on repeat sign-ins.
  Future<void> saveUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------
  // Membership discovery (Phase 11 design item 27)
  // ---------------------------------------------------------------------

  /// Finds every vault the given [uid] belongs to via a
  /// `collectionGroup('members')` query filtered by the `uid` field
  /// stored on each membership document — not by document ID, since the
  /// membership document ID is the member's own `uid` only within a
  /// single vault's subcollection, and collection-group queries span
  /// every vault's `members` subcollection at once.
  ///
  /// Requires the collection-group index on `members.uid` and a
  /// `rules_version = '2'` Security Rule matching
  /// `{path=**}/members/{memberId}` (see firestore.rules).
  Future<List<VaultMembership>> loadMemberships(String uid) async {
    final memberDocs = await _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .get();

    final memberships = <VaultMembership>[];
    for (final memberDoc in memberDocs.docs) {
      final vaultRef = memberDoc.reference.parent.parent;
      if (vaultRef == null) continue;
      final vaultSnap = await vaultRef.get();
      if (!vaultSnap.exists) continue;
      memberships.add(
        VaultMembership(
          vault: FamilyVault.fromMap(vaultSnap.data()!),
          member: VaultMember.fromMap(memberDoc.data()),
        ),
      );
    }
    return memberships;
  }

  // ---------------------------------------------------------------------
  // Vault creation (Phase 11 design items 20, 21, 30, 31 — revised item 2)
  // ---------------------------------------------------------------------

  /// Creates a new [FamilyVault] and its owner [VaultMember] document
  /// atomically, generating a collision-safe Vault ID.
  ///
  /// Collision-safety (final-design requirement 2): the candidate ID's
  /// existence check and both writes (vault document + owner membership
  /// document) happen inside a single `runTransaction`. Firestore
  /// transactions are atomic and use optimistic concurrency: if two
  /// clients race to create a vault with the same candidate ID, only one
  /// transaction can ever commit — the other either sees
  /// `snapshot.exists == true` at read time and aborts before writing
  /// anything, or (in the rarer case where both reads happen before
  /// either write) has its commit rejected by Firestore because the
  /// document changed since the transaction's read, and is retried by
  /// the SDK. Either way, two users can never both succeed in writing
  /// the same Vault ID — there is no window where an existence check and
  /// its corresponding write are two separate, non-atomic operations.
  ///
  /// If a candidate collides, a fresh candidate is generated and the
  /// whole transaction is retried, up to [_maxVaultIdAttempts] times.
  Future<FamilyVault> createVault({
    required String name,
    required String ownerUid,
    required String ownerDisplayName,
  }) async {
    for (var attempt = 1; attempt <= _maxVaultIdAttempts; attempt++) {
      final candidateId = VaultIdGenerator.generate();
      final vaultRef = _vaults.doc(candidateId);

      try {
        return await _firestore.runTransaction<FamilyVault>((transaction) async {
          final existing = await transaction.get(vaultRef);
          if (existing.exists) {
            // Collision — abort this transaction without writing
            // anything, so the retry loop below can try a fresh ID.
            throw _VaultIdCollisionException();
          }

          final now = DateTime.now().toIso8601String();
          final vault = FamilyVault(
            vaultId: candidateId,
            name: name,
            ownerUid: ownerUid,
            createdAt: now,
          );
          final ownerMember = VaultMember(
            uid: ownerUid,
            displayName: ownerDisplayName,
            role: VaultRole.owner,
            joinedAt: now,
          );

          transaction.set(vaultRef, vault.toMap());
          transaction.set(
            vaultRef.collection('members').doc(ownerUid),
            ownerMember.toMap(),
          );

          return vault;
        });
      } on _VaultIdCollisionException {
        continue; // Try again with a freshly generated candidate ID.
      }
    }

    throw const VaultIdExhaustedException(_maxVaultIdAttempts);
  }

  // ---------------------------------------------------------------------
  // Vault lookup + join requests (Phase 11 design items 32-38)
  // ---------------------------------------------------------------------

  /// Confirms a vault exists and returns it. Any authenticated user may
  /// read the top-level vault document (Security Rules), which carries
  /// only non-sensitive fields (name/owner/createdAt) — never member or
  /// request data — so this alone cannot leak private vault details.
  Future<FamilyVault?> findVaultById(String vaultId) async {
    final snap = await _vaults.doc(vaultId).get();
    if (!snap.exists) return null;
    return FamilyVault.fromMap(snap.data()!);
  }

  Future<VaultMember?> findMembership({
    required String vaultId,
    required String uid,
  }) async {
    final snap = await _vaults.doc(vaultId).collection('members').doc(uid).get();
    if (!snap.exists) return null;
    return VaultMember.fromMap(snap.data()!);
  }

  Future<VaultJoinRequest?> findOwnJoinRequest({
    required String vaultId,
    required String uid,
  }) async {
    final snap =
        await _vaults.doc(vaultId).collection('joinRequests').doc(uid).get();
    if (!snap.exists) return null;
    return VaultJoinRequest.fromMap(snap.data()!);
  }

  /// Submits (or re-submits after rejection) a join request. Callers are
  /// expected to have already checked [findMembership] and
  /// [findOwnJoinRequest] so the UI can short-circuit with the right
  /// message (item 36/37); Security Rules enforce the same constraints
  /// server-side regardless.
  Future<void> submitJoinRequest({
    required String vaultId,
    required String uid,
    required String displayName,
  }) async {
    final request = VaultJoinRequest(
      uid: uid,
      displayName: displayName,
      status: JoinRequestStatus.pending,
      requestedAt: DateTime.now().toIso8601String(),
      resolvedAt: null,
    );
    await _vaults
        .doc(vaultId)
        .collection('joinRequests')
        .doc(uid)
        .set(request.toMap());
  }

  // ---------------------------------------------------------------------
  // Owner: pending requests + accept/reject (items 39-43)
  // ---------------------------------------------------------------------

  Future<List<VaultJoinRequest>> loadPendingJoinRequests(String vaultId) async {
    final snap = await _vaults
        .doc(vaultId)
        .collection('joinRequests')
        .where('status', isEqualTo: JoinRequestStatus.pending)
        .get();
    return snap.docs.map((d) => VaultJoinRequest.fromMap(d.data())).toList();
  }

  /// Atomically creates the new member document and marks the request
  /// accepted (Phase 11 design item 41) — a transaction so the two
  /// writes can never partially apply.
  Future<void> acceptJoinRequest({
    required String vaultId,
    required String requestUid,
    required String requestDisplayName,
  }) async {
    final vaultRef = _vaults.doc(vaultId);
    final memberRef = vaultRef.collection('members').doc(requestUid);
    final requestRef = vaultRef.collection('joinRequests').doc(requestUid);

    await _firestore.runTransaction((transaction) async {
      final now = DateTime.now().toIso8601String();
      final newMember = VaultMember(
        uid: requestUid,
        displayName: requestDisplayName,
        role: VaultRole.member,
        joinedAt: now,
      );
      transaction.set(memberRef, newMember.toMap());
      transaction.update(requestRef, {
        'status': JoinRequestStatus.accepted,
        'resolvedAt': now,
      });
    });
  }

  Future<void> rejectJoinRequest({
    required String vaultId,
    required String requestUid,
  }) async {
    await _vaults
        .doc(vaultId)
        .collection('joinRequests')
        .doc(requestUid)
        .update({
      'status': JoinRequestStatus.rejected,
      'resolvedAt': DateTime.now().toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------
  // Members (items 44-47)
  // ---------------------------------------------------------------------

  Future<List<VaultMember>> loadMembers(String vaultId) async {
    final snap = await _vaults.doc(vaultId).collection('members').get();
    return snap.docs.map((d) => VaultMember.fromMap(d.data())).toList();
  }

  /// Owner-only. A single-document delete is already atomic — no
  /// transaction is needed. This alone revokes future cloud access,
  /// since every Security Rule gates on this membership document's
  /// existence.
  Future<void> removeMember({
    required String vaultId,
    required String memberUid,
  }) async {
    await _vaults.doc(vaultId).collection('members').doc(memberUid).delete();
  }
}
