import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../features/auth/sign_in_screen.dart';
import '../../models/family_vault.dart';
import '../../models/vault_join_request.dart';
import '../../models/vault_member.dart';
import '../../repositories/vault_repository.dart';
import '../../services/auth_service.dart';

/// Single vault-management surface reached via the one approved
/// Dashboard AppBar action (final design item 4 — renamed from
/// "Members" to "Vault Settings"). Combines:
///
/// - Vault Name + Vault ID + Copy
/// - Members (owner sees Remove per row)
/// - Pending Join Requests (owner only, Accept/Reject)
/// - Sign Out
class VaultSettingsScreen extends StatefulWidget {
  const VaultSettingsScreen({super.key, required this.vaultId});

  final String vaultId;

  @override
  State<VaultSettingsScreen> createState() => _VaultSettingsScreenState();
}

class _VaultSettingsScreenState extends State<VaultSettingsScreen> {
  final VaultRepository _vaultRepository = VaultRepository();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  FamilyVault? _vault;
  bool _isOwner = false;
  List<VaultMember> _members = const [];
  List<VaultJoinRequest> _pendingRequests = const [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vault = await _vaultRepository.findVaultById(widget.vaultId);
      final members = await _vaultRepository.loadMembers(widget.vaultId);
      final ownMembership = members.where((m) => m.uid == uid).firstOrNull;
      final isOwner = ownMembership?.isOwner ?? false;

      final pendingRequests = isOwner
          ? await _vaultRepository.loadPendingJoinRequests(widget.vaultId)
          : const <VaultJoinRequest>[];

      if (!mounted) return;
      setState(() {
        _vault = vault;
        _members = members;
        _isOwner = isOwner;
        _pendingRequests = pendingRequests;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Couldn't load vault settings. Please try again.";
      });
    }
  }

  void _copyVaultId() {
    Clipboard.setData(ClipboardData(text: widget.vaultId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vault ID copied')),
    );
  }

  Future<void> _acceptRequest(VaultJoinRequest request) async {
    try {
      await _vaultRepository.acceptJoinRequest(
        vaultId: widget.vaultId,
        requestUid: request.uid,
        requestDisplayName: request.displayName,
      );
      if (mounted) _loadAll();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't accept the request.")),
      );
    }
  }

  Future<void> _rejectRequest(VaultJoinRequest request) async {
    try {
      await _vaultRepository.rejectJoinRequest(
        vaultId: widget.vaultId,
        requestUid: request.uid,
      );
      if (mounted) _loadAll();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't reject the request.")),
      );
    }
  }

  Future<void> _removeMember(VaultMember member) async {
    try {
      await _vaultRepository.removeMember(
        vaultId: widget.vaultId,
        memberUid: member.uid,
      );
      if (mounted) _loadAll();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't remove that member.")),
      );
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Settings')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  _buildVaultInfoCard(),
                  const SizedBox(height: 24),
                  _buildMembersSection(),
                  if (_isOwner) ...[
                    const SizedBox(height: 24),
                    _buildPendingRequestsSection(),
                  ],
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVaultInfoCard() {
    final vault = _vault;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vault?.name ?? '—',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Vault ID', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    widget.vaultId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Copy Vault ID',
                  onPressed: _copyVaultId,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Members', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final member in _members)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(member.displayName),
              subtitle: Text(member.isOwner ? 'Owner' : 'Member'),
              trailing: (_isOwner && !member.isOwner)
                  ? IconButton(
                      icon: const Icon(Icons.person_remove_rounded),
                      tooltip: 'Remove member',
                      onPressed: () => _removeMember(member),
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildPendingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Join Requests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_pendingRequests.isEmpty)
          Text(
            'No pending requests.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          for (final request in _pendingRequests)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(request.displayName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_rounded),
                      tooltip: 'Accept',
                      onPressed: () => _acceptRequest(request),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Reject',
                      onPressed: () => _rejectRequest(request),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
