import 'package:flutter/material.dart';

import '../features/entries/entry_list_screen.dart';
import '../features/search/search_screen.dart';
import '../features/universal_entry/universal_entry_screen.dart';

/// Lightweight static navigation helper for Family Vault.
///
/// Wraps `Navigator.push` + `MaterialPageRoute` for every destination
/// screen. Intentionally simple — one static method per destination, no
/// named routes, no routing package, no `main.dart` changes.
///
/// Phase 07: the Dashboard's category cards now open [EntryListScreen]
/// (viewing/editing/deleting saved entries) instead of the Phase 03
/// placeholder screens. Those 6 placeholder screens
/// (`PersonalScreen`/`CorporateScreen`/etc.) still exist in the project
/// but are intentionally left unused, per explicit instruction — not
/// deleted, not referenced from here anymore. The Universal Entry
/// creation flow (FAB → ... → Review → Finish) is unaffected and
/// continues to navigate internally within `features/universal_entry/`,
/// not through this router.
class AppRouter {
  AppRouter._();

  static void openEntryList(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryListScreen(category: category),
      ),
    );
  }

  static void openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  static void openUniversalEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UniversalEntryScreen()),
    );
  }
}
