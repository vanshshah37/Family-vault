import 'package:flutter/material.dart';

import '../features/corporate/corporate_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/information/information_screen.dart';
import '../features/joint/joint_screen.dart';
import '../features/personal/personal_screen.dart';
import '../features/search/search_screen.dart';
import '../features/share_market/share_market_screen.dart';

/// Lightweight static navigation helper for Family Vault.
///
/// Wraps `Navigator.push` + `MaterialPageRoute` for every destination
/// screen. Intentionally simple — one static method per destination, no
/// named routes, no routing package, no `main.dart` changes. This keeps
/// navigation calls out of [HomeScreen] and centralized in one place,
/// while remaining easy to extend in later phases (e.g. Universal Entry).
class AppRouter {
  AppRouter._();

  static void openPersonal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonalScreen()),
    );
  }

  static void openCorporate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CorporateScreen()),
    );
  }

  static void openShareMarket(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShareMarketScreen()),
    );
  }

  static void openJoint(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JointScreen()),
    );
  }

  static void openDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocumentsScreen()),
    );
  }

  static void openInformation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InformationScreen()),
    );
  }

  static void openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }
}
