import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/home/home_screen.dart';
import '../../models/user_profile.dart';
import '../../repositories/vault_repository.dart';
import 'create_vault_screen.dart';
import 'join_vault_screen.dart';
import 'vault_selection_screen.dart';

/// Resolves how many vaults the signed-in user belongs to and routes
/// accordingly (Phase 11 design item 28):
///
/// - 0 memberships → shows exactly two choices: Create New Vault, Join
///   Existing Vault.
/// - 1 membership → opens that vault's Dashboard directly, no selection
///   screen shown.
/// - 2+ memberships → always shows [VaultSelectionScreen] — every
///   launch, per the final design's explicit removal of any
///   "remember last vault" feature.
///
/// This screen re-runs its membership query every time it is reached
/// (e.g. returning here after sign-out and signing back in), so a
/// newly-accepted join request is picked up the next time the app is
/// opened, with no listener/polling needed in Phase 11.
class VaultGateScreen extends StatefulWidget {
  const VaultGateScreen({super.key, required this.uid, required this.displayName});

  final String uid;
  final String displayName;

  @override
  State<VaultGateScreen> createState() => _VaultGateScreenState();
}

class _VaultGateScreenState extends State<VaultGateScreen> {
  final VaultRepository _vaultRepository = VaultRepository();

  bool _isLoading = true;
  String? _errorMessage;
  List<VaultMembership> _memberships = const [];

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _saveUserProfile();
      final memberships = await _vaultRepository.loadMemberships(widget.uid);
      if (!mounted) return;

      if (memberships.length == 1) {
        // Exactly one vault — open its Dashboard directly, no
        // VaultSelectionScreen shown, per Phase 11 design item 28.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(vaultId: memberships.first.vault.vaultId),
          ),
        );
        return;
      }

      if (memberships.length >= 2) {
        // Always shown for 2+ memberships, every launch — no
        // "last selected vault" persistence (final design item 6).
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VaultSelectionScreen(memberships: memberships),
          ),
        );
        return;
      }

      // 0 memberships — stay on this screen and show the two choices.
      setState(() {
        _memberships = memberships;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Couldn't load your vaults. Please try again.";
      });
    }
  }

  /// Writes/refreshes this user's `users/{uid}` profile document — safe
  /// to call on every gate load since [VaultRepository.saveUserProfile]
  /// merges rather than overwrites.
  Future<void> _saveUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _vaultRepository.saveUserProfile(
      UserProfile.fromFirebaseUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      ),
    );
  }

  Future<void> _openCreateVault() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateVaultScreen(
          ownerUid: widget.uid,
          ownerDisplayName: widget.displayName,
        ),
      ),
    );
    // If the user backed out without creating a vault, re-check —
    // membership state may be unchanged, which is fine.
    if (mounted) _loadMemberships();
  }

  Future<void> _openJoinVault() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const JoinVaultScreen()),
    );
    if (mounted) _loadMemberships();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to Family Vault',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You're not part of a vault yet.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openCreateVault,
                          child: const Text('Create New Vault'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _openJoinVault,
                          child: const Text('Join Existing Vault'),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
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
