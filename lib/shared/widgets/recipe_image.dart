import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/recipe.dart';

/// Displays a recipe image — local file takes priority over network URL.
/// Falls back to a category-colored placeholder with an icon.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 48,
  });

  final Recipe recipe;
  final BoxFit fit;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    // ── Local image ──────────────────────────────────────
    if (recipe.hasLocalImage) {
      return Image.file(
        File(recipe.localImagePath!),
        fit: fit,
        errorBuilder: (_, __, ___) =>
            _Placeholder(recipe: recipe, iconSize: placeholderIconSize),
      );
    }

    // ── Network image ────────────────────────────────────
    if (recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: fit,
        placeholder: (_, __) =>
            _Placeholder(recipe: recipe, iconSize: placeholderIconSize),
        errorWidget: (_, url, error) {
          debugPrint('Image failed: $url — $error');
          return _Placeholder(recipe: recipe, iconSize: placeholderIconSize);
        },
      );
    }

    // ── Placeholder ──────────────────────────────────────
    return _Placeholder(recipe: recipe, iconSize: placeholderIconSize);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.recipe, required this.iconSize});
  final Recipe recipe;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: recipe.category.color,
      child: Center(
        child: Icon(recipe.category.icon, size: iconSize, color: Colors.white),
      ),
    );
  }
}
