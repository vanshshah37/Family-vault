import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../core/constants/form_definitions.dart';
import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import '../../utils/credential_fields.dart';
import 'edit_entry_screen.dart';

/// Entry Details — displays every stored field of one [Entry], with Edit
/// and Delete actions.
///
/// A [StatefulWidget] so it can show the freshly updated entry in place
/// after [EditEntryScreen] returns, without needing to pop all the way
/// back to [EntryListScreen] first (per decision: "After Edit → Save:
/// Return to the updated EntryDetailsScreen").
///
/// Phase 12 adds, all conditional on the category actually having a
/// password-marked field (see [CredentialFields.passwordField] — today
/// only 'Share Market'; every other category renders exactly as before):
/// - An "Updated By" metadata row alongside the existing Created/Last
///   Updated rows (reads a reserved key from `Entry.data`; missing on
///   older entries reads back as "—", never a crash).
/// - A "Login Details" section showing Username (with Copy) and
///   Current/Previous Password (masked, independently revealable, with
///   Copy on the current one) — pulled out of the generic field loop so
///   they aren't shown twice.
/// - A polished delete-confirmation dialog naming the entry, plus a
///   success Snackbar before popping.
class EntryDetailsScreen extends StatefulWidget {
  const EntryDetailsScreen({super.key, required this.entry});

  final Entry entry;

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  late Entry _entry = widget.entry;
  bool _isDeleting = false;

  // Phase 12: always starts hidden, and is never persisted anywhere —
  // reopening this screen (a fresh State) always starts hidden again,
  // matching the same "never carry over" rule used by PasswordFormField.
  bool _currentPasswordVisible = false;
  bool _previousPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final values = _decodedValues();
    final allFields = kFormDefinitions[_entry.category] ?? const [];

    final passwordField = CredentialFields.passwordField(_entry.category);
    final usernameField = CredentialFields.usernameField(_entry.category);

    // The generic "Details" loop below shows every field EXCEPT the
    // username/password fields, which get their own dedicated Login
    // Details section further down — this avoids showing either twice.
    final genericFields = allFields.where((field) {
      return field.label != passwordField?.label &&
          field.label != usernameField?.label;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_entry.category)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Owner', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(_entry.owner, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('Created', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(_entry.createdAt.split('T').first, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('Last Updated', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(_entry.updatedAt.split('T').first, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('Updated By', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    _valueOrDash(values[CredentialFields.updatedByKey]),
                    style: textTheme.bodyLarge,
                  ),
                  if (passwordField != null) ...[
                    const SizedBox(height: 24),
                    Text('Login Details', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (usernameField != null)
                      _buildUsernameRow(context, usernameField.label, values),
                    const SizedBox(height: 16),
                    _buildPasswordRow(
                      context,
                      label: 'Current Password',
                      value: values[passwordField.label],
                      visible: _currentPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _currentPasswordVisible = !_currentPasswordVisible;
                        });
                      },
                      showCopyAction: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordRow(
                      context,
                      label: 'Previous Password',
                      value: values[CredentialFields.previousPasswordKey],
                      visible: _previousPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _previousPasswordVisible = !_previousPasswordVisible;
                        });
                      },
                      showCopyAction: false,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('Details', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final field in genericFields) ...[
                    Text(field.label, style: textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      _valueOrDash(values[field.label]),
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : _handleEdit,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: _isDeleting ? null : _handleDelete,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameRow(
    BuildContext context,
    String usernameLabel,
    Map<String, String> values,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedValue = values[usernameLabel] ?? '';
    final hasValue = resolvedValue.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(usernameLabel, style: textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(hasValue ? resolvedValue : '—', style: textTheme.bodyLarge),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded),
          tooltip: 'Copy $usernameLabel',
          onPressed: hasValue
              ? () => _copyToClipboard(resolvedValue, '$usernameLabel copied')
              : null,
        ),
      ],
    );
  }

  Widget _buildPasswordRow(
    BuildContext context, {
    required String label,
    required String? value,
    required bool visible,
    required VoidCallback onToggleVisibility,
    required bool showCopyAction,
  }) {
    final textTheme = Theme.of(context).textTheme;
    // Resolved to a non-null local immediately — type promotion from a
    // separately-computed bool (`hasValue`) doesn't carry over to a
    // different variable's nullability in Dart, so every later use in
    // this function reads `resolvedValue`, never the nullable `value`.
    final resolvedValue = value ?? '';
    final hasValue = resolvedValue.isNotEmpty;
    final dotCount = hasValue ? resolvedValue.length.clamp(6, 12).toInt() : 0;
    final displayText = !hasValue
        ? '—'
        : (visible ? resolvedValue : '•' * dotCount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  displayText,
                  key: ValueKey(visible),
                  style: textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        if (hasValue)
          IconButton(
            icon: Icon(
              visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            ),
            tooltip: visible ? 'Hide $label' : 'Show $label',
            onPressed: onToggleVisibility,
          ),
        if (showCopyAction)
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy $label',
            onPressed: hasValue
                ? () => _copyToClipboard(resolvedValue, '$label copied')
                : null,
          ),
      ],
    );
  }

  void _copyToClipboard(String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ $message')),
    );
  }

  Map<String, String> _decodedValues() {
    final decoded = jsonDecode(_entry.data) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  String _valueOrDash(String? value) {
    return (value == null || value.isEmpty) ? '—' : value;
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(builder: (_) => EditEntryScreen(entry: _entry)),
    );
    if (updated != null && mounted) {
      setState(() => _entry = updated);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Delete ${_entry.category}?'),
        content: Text(
          '${_entry.owner}\n\nThis action cannot be undone.',
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || _entry.id == null) return;

    setState(() => _isDeleting = true);

    try {
      await EntryRepository().deleteEntry(_entry.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Entry Deleted')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete this entry. Please try again.'),
        ),
      );
    }
  }
}
