/// Lightweight UI model representing one entered field value.
///
/// Purely a data holder — not a database entity, not tied to persistence.
/// [DynamicEntryScreen] collects a `List<EntryValue>` (preserving field
/// order) and passes it to [ReviewEntryScreen] via a constructor
/// parameter. Using an explicit list of (field, value) pairs instead of a
/// `Map<String, String>` keeps entry order guaranteed and gives Phase 06
/// (SQLite) a ready-made shape to persist without any UI changes.
class EntryValue {
  const EntryValue({
    required this.field,
    required this.value,
  });

  final String field;
  final String value;
}
