/// The 4 supported field types for the Dynamic Entry engine (Phase 05).
///
/// No dropdowns, no file/image pickers, no custom widgets — only these
/// four, rendered generically by a single reusable mechanism.
enum FormFieldType {
  text,
  multiline,
  number,
  date,
}

/// Pure-data description of a single field within a category's form.
///
/// This is UI configuration only — no business logic, no validation, no
/// persistence. [form_definitions.dart] maps each category to a list of
/// these, and [DynamicEntryScreen] renders them generically based on
/// [type].
class FormFieldDefinition {
  const FormFieldDefinition({
    required this.label,
    required this.type,
  });

  final String label;
  final FormFieldType type;
}
