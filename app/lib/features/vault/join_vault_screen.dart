import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/vault_repository.dart';
import '../../utils/vault_id_generator.dart';

/// Join-existing-vault flow (Phase 11 design items 33-38, revised
/// item 5): enter a Vault ID → validate → submit a join request → show
/// a "Request Sent" confirmation state in place, rather than popping
/// back to the previous screen.
class JoinVaultScreen extends StatefulWidget {
  const JoinVaultScreen({super.key});

  @override
  State<JoinVaultScreen> createState() => _JoinVaultScreenState();
}

class _JoinVaultScreenState extends State<JoinVaultScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaultIdController = TextEditingController();
  final VaultRepository _vaultRepository = VaultRepository();

  bool _isSubmitting = false;
  bool _requestSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _vaultIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Shouldn't happen — gated behind sign-in.

    final vaultId = VaultIdGenerator.normalize(_vaultIdController.text);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final vault = await _vaultRepository.findVaultById(vaultId);
      if (vault == null) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = "That Vault ID wasn't found.";
        });
        return;
      }

      final existingMembership = await _vaultRepository.findMembership(
        vaultId: vaultId,
        uid: user.uid,
      );
      if (existingMembership != null) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = "You're already a member of this vault.";
        });
        return;
      }

      final existingRequest = await _vaultRepository.findOwnJoinRequest(
        vaultId: vaultId,
        uid: user.uid,
      );
      if (existingRequest != null && existingRequest.status == 'pending') {
        // Already pending — show the same confirmation state rather
        // than writing again or erroring.
        setState(() {
          _isSubmitting = false;
          _requestSent = true;
        });
        return;
      }

      await _vaultRepository.submitJoinRequest(
        vaultId: vaultId,
        uid: user.uid,
        displayName: user.displayName ?? 'Family Member',
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _requestSent = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = "Couldn't send the join request. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Existing Vault')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _requestSent ? _buildRequestSentState() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _vaultIdController,
            decoration: const InputDecoration(
              labelText: 'Vault ID',
              hintText: 'FV-7K9X-2M4P',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a Vault ID.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Send Request'),
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

  Widget _buildRequestSentState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hourglass_top_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Request Sent',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Waiting for the vault owner to approve your request.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
      ],
    );
  }
}
