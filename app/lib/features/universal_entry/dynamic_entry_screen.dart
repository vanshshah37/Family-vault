import 'package:flutter/material.dart';

import '../../core/constants/form_definitions.dart';
import '../../core/models/entry_value.dart';
import '../../core/models/form_field_definition.dart';
import '../../widgets/password_form_field.dart';
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
///
/// Phase 10 adds one centralized, config-driven validation layer on top
/// of this same renderer — a single [Form]/[GlobalKey] and one private
/// validator function, reused by both Create and Edit and by every field
/// type. No per-category or per-field-type validator classes exist;
/// [FormFieldDefinition.required] and [FormFieldDefinition.validationType]
/// are the only inputs the validator reads.
///
/// Phase 12 adds exactly one new branch to [_buildField]: a field with
/// [FormFieldDefinition.isPassword] set renders via [PasswordFormField]
/// (obscured, show/hide toggle, live strength meter) instead of a plain
/// [TextFormField] — everything else about the renderer, including the
/// centralized [_validate] function, is untouched. Because this reads
/// [FormFieldDefinition.isPassword] (defaulting to `false`), every field
/// in every category that doesn't opt in renders exactly as before.
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
  final _formKey = GlobalKey<FormState>();

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
        ),
      ),
    );
  }

  /// Single reusable rendering mechanism for all 4 supported field types,
  /// plus the one Phase 12 addition: a password-marked field short-
  /// circuits to [PasswordFormField] before the [FormFieldType] switch
  /// is ever reached — the switch itself is completely unmodified.
  Widget _buildField(
    FormFieldDefinition definition,
    TextEditingController controller,
  ) {
    if (definition.isPassword) {
      return PasswordFormField(
        controller: controller,
        label: definition.label,
        validator: (value) => _validate(definition, value),
        showStrengthIndicator: true,
      );
    }

    switch (definition.type) {
      case FormFieldType.text:
        return TextFormField(
          controller: controller,
          keyboardType: definition.validationType == ValidationType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(labelText: definition.label),
          validator: (value) => _validate(definition, value),
        );
      case FormFieldType.multiline:
        return TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(labelText: definition.label),
          validator: (value) => _validate(definition, value),
        );
      case FormFieldType.number:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: definition.label),
          validator: (value) => _validate(definition, value),
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
          validator: (value) => _validate(definition, value),
        );
    }
  }

  /// The one centralized validator for every field, driven only by
  /// [FormFieldDefinition.required] and [FormFieldDefinition.validationType]
  /// (plus [FormFieldDefinition.type] for the date-specific real-date
  /// check). No category-specific or field-specific branches exist here.
  String? _validate(FormFieldDefinition definition, String? rawValue) {
    final value = (rawValue ?? '').trim();

    if (definition.required && value.isEmpty) {
      return 'This field is required';
    }
    if (value.isEmpty) {
      return null;
    }

    if (definition.type == FormFieldType.date) {
      return _isRealDate(value) ? null : 'Please reselect a valid date';
    }

    switch (definition.validationType) {
      case ValidationType.email:
        final validEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
        return validEmail ? null : 'Enter a valid email address';
      case ValidationType.digitsOnly:
        final validDigits = RegExp(r'^[0-9]+$').hasMatch(value);
        return validDigits ? null : 'Enter digits only';
      case ValidationType.none:
        return null;
    }
  }

  /// Validates that [value] is both shaped like dd/mm/yyyy and represents
  /// a real calendar date (e.g. rejects 31/02/2026 and 99/99/2026) rather
  /// than only checking the regex shape.
  bool _isRealDate(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value);
    if (match == null) return false;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    final parsed = DateTime(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
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

  /// Trims every value before handing it to Create or Edit — the single
  /// shared normalization point for both flows.
  List<EntryValue> _collectValues() {
    return [
      for (var i = 0; i < _fields.length; i++)
        EntryValue(
          field: _fields[i].label,
          value: _controllers[i].text.trim(),
        ),
    ];
  }

  void _goToReview() {
    if (!_formKey.currentState!.validate()) return;

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
    if (!_formKey.currentState!.validate()) return;

    await widget.onSubmit!(_collectValues());
  }
}
