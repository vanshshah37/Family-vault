/// Database-level constants: file name, schema version, table name, and
/// column names for the `entries` table.
///
/// Kept separate from [DatabaseService] and [Entry] so schema identifiers
/// exist in exactly one place. Per 02_MASTER_RULES.md ("Never modify the
/// database schema without approval... Always create migrations when
/// schema changes are required"), any future change to these values is a
/// schema change and must go through that process, not be edited casually.
class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'family_vault.db';
  static const int databaseVersion = 1;

  static const String entriesTable = 'entries';

  static const String columnId = 'id';
  static const String columnCategory = 'category';
  static const String columnOwner = 'owner';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnData = 'data';
}
