import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import '../database/database_service.dart';
import '../models/entry.dart';
import '../utils/credential_fields.dart';

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
///
/// Phase 12 adds two small, purely-additive pieces of write-time logic —
/// still no new public methods, per that same Phase 07 boundary:
///
/// 1. **Previous-password tracking**: on [updateEntry], if the category's
///    password-marked field (see [CredentialFields.passwordField]) has
///    changed from what was previously saved, the old value is preserved
///    under a reserved key ([CredentialFields.previousPasswordKey])
///    inside [Entry.data]'s JSON map — never as a new [Entry] field or
///    SQLite column, so no schema migration is needed and older rows
///    (missing that key entirely) simply read back as "no previous
///    password yet".
/// 2. **`updatedBy` stamping**: every [saveEntry]/[updateEntry] call
///    stamps the display name of whoever is currently signed in on this
///    device (via `FirebaseAuth.instance.currentUser`) under another
///    reserved key ([CredentialFields.updatedByKey]). Per the approved
///    Phase 12 decision, this represents only "the current device's
///    signed-in user" — Entries are still local-only (Phase 11
///    deliberately excluded Entry cloud sync), so this is not, and must
///    not be presented as, a cross-device/family-wide audit trail.
///
/// Both pieces of logic live here, not in any screen, keeping this class
/// the single place that decides what actually gets persisted — exactly
/// the role it has played since Phase 06.
class EntryRepository {
  EntryRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  /// Saves a new [Entry] and returns its auto-generated id. Stamps
  /// `updatedBy` (Phase 12) before writing — a freshly created entry has
  /// no previous password to preserve, so only that one field is added.
  Future<int> saveEntry(Entry entry) {
    final stamped = _stampUpdatedBy(entry);
    return _databaseService.insertEntry(stamped.toMap());
  }

  /// Loads every previously saved [Entry].
  Future<List<Entry>> loadEntries() async {
    final rows = await _databaseService.queryEntries();
    return rows.map(Entry.fromMap).toList();
  }

  /// Updates an existing [Entry] (matched by [Entry.id]). Phase 07.
  ///
  /// Phase 12: before writing, this now (a) looks up the previously
  /// saved version of this same entry to detect a password change, and
  /// (b) re-stamps `updatedBy`. Both are folded into [entry]'s `data`
  /// JSON map — [Entry]'s own shape (`id`/`category`/`owner`/
  /// `createdAt`/`updatedAt`/`data`) is completely unchanged.
  Future<void> updateEntry(Entry entry) async {
    final previous = await _findById(entry.id);
    final withMetadata = _applyPasswordHistoryAndStamp(entry, previous);
    await _databaseService.updateEntry(entry.id!, withMetadata.toMap());
  }

  /// Permanently deletes the entry with the given [id]. Phase 07.
  Future<void> deleteEntry(int id) async {
    await _databaseService.deleteEntry(id);
  }

  // ---------------------------------------------------------------------
  // Phase 12 internals — private, no new public surface on this class.
  // ---------------------------------------------------------------------

  Future<Entry?> _findById(int? id) async {
    if (id == null) return null;
    final all = await loadEntries();
    for (final entry in all) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Entry _stampUpdatedBy(Entry entry) {
    final values = _safeDecodeData(entry.data);
    values[CredentialFields.updatedByKey] = _currentUserDisplayName();
    return entry.copyWith(data: jsonEncode(values));
  }

  Entry _applyPasswordHistoryAndStamp(Entry newEntry, Entry? previousEntry) {
    final newValues = _safeDecodeData(newEntry.data);
    final previousValues = previousEntry != null
        ? _safeDecodeData(previousEntry.data)
        : const <String, String>{};

    final passwordLabel = CredentialFields.passwordField(newEntry.category)?.label;
    if (passwordLabel != null) {
      final oldPassword = previousValues[passwordLabel];
      final newPassword = newValues[passwordLabel];

      if (oldPassword != null &&
          oldPassword.isNotEmpty &&
          oldPassword != newPassword) {
        // The password actually changed — the value it's changing FROM
        // becomes the new "previous password".
        newValues[CredentialFields.previousPasswordKey] = oldPassword;
      } else if (previousValues.containsKey(CredentialFields.previousPasswordKey)) {
        // Password unchanged this edit — carry forward whatever was
        // already recorded as the previous password, rather than
        // silently dropping it because this particular save didn't
        // touch the password field.
        newValues[CredentialFields.previousPasswordKey] =
            previousValues[CredentialFields.previousPasswordKey]!;
      }
    }

    newValues[CredentialFields.updatedByKey] = _currentUserDisplayName();
    return newEntry.copyWith(data: jsonEncode(newValues));
  }

  String _currentUserDisplayName() {
    return FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown';
  }

  /// Defensive JSON decode mirroring the one already used by
  /// [SearchScreen] — malformed [Entry.data] must never crash a save.
  Map<String, String> _safeDecodeData(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      return <String, String>{};
    } catch (_) {
      return <String, String>{};
    }
  }
}
