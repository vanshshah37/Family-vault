import 'package:flutter/material.dart';

import '../../features/home/home_screen.dart';
import '../../repositories/vault_repository.dart';

/// Shown whenever the signed-in user belongs to 2+ vaults — every app
/// launch, with no "last selected vault" persistence (final design item
/// 6, deliberately kept out of Phase 11 scope).
class VaultSelectionScreen extends StatelessWidget {
  const VaultSelectionScreen({super.key, required this.memberships});

  final List<VaultMembership> memberships;

  void _openVault(BuildContext context, VaultMembership membership) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(vaultId: membership.vault.vaultId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Vault')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: memberships.length,
          itemBuilder: (context, index) {
            final membership = memberships[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(membership.vault.name),
                subtitle: Text(
                  membership.member.isOwner ? 'Owner' : 'Member',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openVault(context, membership),
              ),
            );
          },
        ),
      ),
    );
  }
}
