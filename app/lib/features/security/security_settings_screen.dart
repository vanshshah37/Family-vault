import 'package:flutter/material.dart';

import '../../services/security_preferences_store.dart';
import '../../services/vault_lock_controller.dart';
import '../../utils/auto_lock_duration.dart';
import '../../utils/biometric_support.dart';
import 'pin_setup_screen.dart';
import 'verify_pin_screen.dart';

/// Security Settings — reached from Vault Settings' "Security" row.
/// Options per the Phase 13 spec: Change PIN, Enable/Disable
/// Biometrics, Auto-Lock Timer, Lock Now.
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLoading = true;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  AutoLockDuration _autoLockDuration = AutoLockDuration.threeMinutes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Run independently of one another — none of these three reads
    // depends on another's result, so there's no reason to serialize
    // them and make the slowest one (biometric hardware capability
    // checks, now individually timeout-guarded in [BiometricSupport])
    // hold up the other two.
    final results = await Future.wait([
      BiometricSupport.isAvailable(),
      SecurityPreferencesStore.biometricsEnabled(),
      SecurityPreferencesStore.loadAutoLockDuration(),
    ]);
    if (!mounted) return;
    setState(() {
      _biometricsAvailable = results[0] as bool;
      _biometricsEnabled = results[1] as bool;
      _autoLockDuration = results[2] as AutoLockDuration;
      _isLoading = false;
    });
  }

  Future<void> _handleBiometricsToggle(bool value) async {
    setState(() => _biometricsEnabled = value);
    await SecurityPreferencesStore.setBiometricsEnabled(value);
  }

  Future<void> _handleAutoLockChanged(AutoLockDuration? duration) async {
    if (duration == null) return;
    setState(() => _autoLockDuration = duration);
    await VaultLockController.instance.setAutoLockDuration(duration);
  }

  void _handleChangePin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PinSetupScreen(mode: PinSetupMode.change),
      ),
    );
  }

  void _handleVerifyPin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VerifyPinScreen()),
    );
  }

  void _handleLockNow() {
    // Immediate, no confirmation dialog — per the approved decision.
    // No navigation needed here: VaultSecurityOverlay draws the lock
    // screen on top of wherever the user currently is (this screen),
    // so returning after unlock lands right back here.
    VaultLockController.instance.lock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _handleChangePin,
                ),
                ListTile(
                  title: const Text('Verify PIN'),
                  subtitle: const Text('Check you still remember your PIN'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _handleVerifyPin,
                ),
                SwitchListTile(
                  title: const Text('Fingerprint Unlock'),
                  subtitle: _biometricsAvailable
                      ? null
                      : const Text('Not available on this device'),
                  value: _biometricsEnabled,
                  onChanged: _biometricsAvailable ? _handleBiometricsToggle : null,
                ),
                ListTile(
                  title: const Text('Auto-Lock Timer'),
                  trailing: DropdownButton<AutoLockDuration>(
                    value: _autoLockDuration,
                    onChanged: _handleAutoLockChanged,
                    items: [
                      for (final option in AutoLockDuration.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_rounded),
                  title: const Text('Lock Now'),
                  onTap: _handleLockNow,
                ),
              ],
            ),
    );
  }
}
