import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe.dart';

class RecipeCardSmall extends StatelessWidget {
  const RecipeCardSmall({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: recipe.hasImage
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _SmallPlaceholder(recipe: recipe),
                        errorWidget: (_, __, ___) =>
                            _SmallPlaceholder(recipe: recipe),
                      )
                    : _SmallPlaceholder(recipe: recipe),
              ),
            ),

            // ── Info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recipe.totalTimeMinutes != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.totalTimeMinutes} min',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPlaceholder extends StatelessWidget {
  const _SmallPlaceholder({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: recipe.category.color,
      child: Center(
        child: Text(
          recipe.category.emoji,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
