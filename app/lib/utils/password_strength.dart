/// Phase 12 — pure password-strength scoring, no widget/UI code here so
/// it stays independently usable (and testable) from whichever screen
/// ends up hosting the live indicator.
enum PasswordStrength { weak, medium, strong }

abstract class PasswordStrengthCalculator {
  /// Scores [password] against six factors (length, uppercase,
  /// lowercase, digits, symbols, absence of repeated characters) and
  /// buckets the result into [PasswordStrength.weak]/`.medium`/`.strong`.
  ///
  /// Each satisfied factor contributes one point (max 6); the repeated-
  /// character factor is satisfied when no single character appears 3+
  /// times in a row (e.g. "aaa"), which is treated as a weakening
  /// pattern rather than a strengthening one.
  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    var score = 0;

    if (password.length >= 12) {
      score += 2;
    } else if (password.length >= 8) {
      score += 1;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/;~`]').hasMatch(password)) {
      score += 1;
    }

    // Penalize any character repeated 3+ times in a row (e.g. "aaa",
    // "111") — a classic weak-password pattern that should pull the
    // score down rather than let raw length alone read as "strong".
    if (RegExp(r'(.)\1\1').hasMatch(password)) {
      score -= 2;
    }

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}
