import 'package:shared_preferences/shared_preferences.dart';

import '../utils/auto_lock_duration.dart';
import '../utils/pin_hasher.dart';

/// Phase 13 — the sole place that reads/writes vault-security
/// preferences, mirroring Phase 12's `SortPreferenceStore` pattern.
/// Everything lives in `shared_preferences` (already a project
/// dependency since Phase 12) — no new local-storage mechanism, and
/// per the approved decision, no `flutter_secure_storage` and no
/// database encryption in this phase.
///
/// Only ever stores: the PIN's salt and salted hash (never the
/// plaintext PIN itself), whether biometrics are enabled, and the
/// selected Auto-Lock Timer. `isSecurityConfigured()`'s answer (does a
/// PIN hash exist at all) is also, implicitly, the "has first-time
/// setup ever completed" signal `VaultLockController` reads on launch.
abstract class SecurityPreferencesStore {
  static const String _pinHashKey = 'security_pin_hash';
  static const String _pinSaltKey = 'security_pin_salt';
  static const String _biometricsEnabledKey = 'security_biometrics_enabled';
  static const String _autoLockDurationKey = 'security_auto_lock_duration';

  static Future<bool> isSecurityConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinHashKey);
  }

  /// Generates a fresh salt and stores the salted hash of [pin] —
  /// used for both first-time setup and "Change PIN" (both simply
  /// overwrite the previous salt+hash pair).
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash(pin, salt);
    await prefs.setString(_pinSaltKey, salt);
    await prefs.setString(_pinHashKey, hash);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_pinSaltKey);
    final hash = prefs.getString(_pinHashKey);
    if (salt == null || hash == null) return false;
    return PinHasher.verify(pin, salt, hash);
  }

  static Future<bool> biometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricsEnabledKey) ?? false;
  }

  static Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsEnabledKey, enabled);
  }

  static Future<AutoLockDuration> loadAutoLockDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return AutoLockDuration.fromStorageKey(prefs.getString(_autoLockDurationKey));
  }

  static Future<void> saveAutoLockDuration(AutoLockDuration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_autoLockDurationKey, duration.storageKey);
  }
}
