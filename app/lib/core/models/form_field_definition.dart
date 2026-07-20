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
///
/// Phase 12 adds three field-role markers — [isPassword], [isUsername],
/// [isSearchable] — so credential-related features (strength meter,
/// copy actions, previous-password tracking, search scope) can key off
/// "which field plays this role for this category" instead of any
/// screen hardcoding a field label or category name. All three default
/// to `false`, so every existing [kFormDefinitions] entry is completely
/// unaffected unless a field explicitly opts in.
class FormFieldDefinition {
  const FormFieldDefinition({
    required this.label,
    required this.type,
    this.required = false,
    this.validationType = ValidationType.none,
    this.isPassword = false,
    this.isUsername = false,
    this.isSearchable = false,
  });

  final String label;
  final FormFieldType type;

  /// Whether this field must be non-empty (after trimming) to submit.
  /// Defaults to `false` so existing call sites are unaffected.
  final bool required;

  /// Which format rule, if any, applies when the (trimmed) value is
  /// non-empty. Defaults to [ValidationType.none].
  final ValidationType validationType;

  /// Phase 12: marks this field as "the password" for its category.
  /// At most one field per category is expected to set this to `true`.
  /// When set, [DynamicEntryScreen] renders it via the obscured
  /// `PasswordFormField` (show/hide toggle + live strength meter)
  /// instead of a plain [TextFormField], and [EntryRepository] tracks
  /// its previous value on change. Never treated as searchable,
  /// regardless of [isSearchable]'s value — a password must never be
  /// matchable by Search, by design.
  final bool isPassword;

  /// Phase 12: marks this field as "the username" for its category, for
  /// the dedicated Copy Username action and metadata display in
  /// [EntryDetailsScreen].
  final bool isUsername;

  /// Phase 12: marks a field as specifically intended for Search (e.g.
  /// Website, Username, Notes) — self-documentation for which fields a
  /// category's author added with search in mind. NOT currently
  /// consulted as an allow-list by [SearchScreen]'s matching logic: since
  /// most existing categories have no field marked `true` here at all,
  /// enforcing it as an allow-list would silently stop Search from
  /// matching any of their fields. Search instead matches every field
  /// except [isPassword] ones, which is a superset that already includes
  /// every `isSearchable` field — flip this into an actual filter only
  /// if a future category needs some fields deliberately excluded from
  /// search beyond just the password.
  final bool isSearchable;
}
