import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/recipe.dart';
import '../../home/providers/recipes_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  // Track checked ingredients for shopping-list feel
  final _checkedIngredients = <int>{};

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(recipeByIdProvider(widget.recipeId));

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recept hittades inte')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(recipe: recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title & favorite ──────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FavoriteButton(recipe: recipe),
                    ],
                  ),

                  if (recipe.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      recipe.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Meta chips ────────────────────────────
                  _MetaChips(recipe: recipe),

                  // ── Source link ───────────────────────────
                  if (recipe.hasSource) ...[
                    const SizedBox(height: 12),
                    _SourceLink(recipe: recipe),
                  ],

                  const SizedBox(height: 24),

                  // ── Ingredients ───────────────────────────
                  if (recipe.ingredients.isNotEmpty) ...[
                    _SectionTitle(AppStrings.ingredients),
                    const SizedBox(height: 10),
                    ...recipe.ingredients.asMap().entries.map(
                      (e) => _IngredientRow(
                        index: e.key,
                        text: e.value,
                        isChecked: _checkedIngredients.contains(e.key),
                        onToggle: () => setState(() {
                          if (_checkedIngredients.contains(e.key)) {
                            _checkedIngredients.remove(e.key);
                          } else {
                            _checkedIngredients.add(e.key);
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Instructions ──────────────────────────
                  if (recipe.instructions.isNotEmpty) ...[
                    _SectionTitle(AppStrings.instructions),
                    const SizedBox(height: 10),
                    ...recipe.instructions.asMap().entries.map(
                      (e) => _InstructionRow(step: e.key + 1, text: e.value),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Delete ────────────────────────────────
                  _DeleteButton(recipe: recipe),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero AppBar ────────────────────────────────────────────────────────────

class _HeroAppBar extends ConsumerWidget {
  const _HeroAppBar({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      //backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 18),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_outlined, size: 18),
          ),
          onPressed: () =>
              context.push('/add-recipe', extra: {'recipe': recipe}),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: recipe.hasImage
            ? CachedNetworkImage(
                imageUrl: recipe.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _HeroPlaceholder(recipe: recipe),
              )
            : _HeroPlaceholder(recipe: recipe),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: recipe.category.color,
      child: Center(
        child: Text(
          recipe.category.emoji,
          style: const TextStyle(fontSize: 72),
        ),
      ),
    );
  }
}

// ── Meta chips ─────────────────────────────────────────────────────────────

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(icon: Icons.label_outline, label: recipe.category.label),
        if (recipe.totalTimeMinutes != null)
          _MetaChip(
            icon: Icons.schedule_outlined,
            label: '${recipe.totalTimeMinutes} min',
          ),
        _MetaChip(
          icon: Icons.people_outline,
          label: '${recipe.servings} portioner',
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Source link ────────────────────────────────────────────────────────────

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(recipe.sourceUrl!);
        if (uri != null) await launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              recipe.sourceName ?? AppStrings.openSource,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 12, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── Ingredient row (checkable) ─────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.index,
    required this.text,
    required this.isChecked,
    required this.onToggle,
  });
  final int index;
  final String text;
  final bool isChecked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.textMuted,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isChecked
                      ? AppColors.textMuted
                      : AppColors.textSecondary,
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Instruction row ────────────────────────────────────────────────────────

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.step, required this.text});
  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Favorite button ────────────────────────────────────────────────────────

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(recipesProvider.notifier).toggleFavorite(recipe.id),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(recipe.isFavorite),
          color: recipe.isFavorite
              ? AppColors.primary
              : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}

// ── Delete button ──────────────────────────────────────────────────────────

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => _confirmDelete(context, ref),
      icon: const Icon(Icons.delete_outline, size: 18),
      label: const Text(AppStrings.deleteRecipe),
      style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteMsg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(recipesProvider.notifier).delete(recipe.id);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.deletedOk)));
      }
    }
  }
}
