/// Minimal profile mirror of a Firebase Auth user, stored at
/// `users/{uid}`.
///
/// Exists purely so vault member lists can display a name/photo without
/// a second round-trip to Firebase Auth's admin API (which the client
/// can't call). Not a settings/preferences store — Phase 11 needs
/// nothing beyond identity display fields.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
  });

  /// Builds a [UserProfile] from the currently signed-in Firebase user,
  /// stamping [createdAt] as now. Used the first time a user is seen.
  factory UserProfile.fromFirebaseUser({
    required String uid,
    required String? displayName,
    required String? email,
    required String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? 'Family Member',
      email: email ?? '',
      photoUrl: photoUrl,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  factory UserProfile.fromMap(Map<String, Object?> map) {
    return UserProfile(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String createdAt;

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}
