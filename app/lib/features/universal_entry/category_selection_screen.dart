import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../widgets/category_card.dart';
import 'owner_selection_screen.dart';

/// Category Selection — second step of the Universal Entry wizard.
///
/// Reuses the existing [CategoryCard] widget and the shared [kCategories]
/// list (same source used by the Dashboard). Tapping a category pushes
/// [OwnerSelectionScreen], passing the chosen category via a constructor
/// parameter — no providers, models, or global state.
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: kCategories.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final category = kCategories[index];
            return CategoryCard(
              icon: category.icon,
              label: category.label,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerSelectionScreen(
                      category: category.label,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
