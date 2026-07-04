import 'package:flutter/material.dart';

/// Confirmation — final step of the Universal Entry wizard.
///
/// Displays the category and owner selected in the previous two steps,
/// both received via constructor parameters. No data is saved here —
/// Phase 04 builds the navigation framework only. The user returns to the
/// Dashboard by backing out through the wizard (automatic Back button /
/// device back), consistent with using only Navigator.push() and
/// Navigator.pop() — no popUntil / pushReplacement / pushAndRemoveUntil.
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.category,
    required this.owner,
  });

  final String category;
  final String owner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Selections Noted',
                style: textTheme.titleMedium?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Category: $category',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Owner: $owner',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'This information has not been saved yet.',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
