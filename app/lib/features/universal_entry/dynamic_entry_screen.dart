import 'package:flutter/material.dart';

import '../../core/constants/form_definitions.dart';
import '../../core/models/entry_value.dart';
import '../../core/models/form_field_definition.dart';
import 'review_entry_screen.dart';

/// Dynamic Entry — fourth step of the Universal Entry wizard, and also
/// reused (unmodified renderer) by Phase 07's Edit flow.
///
/// Renders a form generically from [kFormDefinitions] based on the
/// [category] received via constructor. One reusable rendering mechanism
/// (`_buildField`) supports every category — no per-category screens or
/// hardcoded layouts. A [StatefulWidget] only because plain-text input
/// requires local [TextEditingController]s to read back what the user
/// typed; nothing here is persisted or shared beyond this screen's
/// lifetime.
///
/// Two modes, distinguished only by [onSubmit]:
/// - **Create** (default, [onSubmit] null): unchanged since Phase 05 —
///   fields start empty, submitting pushes [ReviewEntryScreen].
/// - **Edit** ([onSubmit] provided, used by `EditEntryScreen`): fields
///   are pre-filled from [initialValues], and submitting calls [onSubmit]
///   directly instead of navigating to Review — the caller decides what
///   "Save" means (an update + pop, in Edit's case). The field-rendering
///   switch itself (`_buildField`) is identical in both modes — nothing
///   about the renderer is duplicated.
class DynamicEntryScreen extends StatefulWidget {
  const DynamicEntryScreen({
    super.key,
    required this.category,
    required this.owner,
    this.initialValues,
    this.onSubmit,
  });

  final String category;
  final String owner;

  /// Pre-fills each field's controller by matching [FormFieldDefinition.label].
  /// Ignored (fields start empty) when null — the Create-mode default.
  final Map<String, String>? initialValues;

  /// When provided, submitting calls this instead of pushing
  /// [ReviewEntryScreen]. Signals Edit mode and changes the submit
  /// button's label from "Review" to "Save".
  final Future<void> Function(List<EntryValue> values)? onSubmit;

  @override
  State<DynamicEntryScreen> createState() => _DynamicEntryScreenState();
}

class _DynamicEntryScreenState extends State<DynamicEntryScreen> {
  late final List<FormFieldDefinition> _fields;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _fields = kFormDefinitions[widget.category] ?? const [];
    _controllers = List.generate(_fields.length, (index) {
      final initial = widget.initialValues?[_fields[index].label];
      return TextEditingController(text: initial ?? '');
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _fields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildField(_fields[index], _controllers[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: widget.onSubmit != null ? _handleSave : _goToReview,
                child: Text(widget.onSubmit != null ? 'Save' : 'Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single reusable rendering mechanism for all 4 supported field types.
  Widget _buildField(
    FormFieldDefinition definition,
    TextEditingController controller,
  ) {
    switch (definition.type) {
      case FormFieldType.text:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: definition.label),
        );
      case FormFieldType.multiline:
        return TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(labelText: definition.label),
        );
      case FormFieldType.number:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: definition.label),
        );
      case FormFieldType.date:
        return TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: definition.label,
            suffixIcon: const Icon(Icons.calendar_today_rounded),
          ),
          onTap: () => _pickDate(controller),
        );
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 100),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  List<EntryValue> _collectValues() {
    return [
      for (var i = 0; i < _fields.length; i++)
        EntryValue(field: _fields[i].label, value: _controllers[i].text),
    ];
  }

  void _goToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewEntryScreen(
          category: widget.category,
          owner: widget.owner,
          values: _collectValues(),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    await widget.onSubmit!(_collectValues());
  }
}
