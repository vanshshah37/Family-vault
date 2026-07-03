import 'package:flutter/material.dart';

import '../../navigation/app_router.dart';
import '../../widgets/category_card.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/stat_card.dart';

/// Permanent Dashboard screen — the application's home screen.
///
/// Layout is unchanged since Phase 02 (static, placeholder-driven UI).
/// Phase 03 adds navigation only: category cards and the search icon now
/// push their corresponding placeholder screens via [AppRouter]. Still no
/// database, providers, or business logic. Statistics and category values
/// below remain hardcoded placeholders.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Placeholder statistics (Phase 02 — static values only).
  static const List<_StatItem> _stats = [
    _StatItem(icon: Icons.account_balance_wallet_rounded, value: '34', label: 'Accounts'),
    _StatItem(icon: Icons.description_rounded, value: '18', label: 'Documents'),
    _StatItem(icon: Icons.cloud_done_rounded, value: '2 days ago', label: 'Last Backup'),
  ];

  // Placeholder categories (Phase 02 — static values only).
  static const List<_CategoryItem> _categories = [
    _CategoryItem(icon: Icons.person_rounded, label: 'Personal'),
    _CategoryItem(icon: Icons.business_rounded, label: 'Corporate'),
    _CategoryItem(icon: Icons.show_chart_rounded, label: 'Share Market'),
    _CategoryItem(icon: Icons.groups_rounded, label: 'Joint'),
    _CategoryItem(icon: Icons.folder_rounded, label: 'Documents'),
    _CategoryItem(icon: Icons.info_rounded, label: 'Information'),
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
      floatingActionButton: _buildFab(),
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
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return CategoryCard(
          icon: category.icon,
          label: category.label,
          onTap: () => _handleCategoryTap(context, category.label),
        );
      },
    );
  }

  void _handleCategoryTap(BuildContext context, String label) {
    switch (label) {
      case 'Personal':
        AppRouter.openPersonal(context);
      case 'Corporate':
        AppRouter.openCorporate(context);
      case 'Share Market':
        AppRouter.openShareMarket(context);
      case 'Joint':
        AppRouter.openJoint(context);
      case 'Documents':
        AppRouter.openDocuments(context);
      case 'Information':
        AppRouter.openInformation(context);
    }
  }

  Widget _buildFab() {
    // Colors intentionally omitted — inherited from
    // AppTheme.lightTheme.floatingActionButtonTheme.
    return FloatingActionButton(
      onPressed: () {},
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

/// Internal placeholder model for a single category entry.
class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
