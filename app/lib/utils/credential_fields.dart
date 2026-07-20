import '../core/constants/form_definitions.dart';
import '../core/models/form_field_definition.dart';

/// Phase 12 — the single place that answers "which field is the
/// password/username field for this category," so [EntryRepository]
/// (writing) and [EntryDetailsScreen] (reading/displaying) never
/// duplicate that lookup or drift out of sync with each other.
abstract class CredentialFields {
  /// Reserved JSON keys used inside [Entry.data] for Phase 12 metadata
  /// that isn't tied to any single [FormFieldDefinition.label] — the
  /// double-underscore prefix keeps these from ever colliding with a
  /// real, user-facing field label (which are always plain words like
  /// "Password" or "Website").
  static const String previousPasswordKey = '__previousPassword';
  static const String updatedByKey = '__updatedByName';

  /// All reserved metadata keys — used by Search/preview logic to skip
  /// internal bookkeeping fields when scanning a decoded entry's data.
  static const Set<String> reservedKeys = {previousPasswordKey, updatedByKey};

  static FormFieldDefinition? passwordField(String category) {
    return _firstWhere(category, (field) => field.isPassword);
  }

  static FormFieldDefinition? usernameField(String category) {
    return _firstWhere(category, (field) => field.isUsername);
  }

  static FormFieldDefinition? _firstWhere(
    String category,
    bool Function(FormFieldDefinition field) predicate,
  ) {
    final fields = kFormDefinitions[category];
    if (fields == null) return null;
    for (final field in fields) {
      if (predicate(field)) return field;
    }
    return null;
  }
}
