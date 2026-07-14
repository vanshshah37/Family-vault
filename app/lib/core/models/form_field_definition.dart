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

/// Phase 10 — the validation rule applied to a field's value, independent
/// of [FormFieldType] (which only controls rendering/keyboard). Kept as
/// its own enum rather than folded into [FormFieldType] so that e.g. an
/// email field still renders as a plain text input while getting
/// email-shape validation.
enum ValidationType {
  /// No format check beyond the shared required/trim handling.
  none,

  /// Basic local email-shape validation (no RFC compliance, no package).
  email,

  /// Value must contain digits only when non-empty.
  digitsOnly,
}

/// Pure-data description of a single field within a category's form.
///
/// This is UI configuration only — no business logic lives here.
/// [form_definitions.dart] maps each category to a list of these,
/// [DynamicEntryScreen] renders them generically based on [type], and
/// (Phase 10) validates them generically based on [required] and
/// [validationType].
class FormFieldDefinition {
  const FormFieldDefinition({
    required this.label,
    required this.type,
    this.required = false,
    this.validationType = ValidationType.none,
  });

  final String label;
  final FormFieldType type;

  /// Whether this field must be non-empty (after trimming) to submit.
  /// Defaults to `false` so existing call sites are unaffected.
  final bool required;

  /// Which format rule, if any, applies when the (trimmed) value is
  /// non-empty. Defaults to [ValidationType.none].
  final ValidationType validationType;
}
