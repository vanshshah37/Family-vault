import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Phase 13 — salted PIN hashing. Never stores a plaintext PIN
/// anywhere (per the spec's explicit requirement); `SecurityPreferencesStore`
/// only ever persists the salt and the resulting hash, both produced here.
///
/// Uses `package:crypto` (dart-lang official, actively maintained) —
/// the minimal, standard choice for this: there's no hash function
/// anywhere in Dart's core SDK, so unlike `flutter_secure_storage`
/// (declined in Phase 11 as unproven-necessary and again here per the
/// approved decision to use `shared_preferences` + `crypto` only),
/// this dependency is genuinely required by the spec's own "do not
/// store plaintext PINs" requirement.
abstract class PinHasher {
  /// A random salt, generated once per device (persisted alongside the
  /// hash) via the same `Random.secure()` generator already used for
  /// Vault ID generation in Phase 11.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String salt, String expectedHash) {
    return hash(pin, salt) == expectedHash;
  }
}
