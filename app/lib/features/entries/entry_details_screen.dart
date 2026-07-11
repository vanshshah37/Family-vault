import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/form_definitions.dart';
import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import 'edit_entry_screen.dart';

/// Entry Details — displays every stored field of one [Entry], with Edit
/// and Delete actions.
///
/// A [StatefulWidget] so it can show the freshly updated entry in place
/// after [EditEntryScreen] returns, without needing to pop all the way
/// back to [EntryListScreen] first (per decision: "After Edit → Save:
/// Return to the updated EntryDetailsScreen").
class EntryDetailsScreen extends StatefulWidget {
  const EntryDetailsScreen({super.key, required this.entry});

  final Entry entry;

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  late Entry _entry = widget.entry;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final values = _decodedValues();
    final fields = kFormDefinitions[_entry.category] ?? const [];

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
                  const SizedBox(height: 24),
                  Text('Details', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final field in fields) ...[
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
        title: const Text('Delete Entry'),
        content: const Text(
          'This will permanently delete this entry. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
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
