import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../vault/vault_gate_screen.dart';
import 'sign_in_screen.dart';

/// The new `home:` of [FamilyVaultApp] (Phase 11 design item 15).
///
/// Listens to `FirebaseAuth.instance.authStateChanges()` to decide, on
/// launch, whether to show [SignInScreen] or [VaultGateScreen]. Deeper
/// navigation (into a vault's Dashboard, vault selection, etc.)
/// deliberately replaces this screen's route entirely via
/// `pushReplacement`/`pushAndRemoveUntil` rather than relying on this
/// StreamBuilder to keep reacting once inside the app — sign-out is
/// always an explicit user action (from [VaultSettingsScreen]) that
/// explicitly navigates back to a fresh [SignInScreen], consistent with
/// this project's exclusive `Navigator.push`/`pop` navigation pattern
/// (no named routes, no ambient global auth listener driving navigation
/// deep in the stack).
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        return VaultGateScreen(
          uid: user.uid,
          displayName: user.displayName ?? 'Family Member',
        );
      },
    );
  }
}
