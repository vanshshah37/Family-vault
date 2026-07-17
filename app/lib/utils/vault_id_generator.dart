import 'dart:math';

/// Generates candidate human-readable Vault IDs in the `FV-XXXX-XXXX`
/// format approved in the Phase 11 design (item 21).
///
/// Character set is Crockford-style — excludes `0`/`O` and `1`/`I`/`L` —
/// so a family member reading an ID aloud, or typing it from memory,
/// can't confuse visually similar characters. 8 symbols from this
/// 32-character alphabet give roughly 40 bits of entropy: far more than
/// enough to make random guessing impractical at this app's scale, while
/// staying short enough to type by hand.
///
/// This class only ever produces a *candidate* ID — it does not check
/// uniqueness itself. Uniqueness is enforced where it actually matters:
/// atomically, inside [VaultRepository.createVault]'s Firestore
/// transaction (existence-check + write in one atomic unit), which is
/// what actually prevents two users from ever committing the same
/// Vault ID. This generator is retried with a fresh candidate whenever
/// that transaction reports a collision.
abstract class VaultIdGenerator {
  static const String _alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const int _groupLength = 4;
  static final Random _random = Random.secure();

  static String generate() {
    final group1 = _randomGroup();
    final group2 = _randomGroup();
    return 'FV-$group1-$group2';
  }

  static String _randomGroup() {
    return List.generate(
      _groupLength,
      (_) => _alphabet[_random.nextInt(_alphabet.length)],
    ).join();
  }

  /// Normalizes user-typed input before a lookup (Phase 11 design item
  /// 34): trims whitespace, uppercases, and strips any spaces the user
  /// may have typed around the hyphenated groups.
  static String normalize(String rawInput) {
    return rawInput.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }
}
