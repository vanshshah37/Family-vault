/// Phase 13 — the five Auto-Lock Timer options from Security Settings.
///
/// Mirrors Phase 12's `EntrySortOption` pattern exactly: a stable string
/// storage key (not an ordinal index, which would silently corrupt a
/// saved preference if this enum is ever reordered).
enum AutoLockDuration {
  immediately,
  oneMinute,
  threeMinutes,
  fiveMinutes,
  never;

  String get label {
    switch (this) {
      case AutoLockDuration.immediately:
        return 'Immediately';
      case AutoLockDuration.oneMinute:
        return '1 Minute';
      case AutoLockDuration.threeMinutes:
        return '3 Minutes';
      case AutoLockDuration.fiveMinutes:
        return '5 Minutes';
      case AutoLockDuration.never:
        return 'Never';
    }
  }

  String get storageKey => name;

  static AutoLockDuration fromStorageKey(String? key) {
    return AutoLockDuration.values.firstWhere(
      (option) => option.storageKey == key,
      orElse: () => AutoLockDuration.threeMinutes, // spec default
    );
  }

  /// The foreground-inactivity timer length. `null` exclusively means
  /// [never] — per the approved decision, "Never" disables *every*
  /// automatic lock trigger (foreground inactivity AND backgrounding),
  /// not just this timer. [VaultLockController] treats a `null` here as
  /// "arm no timer, and do not lock on backgrounding either."
  ///
  /// [immediately] maps to [Duration.zero] deliberately — the strictest
  /// possible reading of "Immediately", consistent with how it also
  /// governs backgrounding (see [VaultLockController]).
  Duration? get duration {
    switch (this) {
      case AutoLockDuration.immediately:
        return Duration.zero;
      case AutoLockDuration.oneMinute:
        return const Duration(minutes: 1);
      case AutoLockDuration.threeMinutes:
        return const Duration(minutes: 3);
      case AutoLockDuration.fiveMinutes:
        return const Duration(minutes: 5);
      case AutoLockDuration.never:
        return null;
    }
  }
}
