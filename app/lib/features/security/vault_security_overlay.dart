import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/vault_lock_controller.dart';
import '../../widgets/activity_detector.dart';
import 'lock_screen.dart';
import 'pin_setup_screen.dart';

/// The single insertion point for Phase 13's vault lock — wired in
/// once via `MaterialApp.builder` in `main.dart`, wrapping the ENTIRE
/// app (every route, every screen). This means a lock/setup screen can
/// be drawn on top regardless of how deep the current navigation stack
/// is, without a `navigatorKey` or popping any routes, and — just as
/// importantly — **no other screen in the app needs to know locking
/// exists**: `AuthGateScreen`, `VaultGateScreen`, `HomeScreen`,
/// `EntryListScreen`, and everything else are completely untouched.
///
/// Deliberately keeps [child] (the whole app's `Navigator`, including
/// `AuthGateScreen` and everything beneath it) permanently mounted via
/// a [Stack] rather than conditionally swapping it out — this
/// preserves the user's navigation position (e.g. still on
/// `EntryDetailsScreen`) across a lock/unlock cycle, instead of
/// resetting to the Dashboard root every time the vault re-locks.
///
/// Independent from Firebase Authentication (per the approved
/// constraint): only ever shows a lock/setup screen when
/// `FirebaseAuth.instance.currentUser` is non-null — the vault lock
/// never covers `SignInScreen`. This widget also listens to
/// `authStateChanges()` itself (separately from `AuthGateScreen`'s own
/// subscription) purely to (a) know when to stop protecting once
/// signed out, and (b) call `VaultLockController.instance.lock()`
/// whenever a sign-out is observed, regardless of whether it came from
/// the explicit Sign Out button or any other path — so a stale
/// "unlocked" flag can never survive into a later sign-in within the
/// same app process (see the Phase 13 analysis §4/§8 for why this
/// second safety net matters, alongside the one already added to
/// `VaultSettingsScreen._signOut()`).
class VaultSecurityOverlay extends StatefulWidget {
  const VaultSecurityOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<VaultSecurityOverlay> createState() => _VaultSecurityOverlayState();
}

class _VaultSecurityOverlayState extends State<VaultSecurityOverlay> {
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        VaultLockController.instance.lock();
      }
      if (mounted) {
        setState(() => _currentUser = user);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ActivityDetector(child: widget.child),
        ValueListenableBuilder<VaultLockState>(
          valueListenable: VaultLockController.instance.state,
          builder: (context, lockState, _) {
            final shouldProtect =
                _currentUser != null && lockState != VaultLockState.unlocked;
            if (!shouldProtect) return const SizedBox.shrink();

            return Positioned.fill(
              child: lockState == VaultLockState.needsSetup
                  ? const PinSetupScreen(mode: PinSetupMode.firstTime)
                  : const LockScreen(),
            );
          },
        ),
      ],
    );
  }
}
