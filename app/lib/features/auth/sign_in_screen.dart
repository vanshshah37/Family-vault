import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

/// Entry point of the authentication gate — shown whenever
/// `authStateChanges()` emits `null`.
///
/// Plain [StatefulWidget] + `setState`, matching [HomeScreen]'s existing
/// pattern (Phase 11 design item 56 — no new state-management framework
/// introduced).
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService();

  bool _isSigningIn = false;
  String? _errorMessage;

  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (credential == null) {
        // User cancelled — not an error, just return to idle.
        setState(() => _isSigningIn = false);
        return;
      }

      // On success, authStateChanges() fires and AuthGateScreen handles
      // navigation — nothing further to do here.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = "Couldn't sign in. Please try again.";
      });
    }
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
                Text(
                  'Family Vault',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your family\'s shared vault.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                if (_isSigningIn)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _handleSignIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Sign in with Google'),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
