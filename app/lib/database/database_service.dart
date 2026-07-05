import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

/// Owns the SQLite [Database] lifecycle: resolving the file path, opening
/// it, and creating the schema on first run.
///
/// This is the only file in the project that imports `sqflite` directly.
/// UI code must never reach this class directly — always go through
/// [EntryRepository], per Phase 06's Architect Notes ("The repository is
/// the only layer allowed to communicate with the database").
///
/// Works on both Android and Windows because `main.dart` swaps in the
/// desktop FFI `databaseFactory` before `runApp()` on Windows/Linux/macOS;
/// this class itself is unaware of which backend is active — it only
/// calls the platform-agnostic `sqflite` API.
class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  Database? _database;

  Future<Database> get _db async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}${Platform.pathSeparator}${DatabaseConstants.databaseName}';

    return openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${DatabaseConstants.entriesTable} (
            ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DatabaseConstants.columnCategory} TEXT NOT NULL,
            ${DatabaseConstants.columnOwner} TEXT NOT NULL,
            ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
            ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL,
            ${DatabaseConstants.columnData} TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Inserts a raw row map (from `Entry.toMap()`) and returns the new
  /// auto-generated id.
  Future<int> insertEntry(Map<String, Object?> values) async {
    final db = await _db;
    return db.insert(DatabaseConstants.entriesTable, values);
  }

  /// Returns every stored row as raw maps (for `Entry.fromMap()`).
  Future<List<Map<String, Object?>>> queryEntries() async {
    final db = await _db;
    return db.query(DatabaseConstants.entriesTable);
  }
}
