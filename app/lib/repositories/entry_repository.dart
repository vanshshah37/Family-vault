import '../database/database_service.dart';
import '../models/entry.dart';

/// The only allowed boundary between UI and persistence.
///
/// Per Phase 06's Architect Notes: "The UI must not know how SQLite
/// works... the repository is the only layer allowed to communicate with
/// the database." No screen should import [DatabaseService] or `sqflite`
/// directly — only this class.
///
/// Phase 06 added save/load; Phase 07 adds update/delete, completing the
/// CRUD engine. No other methods are added — Search/Filter/Sort remain
/// out of scope and, per the Architect Notes, will build on
/// [EntryListScreen] rather than on new repository methods.
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

  /// Updates an existing [Entry] (matched by [Entry.id]). Phase 07.
  Future<void> updateEntry(Entry entry) async {
    await _databaseService.updateEntry(entry.id!, entry.toMap());
  }

  /// Permanently deletes the entry with the given [id]. Phase 07.
  Future<void> deleteEntry(int id) async {
    await _databaseService.deleteEntry(id);
  }
}
