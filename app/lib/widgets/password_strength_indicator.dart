import 'package:flutter/material.dart';

import '../utils/password_strength.dart';

/// Phase 12 — live strength meter shown beneath a password field.
///
/// Pure display widget: renders whatever [password] currently is. The
/// caller (see [PasswordFormField]) re-renders this on every keystroke
/// by rebuilding with the controller's latest text — no internal state
/// of its own.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = PasswordStrengthCalculator.evaluate(password);
    final (Color color, String label, double progress) = switch (strength) {
      PasswordStrength.weak => (Colors.red, 'Weak', 1 / 3),
      PasswordStrength.medium => (Colors.amber.shade700, 'Medium', 2 / 3),
      PasswordStrength.strong => (Colors.green.shade600, 'Strong', 1.0),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Padding(
        key: ValueKey(strength),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
