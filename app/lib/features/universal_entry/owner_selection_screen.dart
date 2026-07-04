import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'confirmation_screen.dart';

/// Owner Selection — third step of the Universal Entry wizard.
///
/// Receives the previously selected [category] via a constructor
/// parameter (no providers/models/global state). Displays two placeholder
/// owner options; tapping one pushes [ConfirmationScreen] with both
/// selections. No reusable "Owner Card" widget is created here — that
/// component is reserved for a future phase per DESIGN_SYSTEM.md, so this
/// screen builds its two tappable tiles via a private helper method to
/// avoid duplicating the tile layout inline twice.
class OwnerSelectionScreen extends StatelessWidget {
  const OwnerSelectionScreen({super.key, required this.category});

  final String category;

  static const List<String> _owners = ['Primary Owner', 'Secondary Owner'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Owner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _owners.length; i++) ...[
              if (i != 0) const SizedBox(height: 12),
              _buildOwnerTile(context, _owners[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerTile(BuildContext context, String owner) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmationScreen(
                category: category,
                owner: owner,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  owner,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
