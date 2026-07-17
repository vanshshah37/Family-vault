/// A single shared Family Vault, stored at `vaults/{vaultId}`.
///
/// [vaultId] is the human-readable public ID (e.g. `FV-7K9X-2M4P`) and is
/// also the Firestore document ID — the simplest correct choice per the
/// Phase 11 design (no separate internal ID to keep in sync). This
/// top-level document intentionally carries only non-sensitive fields:
/// no member list, no pending-request data — those live in subcollections
/// with their own, stricter Security Rules.
class FamilyVault {
  const FamilyVault({
    required this.vaultId,
    required this.name,
    required this.ownerUid,
    required this.createdAt,
  });

  factory FamilyVault.fromMap(Map<String, Object?> map) {
    return FamilyVault(
      vaultId: map['vaultId'] as String,
      name: map['name'] as String,
      ownerUid: map['ownerUid'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  final String vaultId;
  final String name;
  final String ownerUid;
  final String createdAt;

  Map<String, Object?> toMap() {
    return {
      'vaultId': vaultId,
      'name': name,
      'ownerUid': ownerUid,
      'createdAt': createdAt,
    };
  }
}
