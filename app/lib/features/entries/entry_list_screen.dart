import 'package:flutter/material.dart';

import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/entry_sort_option.dart';
import '../../utils/sort_preference_store.dart';
import 'entry_details_screen.dart';

/// Entry List — shows every saved [Entry] belonging to one [category].
///
/// Reached from the Dashboard's category cards (Phase 07 retargets them
/// here, replacing the Phase 03 placeholder screens). Loads every entry
/// via [EntryRepository.loadEntries] and filters client-side by
/// [category] — the Repository intentionally exposes no
/// category-specific query method (Phase 07 authorizes only
/// `updateEntry`/`deleteEntry` as additions), so filtering happens here.
///
/// A [StatefulWidget] so the list can reload whenever control returns
/// from [EntryDetailsScreen] (after an edit or delete), matching the
/// "refresh after CRUD operations" requirement without any provider or
/// global state.
///
/// Phase 12 adds sorting (persisted locally via [SortPreferenceStore],
/// shared with [SearchScreen]'s identical sort control — one global
/// "last selected sort option", per the Phase 12 spec's singular
/// wording) and light card/empty-state polish. No repository changes
/// were needed for this: sorting is applied in memory to the same
/// already-loaded, already-category-filtered list, the same way
/// filtering itself already worked.
class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key, required this.category});

  final String category;

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  late Future<List<Entry>> _entriesFuture;
  EntrySortOption _sortOption = EntrySortOption.recentlyUpdated;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _initialize();
  }

  Future<List<Entry>> _initialize() async {
    _sortOption = await SortPreferenceStore.load();
    return _loadEntries();
  }

  Future<List<Entry>> _loadEntries() async {
    final all = await EntryRepository().loadEntries();
    final filtered =
        all.where((entry) => entry.category == widget.category).toList();
    return EntrySorter.sort(filtered, _sortOption);
  }

  void _refresh() {
    setState(() {
      _entriesFuture = _loadEntries();
    });
  }

  Future<void> _onSortSelected(EntrySortOption option) async {
    _sortOption = option;
    await SortPreferenceStore.save(option);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [_buildSortButton(context)],
      ),
      body: FutureBuilder<List<Entry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _EntryTile(
                entry: entries[index],
                onTap: () => _openDetails(entries[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<EntrySortOption>(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort',
      initialValue: _sortOption,
      onSelected: _onSortSelected,
      itemBuilder: (context) => [
        for (final option in EntrySortOption.values)
          PopupMenuItem(value: option, child: Text(option.label)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first entry from the Dashboard\'s + button.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(Entry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryDetailsScreen(entry: entry)),
    );
    // Reload on return regardless of what happened (edit, delete, or
    // nothing) — simplest correct refresh without providers/global state.
    if (mounted) _refresh();
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap});

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final createdDate = entry.createdAt.split('T').first;

    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.description_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.category,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.owner, style: textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(createdDate, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
