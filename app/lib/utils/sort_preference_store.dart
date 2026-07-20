import 'package:shared_preferences/shared_preferences.dart';

import 'entry_sort_option.dart';

/// Phase 12 — the one small piece of local key-value persistence this
/// phase needs ("remember the user's last selected sort option").
///
/// This is the project's first use of `shared_preferences` — Phase 11
/// deliberately avoided adding any local settings store (e.g. for "last
/// selected vault"), so this is a new, minimal dependency, added only
/// for this one value, per the approved Phase 12 decision.
abstract class SortPreferenceStore {
  static const String _prefsKey = 'entry_sort_option';

  static Future<EntrySortOption> load() async {
    final prefs = await SharedPreferences.getInstance();
    return EntrySortOption.fromStorageKey(prefs.getString(_prefsKey));
  }

  static Future<void> save(EntrySortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, option.storageKey);
  }
}
