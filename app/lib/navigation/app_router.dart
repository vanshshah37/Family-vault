import 'package:flutter/material.dart';

import '../features/entries/entry_list_screen.dart';
import '../features/search/search_screen.dart';
import '../features/universal_entry/universal_entry_screen.dart';
import '../features/vault/vault_settings_screen.dart';

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
///
/// Phase 08: [openEntryList] and [openUniversalEntry] now return the
/// `Future` from `Navigator.push` (instead of discarding it) so
/// [HomeScreen] can `await` navigation completion and reload its live
/// Dashboard statistics once control returns — regardless of how the
/// pushed screen was exited (Back, Finish, Delete, etc.). [openSearch]
/// is left unchanged since Search has no bearing on Dashboard statistics.
///
/// Phase 11: adds [openVaultSettings] for the one approved Dashboard
/// AppBar action (Vault Name/ID, Members, Pending Join Requests, Sign
/// Out — see [VaultSettingsScreen]). Sign-in, vault-gate, vault
/// selection, and create/join-vault navigation intentionally do NOT go
/// through this router: they use `pushReplacement`/`pushAndRemoveUntil`
/// directly at their call sites, since they replace the navigation stack
/// rather than pushing a normal back-able destination — see
/// `lib/features/auth/` and `lib/features/vault/` for that flow.
class AppRouter {
  AppRouter._();

  static Future<void> openEntryList(BuildContext context, String category) {
    return Navigator.push(
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

  static Future<void> openUniversalEntry(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UniversalEntryScreen()),
    );
  }

  static Future<void> openVaultSettings(BuildContext context, String vaultId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VaultSettingsScreen(vaultId: vaultId),
      ),
    );
  }
}
