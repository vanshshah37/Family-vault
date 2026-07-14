import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../models/entry.dart';
import '../../repositories/entry_repository.dart';
import '../entries/entry_details_screen.dart';

/// Universal search + category filtering over locally-loaded [Entry] rows.
///
/// Phase 09 — replaces the Phase 03 placeholder. Loads entries only through
/// [EntryRepository.loadEntries]; all filtering happens in memory so typing
/// and chip selection never touch SQLite. The database is only re-read when
/// the screen first opens and after returning from [EntryDetailsScreen], per
/// the approved Phase 09 decisions.
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
    _loadEntries();
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
  String? _firstPreviewValue(Entry entry) {
    final values = _safeDecodeData(entry.data);
    for (final value in values.values) {
      if (value.trim().isNotEmpty) return value;
    }
    return null;
  }

  bool _matchesQuery(Entry entry, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return true;

    if (entry.category.toLowerCase().contains(normalizedQuery)) return true;
    if (entry.owner.toLowerCase().contains(normalizedQuery)) return true;

    final values = _safeDecodeData(entry.data);
    for (final fieldEntry in values.entries) {
      if (fieldEntry.key.toLowerCase().contains(normalizedQuery)) return true;
      if (fieldEntry.value.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }

  List<Entry> get _filteredEntries {
    final normalizedQuery = _searchController.text.trim().toLowerCase();
    return _allEntries.where((entry) {
      final categoryMatches = _selectedCategory == _kAllCategories ||
          entry.category == _selectedCategory;
      if (!categoryMatches) return false;
      return _matchesQuery(entry, normalizedQuery);
    }).toList();
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
      appBar: AppBar(title: const Text('Search')),
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
      return const Center(child: Text('Could not load saved entries'));
    }

    if (_allEntries.isEmpty) {
      return const Center(child: Text('No saved entries yet'));
    }

    final query = _searchController.text.trim();
    if (query.isEmpty && _selectedCategory == _kAllCategories) {
      return const Center(child: Text('Search your saved information'));
    }

    final filtered = _filteredEntries;
    if (filtered.isEmpty) {
      return const Center(child: Text('No matching entries found'));
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
}
