import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe.dart';
import '../providers/recipes_provider.dart';

class RecipeCardLarge extends ConsumerWidget {
  const RecipeCardLarge({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / placeholder ──────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: recipe.hasImage
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _PlaceholderImage(recipe: recipe),
                        errorWidget: (_, __, ___) =>
                            _PlaceholderImage(recipe: recipe),
                      )
                    : _PlaceholderImage(recipe: recipe),
              ),
            ),

            // ── Info ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(recipe: recipe, ref: ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder image ──────────────────────────────────────────────────────

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: recipe.category.color),
        Center(
          child: Text(
            recipe.category.emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _CategoryBadge(category: recipe.category),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final RecipeCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        category.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Meta row (time · servings · source · heart) ────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.recipe, required this.ref});
  final Recipe recipe;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: AppColors.textSecondary);
    const iconSize = 13.0;

    return Row(
      children: [
        // Time
        if (recipe.totalTimeMinutes != null) ...[
          const Icon(
            Icons.schedule_outlined,
            size: iconSize,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text('${recipe.totalTimeMinutes} min', style: style),
          const SizedBox(width: 10),
        ],

        // Servings
        const Icon(
          Icons.people_outline,
          size: iconSize,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 3),
        Text('${recipe.servings} port.', style: style),

        // Source badge
        if (recipe.sourceName != null) ...[
          const SizedBox(width: 8),
          _SourceBadge(name: recipe.sourceName!),
        ],

        const Spacer(),

        // Favorite heart
        GestureDetector(
          onTap: () =>
              ref.read(recipesProvider.notifier).toggleFavorite(recipe.id),
          child: Icon(
            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: recipe.isFavorite
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 10, color: AppColors.background),
          const SizedBox(width: 3),
          Text(
            name,
            style: const TextStyle(fontSize: 10, color: AppColors.background),
          ),
        ],
      ),
    );
  }
}
