import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:share_plus/share_plus.dart';

import '../../features/home/home_screen.dart';
import '../../models/family_vault.dart';
import '../../repositories/vault_repository.dart';

/// Create-vault flow: name entry → atomic creation → success state
/// showing the Vault Name, Vault ID, Copy, and Share actions (final
/// design item 3), then a Continue action that opens the Dashboard for
/// the newly created vault directly.
///
/// Final-design requirement 3: tapping Continue never routes through
/// [VaultSelectionScreen] — it clears the entire navigation stack
/// (SignIn → VaultGate → this screen) and lands straight on
/// [HomeScreen] for the vault just created, regardless of how many
/// other memberships the user may separately have.
class CreateVaultScreen extends StatefulWidget {
  const CreateVaultScreen({
    super.key,
    required this.ownerUid,
    required this.ownerDisplayName,
  });

  final String ownerUid;
  final String ownerDisplayName;

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final VaultRepository _vaultRepository = VaultRepository();

  bool _isCreating = false;
  String? _errorMessage;
  FamilyVault? _createdVault;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final vault = await _vaultRepository.createVault(
        name: _nameController.text.trim(),
        ownerUid: widget.ownerUid,
        ownerDisplayName: widget.ownerDisplayName,
      );
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _createdVault = vault;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
        _errorMessage = "Couldn't create the vault. Please try again.";
      });
    }
  }

  void _copyVaultId(String vaultId) {
    Clipboard.setData(ClipboardData(text: vaultId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vault ID copied')),
    );
  }

  void _shareVaultId(String vaultName, String vaultId) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Join our family vault "$vaultName" on Family Vault — '
            'Vault ID: $vaultId',
      ),
    );
  }

  void _continueToDashboard(String vaultId) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(vaultId: vaultId)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdVault = _createdVault;

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Vault')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: createdVault == null
              ? _buildCreateForm()
              : _buildSuccessState(createdVault),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Vault / Family Name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name for your vault.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (_isCreating)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _handleCreate,
              child: const Text('Create'),
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
    );
  }

  Widget _buildSuccessState(FamilyVault vault) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          vault.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Vault created! Share this Vault ID with family members so '
          'they can request to join.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Vault ID',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  vault.vaultId,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyVaultId(vault.vaultId),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareVaultId(vault.name, vault.vaultId),
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _continueToDashboard(vault.vaultId),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
