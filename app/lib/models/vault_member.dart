/// A single vault membership, stored at
/// `vaults/{vaultId}/members/{uid}`.
///
/// This subcollection is the single authoritative source of truth for
/// membership (Phase 11 design item 26) — no duplicate membership list
/// is kept anywhere else. [displayName] is a denormalized copy purely so
/// the member list UI can render without a second lookup per row.
class VaultMember {
  const VaultMember({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  factory VaultMember.fromMap(Map<String, Object?> map) {
    return VaultMember(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      role: map['role'] as String,
      joinedAt: map['joinedAt'] as String,
    );
  }

  final String uid;
  final String displayName;

  /// Either `owner` or `member`. Exactly one `owner` exists per vault —
  /// its creator (Phase 11 does not implement ownership transfer).
  final String role;
  final String joinedAt;

  bool get isOwner => role == VaultRole.owner;

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'role': role,
      'joinedAt': joinedAt,
    };
  }
}

/// String constants for [VaultMember.role] — avoids typo'd magic strings
/// scattered across the vault feature.
abstract class VaultRole {
  static const String owner = 'owner';
  static const String member = 'member';
}
