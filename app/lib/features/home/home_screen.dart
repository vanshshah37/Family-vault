import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../navigation/app_router.dart';
import '../../repositories/entry_repository.dart';
import '../../widgets/category_card.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/stat_card.dart';

/// Permanent Dashboard screen — the application's home screen.
///
/// Visual structure is unchanged since Phase 02 (same [DashboardCard],
/// [StatCard] row, [CategoryCard] grid, spacing, padding, and icons).
/// Phase 03 added navigation for category cards and the search icon.
/// Phase 04 wired the FAB to launch the Universal Entry wizard. Phase 07
/// retargeted the category cards to open [EntryListScreen]. Phase 08
/// replaces the three hardcoded statistics with live values computed
/// in-memory from [EntryRepository.loadEntries] — no new repository
/// methods, no Riverpod/Provider/streams, no schema changes. The FAB and
/// category navigation calls are now awaited so the Dashboard can reload
/// its statistics whenever control returns.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _placeholder = '—';

  String _accountsCountDisplay = _placeholder;
  String _documentsCountDisplay = _placeholder;
  String _lastUpdatedDisplay = _placeholder;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Loads every entry via [EntryRepository] and computes the three
  /// Dashboard statistics in memory. On failure, falls back to the same
  /// neutral placeholder used during loading — no raw exception text is
  /// ever shown, and the Dashboard stays fully usable either way. No
  /// `_isLoading` guard is used: every refresh requested after returning
  /// from the creation or CRUD flow is allowed to run.
  Future<void> _loadDashboardData() async {
  try {
    final entries = await EntryRepository().loadEntries();

    int accountsCount = 0;
    int documentsCount = 0;

    DateTime? latestUpdatedAt;

    for (final entry in entries) {
      if (entry.category == 'Documents') {
        documentsCount++;
      } else {
        accountsCount++;
      }

      final parsed = DateTime.tryParse(entry.updatedAt);
      if (parsed != null &&
          (latestUpdatedAt == null || parsed.isAfter(latestUpdatedAt))) {
        latestUpdatedAt = parsed;
      }
    }

    if (!mounted) return;

    setState(() {
      _accountsCountDisplay = accountsCount.toString();
      _documentsCountDisplay = documentsCount.toString();
      _lastUpdatedDisplay = _formatLastUpdated(latestUpdatedAt);
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _accountsCountDisplay = _placeholder;
      _documentsCountDisplay = _placeholder;
      _lastUpdatedDisplay = _placeholder;
    });
  }
}

  /// Today / Yesterday / dd/mm/yyyy / Never — compared in local time,
  /// using only Dart's built-in `DateTime` (no `intl` package).
  String _formatLastUpdated(DateTime? dateTime) {
  if (dateTime == null) return 'Never';

  final localDateTime = dateTime.toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
  );

  final differenceInDays = today.difference(date).inDays;

  final hour = localDateTime.hour == 0
      ? 12
      : localDateTime.hour > 12
          ? localDateTime.hour - 12
          : localDateTime.hour;

  final minute = localDateTime.minute.toString().padLeft(2, '0');
  final period = localDateTime.hour >= 12 ? 'PM' : 'AM';

  final time = '$hour:$minute $period';

  if (differenceInDays == 0) {
    return 'Today, $time';
  }

  final day = localDateTime.day.toString().padLeft(2, '0');
  final month = localDateTime.month.toString().padLeft(2, '0');

  return '$day/$month/${localDateTime.year}, $time';
}

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
  final stats = [
    _StatItem(
      icon: Icons.account_balance_wallet_rounded,
      value: _accountsCountDisplay,
      label: 'Accounts',
    ),
    _StatItem(
      icon: Icons.description_rounded,
      value: _documentsCountDisplay,
      label: 'Documents',
    ),
    _StatItem(
      icon: Icons.cloud_done_rounded,
      value: _lastUpdatedDisplay,
      label: 'Last Updated',
    ),
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: stats[0].icon,
                    value: stats[0].value,
                    label: stats[0].label,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: stats[1].icon,
                    value: stats[1].value,
                    label: stats[1].label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: StatCard(
                icon: stats[2].icon,
                value: stats[2].value,
                label: stats[2].label,
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i != 0) const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: stats[i].icon,
                value: stats[i].value,
                label: stats[i].label,
              ),
            ),
          ],
        ],
      );
    },
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
          onTap: () => _openEntryList(context, category.label),
        );
      },
    );
  }

  Widget _buildFab(BuildContext context) {
    // Colors intentionally omitted — inherited from
    // AppTheme.lightTheme.floatingActionButtonTheme.
    return FloatingActionButton(
      onPressed: () => _openUniversalEntry(context),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _openEntryList(BuildContext context, String category) async {
    await AppRouter.openEntryList(context, category);
    if (!mounted) return;
    _loadDashboardData();
  }

  Future<void> _openUniversalEntry(BuildContext context) async {
    await AppRouter.openUniversalEntry(context);
    if (!mounted) return;
    _loadDashboardData();
  }
}

/// Internal display model for a single statistic entry.
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
