import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../navigation/app_router.dart';
import '../../widgets/category_card.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/stat_card.dart';

/// Permanent Dashboard screen — the application's home screen.
///
/// Layout is unchanged since Phase 02 (static, placeholder-driven UI).
/// Phase 03 added navigation for category cards and the search icon.
/// Phase 04 wired the FAB to launch the Universal Entry wizard via
/// [AppRouter]. Phase 07 retargets the category cards to open
/// [EntryListScreen] (viewing/editing/deleting saved entries) instead of
/// the Phase 03 placeholder screens. Still no database calls here
/// directly — this screen only navigates. Category placeholders come
/// from the shared [kCategories] list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Placeholder statistics (Phase 02 — static values only).
  static const List<_StatItem> _stats = [
    _StatItem(icon: Icons.account_balance_wallet_rounded, value: '34', label: 'Accounts'),
    _StatItem(icon: Icons.description_rounded, value: '18', label: 'Documents'),
    _StatItem(icon: Icons.cloud_done_rounded, value: '2 days ago', label: 'Last Backup'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => AppRouter.openSearch(context),
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your family's important information securely.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildStatistics(),
            const SizedBox(height: 24),
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildCategories(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        for (var i = 0; i < _stats.length; i++) ...[
          if (i != 0) const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: _stats[i].icon,
              value: _stats[i].value,
              label: _stats[i].label,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kCategories.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final category = kCategories[index];
        return CategoryCard(
          icon: category.icon,
          label: category.label,
          onTap: () => AppRouter.openEntryList(context, category.label),
        );
      },
    );
  }

  Widget _buildFab(BuildContext context) {
    // Colors intentionally omitted — inherited from
    // AppTheme.lightTheme.floatingActionButtonTheme.
    return FloatingActionButton(
      onPressed: () => AppRouter.openUniversalEntry(context),
      child: const Icon(Icons.add),
    );
  }
}

/// Internal placeholder model for a single statistic entry.
class _StatItem {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}
