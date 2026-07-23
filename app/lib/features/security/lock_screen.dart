import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../services/auth_service.dart';
import '../../services/security_preferences_store.dart';
import '../../services/vault_lock_controller.dart';
import '../../utils/biometric_support.dart';

/// Shown whenever `VaultLockController.state` is
/// [VaultLockState.locked] — security has already been configured (see
/// [PinSetupScreen] for first-time setup) but the vault isn't
/// currently unlocked.
///
/// Attempts biometric authentication automatically once, on open, if
/// enabled and available — and always falls back to (and keeps
/// showing) PIN entry regardless of whether that attempt succeeds,
/// fails, or biometrics aren't available at all, per the spec: "If
/// fingerprint fails or is unavailable, allow PIN entry."
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  final _localAuth = LocalAuthentication();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricUnlock());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricUnlock() async {
    final biometricsEnabled = await SecurityPreferencesStore.biometricsEnabled();
    if (!biometricsEnabled || !mounted) return;

    final available = await BiometricSupport.isAvailable();
    if (!available || !mounted) return;

    try {
      final didAuthenticate = await _localAuth
          .authenticate(
            localizedReason: 'Unlock Family Vault',
            options: const AuthenticationOptions(biometricOnly: true),
          )
          .timeout(const Duration(seconds: 30), onTimeout: () => false);
      if (didAuthenticate && mounted) {
        VaultLockController.instance.unlock();
      }
    } catch (_) {
      // Any failure (no enrolled biometrics, hardware error, lockout,
      // user cancel, platform quirk) — fall through to the PIN entry
      // already shown below. Never surfaced as an error to the user;
      // PIN entry is always the safety net.
    }
  }

  /// Bug fix: previously left `_isVerifying` stuck `true` forever on the
  /// success path — it relied entirely on this whole widget being
  /// unmounted the instant `unlock()` flips `VaultSecurityOverlay`'s
  /// state, with nothing resetting the flag if that didn't happen for
  /// any reason. Wrapping in try/finally guarantees the loading state
  /// always clears — whether the PIN was right or wrong, and regardless
  /// of exactly when (or whether) this screen gets removed from the
  /// tree — so the "Unlock" button can never be stuck showing a spinner
  /// forever.
  Future<void> _handlePinSubmit() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 8) {
      setState(() => _errorMessage = 'Enter your 4–8 digit PIN.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final isValid = await SecurityPreferencesStore.verifyPin(pin);
      if (!mounted) return;

      if (isValid) {
        VaultLockController.instance.unlock();
      } else {
        setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
        _pinController.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    // Per the approved decision, signing out of Firebase always clears
    // the unlocked session — handled by VaultSecurityOverlay's own
    // authStateChanges listener (which calls
    // VaultLockController.instance.lock()) the moment this completes,
    // and AuthGateScreen (untouched by Phase 13) reacts to the same
    // stream on its own to show SignInScreen. No navigation call is
    // needed here at all.
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text('Vault Locked', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'Enter PIN',
                  ),
                  onSubmitted: (_) => _handlePinSubmit(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _handlePinSubmit,
                    child: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Unlock'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _tryBiometricUnlock,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('Use Fingerprint'),
                ),
                TextButton(
                  onPressed: _handleSignOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
