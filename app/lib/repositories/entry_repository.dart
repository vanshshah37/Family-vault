import '../database/database_service.dart';
import '../models/entry.dart';

/// The only allowed boundary between UI and persistence.
///
/// Per Phase 06's Architect Notes: "The UI must not know how SQLite
/// works... the repository is the only layer allowed to communicate with
/// the database." No screen should import [DatabaseService] or `sqflite`
/// directly — only this class.
///
/// Scope for Phase 06 is intentionally narrow (save + load only); Update
/// and Delete are explicitly excluded and will be added here in Phase 07
/// without requiring any UI screen to change.
class EntryRepository {
  EntryRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  /// Saves a new [Entry] and returns its auto-generated id.
  Future<int> saveEntry(Entry entry) {
    return _databaseService.insertEntry(entry.toMap());
  }

  /// Loads every previously saved [Entry].
  Future<List<Entry>> loadEntries() async {
    final rows = await _databaseService.queryEntries();
    return rows.map(Entry.fromMap).toList();
  }
}
