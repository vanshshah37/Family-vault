import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/models/entry_value.dart';
import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import '../universal_entry/dynamic_entry_screen.dart';

/// Edit Entry — reuses [DynamicEntryScreen]'s field renderer in Edit mode
/// (pre-filled values, "Save" instead of "Review").
///
/// Per the Architect Notes ("Do not duplicate the Dynamic Entry
/// renderer"), this screen contains no field-rendering logic of its own —
/// it only decodes the existing entry's JSON `data` into initial values,
/// and supplies an `onSubmit` callback that builds an updated [Entry] and
/// saves it via [EntryRepository]. All actual field UI comes from
/// [DynamicEntryScreen].
class EditEntryScreen extends StatelessWidget {
  const EditEntryScreen({super.key, required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final decoded = jsonDecode(entry.data) as Map<String, dynamic>;
    final initialValues = decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return DynamicEntryScreen(
      category: entry.category,
      owner: entry.owner,
      initialValues: initialValues,
      onSubmit: (values) => _handleSave(context, values),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    List<EntryValue> values,
  ) async {
    final fieldValues = {
      for (final entryValue in values) entryValue.field: entryValue.value,
    };
    final updated = entry.copyWith(
      data: jsonEncode(fieldValues),
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      await EntryRepository().updateEntry(updated);
      if (!context.mounted) return;
      Navigator.pop(context, updated);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save changes. Please try again.'),
        ),
      );
    }
  }
}
