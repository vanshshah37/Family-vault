import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/security_preferences_store.dart';

/// Phase 13 — lets the user confirm they still remember their PIN
/// without ever revealing the stored PIN itself (which isn't even
/// possible to reveal — only a salted hash is ever stored, per
/// [SecurityPreferencesStore]). Reached from Security Settings'
/// "Verify PIN" row.
///
/// Deliberately reuses [SecurityPreferencesStore.verifyPin] — the exact
/// same check [LockScreen] performs — so "verify" and "actually unlock"
/// can never disagree about what counts as the correct PIN.
class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({super.key});

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

enum _VerifyResult { none, correct, incorrect }

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final _pinController = TextEditingController();
  bool _isChecking = false;
  _VerifyResult _result = _VerifyResult.none;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 8) return;

    setState(() {
      _isChecking = true;
      _result = _VerifyResult.none;
    });

    try {
      final isValid = await SecurityPreferencesStore.verifyPin(pin);
      if (!mounted) return;
      setState(() {
        _result = isValid ? _VerifyResult.correct : _VerifyResult.incorrect;
      });
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your PIN to confirm it — this never shows the '
                'stored PIN, only whether what you type matches it.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: '', labelText: 'PIN'),
                onChanged: (_) {
                  if (_result != _VerifyResult.none) {
                    setState(() => _result = _VerifyResult.none);
                  }
                },
                onSubmitted: (_) => _handleVerify(),
              ),
              const SizedBox(height: 16),
              if (_result == _VerifyResult.correct)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Correct PIN',
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                  ],
                ),
              if (_result == _VerifyResult.incorrect)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Text('Incorrect PIN', style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _handleVerify,
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
