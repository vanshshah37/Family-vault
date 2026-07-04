import 'package:flutter/material.dart';

import 'category_selection_screen.dart';

/// Universal Entry landing screen — the entry point of the guided
/// Universal Entry wizard, reached by tapping the Dashboard's FAB.
///
/// Phase 04 scope only: navigation framework, no forms, no persistence.
/// Tapping "Continue" pushes [CategorySelectionScreen], the next step in
/// the wizard.
class UniversalEntryScreen extends StatelessWidget {
  const UniversalEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Universal Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Add New Entry',
                style: textTheme.titleMedium?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Let's get started. We'll guide you through a few quick steps.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategorySelectionScreen(),
                    ),
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
