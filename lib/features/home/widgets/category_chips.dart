import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/recipe.dart';
import '../providers/recipes_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  // Skip RecipeCategory.all — handled via the "Alla" chip
  static const _categories = RecipeCategory.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          if (cat == RecipeCategory.all) {
            return _Chip(
              label: cat.label,
              isSelected: selected == cat,
              onTap: () =>
                  ref.read(selectedCategoryProvider.notifier).state = cat,
            );
          }
          return _Chip(
            label: cat.label,
            isSelected: selected == cat,
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = cat,
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : Theme.of(context).chipTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
