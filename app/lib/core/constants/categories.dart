import 'package:flutter/material.dart';

/// A single category definition (icon + label).
///
/// Purely a data holder — no business logic. Shared between [HomeScreen]'s
/// Dashboard categories section and [CategorySelectionScreen]'s Universal
/// Entry wizard step, so the placeholder category list is defined once.
class CategoryItem {
  const CategoryItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

/// Shared placeholder category list (Phase 02–04).
///
/// Single source of truth to avoid duplicating this list across the
/// Dashboard and the Universal Entry Category Selection screen.
const List<CategoryItem> kCategories = [
  CategoryItem(icon: Icons.person_rounded, label: 'Personal'),
  CategoryItem(icon: Icons.business_rounded, label: 'Corporate'),
  CategoryItem(icon: Icons.show_chart_rounded, label: 'Share Market'),
  CategoryItem(icon: Icons.groups_rounded, label: 'Joint'),
  CategoryItem(icon: Icons.folder_rounded, label: 'Documents'),
  CategoryItem(icon: Icons.info_rounded, label: 'Information'),
];
