import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import '../../utils/credential_fields.dart';
import '../../utils/entry_sort_option.dart';
import '../../utils/sort_preference_store.dart';
import '../entries/entry_details_screen.dart';

/// Universal search + category filtering over locally-loaded [Entry] rows.
///
/// Phase 09 — replaces the Phase 03 placeholder. Loads entries only through
/// [EntryRepository.loadEntries]; all filtering happens in memory so typing
/// and chip selection never touch SQLite. The database is only re-read when
/// the screen first opens and after returning from [EntryDetailsScreen], per
/// the approved Phase 09 decisions.
///
/// Phase 12 adds sorting (persisted locally via [SortPreferenceStore]) and
/// tightens matching/preview so a password value can never be the thing
/// that makes an entry match a search, or appear as its preview text —
/// both now explicitly skip whichever field [CredentialFields.passwordField]
/// identifies for that entry's category, plus the reserved internal
/// metadata keys ([CredentialFields.reservedKeys]).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/// Content-state priority, evaluated top to bottom by [_buildContent].
enum _LoadStatus { loading, loaded, error }

class _SearchScreenState extends State<SearchScreen> {
  /// Local sentinel for "no category filter applied" — not one of the six
  /// real categories, so it is defined here rather than in categories.dart.
  static const String _kAllCategories = 'All';

  final TextEditingController _searchController = TextEditingController();

  _LoadStatus _status = _LoadStatus.loading;
  List<Entry> _allEntries = const [];
  String _selectedCategory = _kAllCategories;
  EntrySortOption _sortOption = EntrySortOption.recentlyUpdated;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    _loadEntries();
    _loadSortPreference();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Triggers a synchronous, in-memory re-filter on every keystroke.
  /// No database access happens here.
  void _onQueryChanged() {
    setState(() {});
  }

  /// The only place SQLite is read from. Called on initial open and again
  /// after returning from [EntryDetailsScreen] — never on keystroke or
  /// category-chip taps.
  Future<void> _loadEntries() async {
    setState(() => _status = _LoadStatus.loading);
    try {
      final entries = await EntryRepository().loadEntries();
      if (!mounted) return;
      setState(() {
        _allEntries = entries;
        _status = _LoadStatus.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _LoadStatus.error);
    }
  }

  Future<void> _loadSortPreference() async {
    final option = await SortPreferenceStore.load();
    if (!mounted) return;
    setState(() => _sortOption = option);
  }

  Future<void> _onSortSelected(EntrySortOption option) async {
    setState(() => _sortOption = option);
    await SortPreferenceStore.save(option);
  }

  /// Defensive JSON decode — malformed [Entry.data] must never crash the
  /// screen. A malformed entry is treated as having no dynamic fields;
  /// its category/owner still participate in matching.
  Map<String, String> _safeDecodeData(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  /// First non-empty decoded dynamic value, used as the one-line preview
  /// on a search result card. Field label ordering (kFormDefinitions) is
  /// not needed for this — map insertion order from the decoded JSON is
  /// sufficient.
  ///
  /// Phase 12: skips the entry's password field (if any) and every
  /// reserved internal metadata key, so a password value or the
  /// `updatedBy`/previous-password bookkeeping fields can never end up
  /// as the visible preview text.
  String? _firstPreviewValue(Entry entry) {
    final passwordLabel = CredentialFields.passwordField(entry.category)?.label;
    final values = _safeDecodeData(entry.data);
    for (final fieldEntry in values.entries) {
      if (fieldEntry.key == passwordLabel) continue;
      if (CredentialFields.reservedKeys.contains(fieldEntry.key)) continue;
      if (fieldEntry.value.trim().isNotEmpty) return fieldEntry.value;
    }
    return null;
  }

  /// Phase 12: excludes the category's password field and every reserved
  /// metadata key from matching, so typing part of a password (or the
  /// internal `updatedBy`/previous-password values) can never surface an
  /// entry via search — everything else about matching is unchanged.
  bool _matchesQuery(Entry entry, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;

    if (entry.category.toLowerCase().contains(normalizedQuery)) return true;
    if (entry.owner.toLowerCase().contains(normalizedQuery)) return true;

    final passwordLabel = CredentialFields.passwordField(entry.category)?.label;
    final values = _safeDecodeData(entry.data);
    for (final fieldEntry in values.entries) {
      if (fieldEntry.key == passwordLabel) continue;
      if (CredentialFields.reservedKeys.contains(fieldEntry.key)) continue;

      if (fieldEntry.key.toLowerCase().contains(normalizedQuery)) return true;
      if (fieldEntry.value.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }

  List<Entry> get _filteredEntries {
    final normalizedQuery = _searchController.text.trim().toLowerCase();
    final matches = _allEntries.where((entry) {
      final categoryMatches = _selectedCategory == _kAllCategories ||
          entry.category == _selectedCategory;
      if (!categoryMatches) return false;
      return _matchesQuery(entry, normalizedQuery);
    }).toList();

    return EntrySorter.sort(matches, _sortOption);
  }

  Future<void> _openEntry(Entry entry) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => EntryDetailsScreen(entry: entry)),
  );

  if (!mounted) return;
  await _loadEntries();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [_buildSortButton(context)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchField(context),
              const SizedBox(height: 12),
              _buildCategoryChips(context),
              const SizedBox(height: 16),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
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

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search your entries',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final options = [
      _kAllCategories,
      ...kCategories.map((category) => category.label),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option),
              selected: _selectedCategory == option,
              onSelected: (_) {
                setState(() => _selectedCategory = option);
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_status == _LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_status == _LoadStatus.error) {
      return _buildEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load saved entries',
      );
    }

    if (_allEntries.isEmpty) {
      return _buildEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'No entries yet',
        subtitle: 'Add your first entry from the Dashboard\'s + button.',
      );
    }

    final query = _searchController.text.trim();
    if (query.isEmpty && _selectedCategory == _kAllCategories) {
      return _buildEmptyState(
        icon: Icons.search_rounded,
        title: 'Search your saved information',
      );
    }

    final filtered = _filteredEntries;
    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching entries found',
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final preview = _firstPreviewValue(entry);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(entry.category),
            subtitle: Text(
              preview == null ? entry.owner : '${entry.owner} • $preview',
            ),
            onTap: () => _openEntry(entry),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
