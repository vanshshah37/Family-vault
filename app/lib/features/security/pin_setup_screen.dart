import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/security_preferences_store.dart';
import '../../services/vault_lock_controller.dart';
import '../../utils/biometric_support.dart';

/// Which of the two Phase 13 uses this screen is serving.
enum PinSetupMode { firstTime, change }

enum _Step { verifyCurrent, createPin, confirmPin }

/// PIN creation/confirmation, reused for two purposes distinguished
/// only by [mode] — mirroring this codebase's own established pattern
/// (`DynamicEntryScreen`'s single renderer for both Create and Edit):
///
/// - [PinSetupMode.firstTime]: mandatory (no skip/cancel option, no
///   back button — per the approved decision), shown by
///   `VaultSecurityOverlay` whenever security has never been
///   configured. Starts directly at [_Step.createPin].
/// - [PinSetupMode.change]: reached from Security Settings; requires
///   verifying the existing PIN first ([_Step.verifyCurrent]) before
///   reusing the identical create/confirm steps. Cancellable (has the
///   default AppBar back arrow) since this is a voluntary settings
///   action, not a mandatory gate.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, required this.mode});

  final PinSetupMode mode;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  late _Step _step =
      widget.mode == PinSetupMode.change ? _Step.verifyCurrent : _Step.createPin;

  final _pinController = TextEditingController();
  String? _firstEnteredPin;
  String? _errorMessage;
  bool _isBusy = false;

  bool _biometricsAvailable = false;
  bool _enableBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricSupport.isAvailable();
    if (!mounted) return;
    setState(() => _biometricsAvailable = available);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final value = _pinController.text.trim();

    if (_step == _Step.verifyCurrent) {
      setState(() => _isBusy = true);
      final isValid = await SecurityPreferencesStore.verifyPin(value);
      if (!mounted) return;
      setState(() => _isBusy = false);

      if (!isValid) {
        setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
        _pinController.clear();
        return;
      }

      setState(() {
        _step = _Step.createPin;
        _errorMessage = null;
        _pinController.clear();
      });
      return;
    }

    if (value.length < 4 || value.length > 8) {
      setState(() => _errorMessage = 'PIN must be 4–8 digits.');
      return;
    }

    if (_step == _Step.createPin) {
      setState(() {
        _firstEnteredPin = value;
        _step = _Step.confirmPin;
        _errorMessage = null;
        _pinController.clear();
      });
      return;
    }

    // _step == _Step.confirmPin
    if (value != _firstEnteredPin) {
      setState(() {
        _errorMessage = "PINs don't match. Please try again.";
        _step = _Step.createPin;
        _firstEnteredPin = null;
        _pinController.clear();
      });
      return;
    }

    setState(() => _isBusy = true);
    await SecurityPreferencesStore.savePin(value);
    // Change-PIN mode intentionally leaves the existing biometrics
    // preference untouched — only first-time setup's toggle writes it.
    if (widget.mode == PinSetupMode.firstTime) {
      await SecurityPreferencesStore.setBiometricsEnabled(_enableBiometrics);
    }

    if (!mounted) return;
    setState(() => _isBusy = false);

    if (widget.mode == PinSetupMode.firstTime) {
      VaultLockController.instance.completeSetup();
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed')),
      );
    }
  }

  String get _title {
    switch (_step) {
      case _Step.verifyCurrent:
        return 'Enter Current PIN';
      case _Step.createPin:
        return 'Create a PIN';
      case _Step.confirmPin:
        return 'Confirm PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMandatoryFirstTime = widget.mode == PinSetupMode.firstTime;

    return Scaffold(
      appBar: AppBar(
        // No back button for mandatory first-time setup — per the
        // approved decision, there is no "Set Up Later" option.
        automaticallyImplyLeading: !isMandatoryFirstTime,
        title: Text(_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMandatoryFirstTime && _step == _Step.createPin) ...[
                Text(
                  'Create a PIN to protect your vault.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: '', labelText: 'PIN'),
                onSubmitted: (_) => _handleContinue(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_step == _Step.createPin && _biometricsAvailable) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Fingerprint Unlock'),
                  value: _enableBiometrics,
                  onChanged: (value) => setState(() => _enableBiometrics = value),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _handleContinue,
                  child: _isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
