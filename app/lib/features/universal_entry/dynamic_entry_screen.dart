import 'package:flutter/material.dart';

import '../../core/constants/form_definitions.dart';
import '../../core/models/entry_value.dart';
import '../../core/models/form_field_definition.dart';
import 'review_entry_screen.dart';

/// Dynamic Entry — fourth step of the Universal Entry wizard.
///
/// Renders a form generically from [kFormDefinitions] based on the
/// [category] received via constructor. One reusable rendering mechanism
/// (`_buildField`) supports every category — no per-category screens or
/// hardcoded layouts. A [StatefulWidget] only because plain-text input
/// requires local [TextEditingController]s to read back what the user
/// typed; nothing here is persisted or shared beyond this screen's
/// lifetime.
class DynamicEntryScreen extends StatefulWidget {
  const DynamicEntryScreen({
    super.key,
    required this.category,
    required this.owner,
  });

  final String category;
  final String owner;

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
    _controllers = List.generate(
      _fields.length,
      (_) => TextEditingController(),
    );
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
                onPressed: _goToReview,
                child: const Text('Review'),
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

  void _goToReview() {
    final values = [
      for (var i = 0; i < _fields.length; i++)
        EntryValue(field: _fields[i].label, value: _controllers[i].text),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewEntryScreen(
          category: widget.category,
          owner: widget.owner,
          values: values,
        ),
      ),
    );
  }
}
