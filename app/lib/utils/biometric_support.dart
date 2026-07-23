import 'package:local_auth/local_auth.dart';

/// Phase 13 — the one place that answers "can this device actually use
/// biometrics right now" (hardware present, platform supported, AND at
/// least one biometric actually enrolled) — shared by [PinSetupScreen],
/// [LockScreen], and [SecuritySettingsScreen] so they never drift out
/// of sync on what "available" means. Every check is wrapped in a
/// broad catch — any failure here (any platform/version quirk) simply
/// means "treat biometrics as unavailable and fall back to the PIN
/// screen," never a crash.
///
/// Bug fix: each `local_auth` call is a native platform-channel round
/// trip, and a broken/misbehaving native side (e.g. the Windows
/// `local_auth_windows` native build issue already on file for this
/// project) can leave a call permanently pending rather than throwing —
/// a plain `try/catch` does nothing for a Future that never completes.
/// A hard [_callTimeout] on the whole sequence guarantees this always
/// resolves quickly either way, which is what actually fixed "Security
/// Settings loads very slowly" (its `_load()` awaits this first) and
/// contributed to the PIN-unlock hang (`LockScreen` also calls this on
/// every open, via `_tryBiometricUnlock`).
abstract class BiometricSupport {
  static const Duration _callTimeout = Duration(seconds: 3);

  static Future<bool> isAvailable() async {
    try {
      return await _checkAvailability().timeout(
        _callTimeout,
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _checkAvailability() async {
    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) return false;

    final enrolled = await localAuth.getAvailableBiometrics();
    return enrolled.isNotEmpty;
  }
}
