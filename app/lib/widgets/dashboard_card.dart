import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Generic reusable card container used throughout the Dashboard.
///
/// Provides the standard card surface (approved card color, radius, soft
/// elevation, comfortable padding) around an arbitrary [child]. In Phase 02
/// it is used only for the Welcome section, but it carries no
/// Welcome-specific logic so it can be reused in later phases.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
