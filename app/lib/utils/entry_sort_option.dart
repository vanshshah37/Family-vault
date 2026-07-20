import '../models/entry.dart';

/// Phase 12 — the four sort modes, plus the comparator that applies
/// them. Operates entirely on an already-loaded `List<Entry>` (same
/// in-memory approach Search already uses since Phase 09) — no
/// repository changes needed.
enum EntrySortOption {
  recentlyUpdated,
  recentlyCreated,
  alphabeticalAZ,
  alphabeticalZA;

  String get label {
    switch (this) {
      case EntrySortOption.recentlyUpdated:
        return 'Recently Updated';
      case EntrySortOption.recentlyCreated:
        return 'Recently Created';
      case EntrySortOption.alphabeticalAZ:
        return 'Alphabetical (A–Z)';
      case EntrySortOption.alphabeticalZA:
        return 'Alphabetical (Z–A)';
    }
  }

  /// Persisted as a plain string key (see `SortPreferenceStore`) rather
  /// than the enum's ordinal index, so a future reordering of this enum
  /// can't silently corrupt a previously-saved preference.
  String get storageKey => name;

  static EntrySortOption fromStorageKey(String? key) {
    return EntrySortOption.values.firstWhere(
      (option) => option.storageKey == key,
      orElse: () => EntrySortOption.recentlyUpdated,
    );
  }
}

abstract class EntrySorter {
  /// Returns a new, sorted list — never mutates [entries] in place, so
  /// callers holding onto the original (e.g. an unsorted "load" result)
  /// aren't affected.
  static List<Entry> sort(List<Entry> entries, EntrySortOption option) {
    final sorted = List<Entry>.of(entries);

    final int Function(Entry, Entry) comparator = switch (option) {
      EntrySortOption.recentlyUpdated =>
        (a, b) => b.updatedAt.compareTo(a.updatedAt),
      EntrySortOption.recentlyCreated =>
        (a, b) => b.createdAt.compareTo(a.createdAt),
      EntrySortOption.alphabeticalAZ => (a, b) =>
          _primaryLabel(a).toLowerCase().compareTo(_primaryLabel(b).toLowerCase()),
      EntrySortOption.alphabeticalZA => (a, b) =>
          _primaryLabel(b).toLowerCase().compareTo(_primaryLabel(a).toLowerCase()),
    };

    sorted.sort(comparator);
    return sorted;
  }

  /// Alphabetical sort needs *some* single display string per entry.
  /// [Entry] has no dedicated "title" field (Phase 06's generic
  /// category+JSON-data shape), so this falls back to [Entry.owner] —
  /// the one human-entered, always-present string on every entry
  /// regardless of category. Both Search and Entry List already treat
  /// `owner` as the entry's primary subtitle/label today, so this stays
  /// consistent with existing display conventions rather than inventing
  /// a new one.
  static String _primaryLabel(Entry entry) => entry.owner;
}
