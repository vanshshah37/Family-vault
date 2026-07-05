import 'package:flutter/material.dart';

import '../../core/models/entry_value.dart';

/// Review Entry — final step of the Universal Entry wizard.
///
/// Displays the selected category, selected owner, and every entered
/// value (via [values], received in the exact order they were entered).
/// Nothing is saved here — Phase 05 builds the UI framework only.
///
/// "Finish" is the one approved exception to the push/pop-only guideline:
/// it uses [Navigator.popUntil] to return directly to the Dashboard,
/// since repeatedly popping through 4 screens behind a single "Finish"
/// tap would be an unusual UX for what is meant to read as one decisive
/// action completing the wizard.
class ReviewEntryScreen extends StatelessWidget {
  const ReviewEntryScreen({
    super.key,
    required this.category,
    required this.owner,
    required this.values,
  });

  final String category;
  final String owner;
  final List<EntryValue> values;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Category', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(category, style: textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('Owner', style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(owner, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text('Entered Values', style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final entry in values) ...[
                    Text(entry.field, style: textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      entry.value.isEmpty ? '—' : entry.value,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'This information has not been saved yet.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
