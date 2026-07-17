/// A join request, stored at `vaults/{vaultId}/joinRequests/{uid}`.
///
/// The document ID is deliberately the requester's own Firebase Auth
/// UID (Phase 11 design item 35) — the simplest deterministic identity
/// available. This has two free side effects: a user can never have two
/// simultaneous pending requests for the same vault (a second attempt
/// targets the same document), and re-requesting after rejection is just
/// another write to the same path (item 43).
class VaultJoinRequest {
  const VaultJoinRequest({
    required this.uid,
    required this.displayName,
    required this.status,
    required this.requestedAt,
    required this.resolvedAt,
  });

  factory VaultJoinRequest.fromMap(Map<String, Object?> map) {
    return VaultJoinRequest(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      status: map['status'] as String,
      requestedAt: map['requestedAt'] as String,
      resolvedAt: map['resolvedAt'] as String?,
    );
  }

  final String uid;
  final String displayName;

  /// One of [JoinRequestStatus.pending], [JoinRequestStatus.accepted],
  /// [JoinRequestStatus.rejected].
  final String status;
  final String requestedAt;
  final String? resolvedAt;

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'status': status,
      'requestedAt': requestedAt,
      'resolvedAt': resolvedAt,
    };
  }
}

/// String constants for [VaultJoinRequest.status].
abstract class JoinRequestStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
}
