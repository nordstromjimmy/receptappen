import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receptappen/data/models/shopping_item.dart';
import 'package:receptappen/features/home/providers/recipes_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/recipe.dart';

import '../providers/shopping_provider.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedShoppingProvider);
    final checkedCount = ref.watch(checkedCountProvider);
    final totalCount = ref.watch(shoppingProvider).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inköpslista',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalCount == 0
                              ? ''
                              : '$checkedCount av $totalCount ingredienser',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalCount > 0) _ClearButton(checkedCount: checkedCount),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────────
            if (totalCount > 0) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProgressBar(checked: checkedCount, total: totalCount),
              ),
            ],

            const SizedBox(height: 8),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: totalCount == 0
                  ? const _EmptyShopping()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: grouped.entries.map((entry) {
                        return _ShoppingGroup(
                          title: entry.key,
                          items: entry.value,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _ShoppingFab(),
    );
  }
}

// ── Progress bar ───────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.checked, required this.total});
  final int checked;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: checked / total,
        minHeight: 5,
        backgroundColor: AppColors.surface,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }
}

// ── Clear button ───────────────────────────────────────────────────────────

class _ClearButton extends ConsumerWidget {
  const _ClearButton({required this.checkedCount});
  final int checkedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (checkedCount == 0) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () => ref.read(shoppingProvider.notifier).clearChecked(),
      icon: const Icon(Icons.check_circle_outline, size: 16),
      label: const Text('Rensa klara'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Shopping group ─────────────────────────────────────────────────────────

class _ShoppingGroup extends StatelessWidget {
  const _ShoppingGroup({required this.title, required this.items});
  final String title;
  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return _ShoppingRow(item: e.value, isLast: isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Shopping row ───────────────────────────────────────────────────────────

class _ShoppingRow extends ConsumerWidget {
  const _ShoppingRow({required this.item, required this.isLast});
  final ShoppingItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(shoppingProvider.notifier).remove(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
      ),
      child: InkWell(
        onTap: () => ref.read(shoppingProvider.notifier).toggle(item.id),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.isChecked
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: item.isChecked
                        ? AppColors.primary
                        : AppColors.textMuted,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: item.isChecked
                        ? AppColors.textMuted
                        : Theme.of(context).colorScheme.onSurface,
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB with two options ───────────────────────────────────────────────────

class _ShoppingFab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ShoppingFab> createState() => _ShoppingFabState();
}

class _ShoppingFabState extends ConsumerState<_ShoppingFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  void _close() {
    setState(() => _open = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Option: Från recept ──────────────────────────
        ScaleTransition(
          scale: _scale,
          child: _FabOption(
            label: 'Från recept',
            icon: Icons.menu_book_outlined,
            onTap: () {
              _close();
              _showRecipePicker(context);
            },
          ),
        ),

        const SizedBox(height: 8),

        // ── Option: Eget ─────────────────────────────────
        ScaleTransition(
          scale: _scale,
          child: _FabOption(
            label: 'Eget',
            icon: Icons.edit_outlined,
            onTap: () {
              _close();
              _showAddCustom(context);
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Main FAB ─────────────────────────────────────
        FloatingActionButton(
          heroTag: 'shopping_fab',
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Recipe picker bottom sheet ─────────────────────────

  void _showRecipePicker(BuildContext context) {
    final recipes = ref.read(recipesProvider);
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Du har inga recept att lägga till')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipePickerSheet(recipes: recipes),
    );
  }

  // ── Custom item bottom sheet ───────────────────────────

  void _showAddCustom(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lägg till vara',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'T.ex. 2 dl grädde',
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      ref.read(shoppingProvider.notifier).addItem(v.trim());
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isNotEmpty) {
                        ref
                            .read(shoppingProvider.notifier)
                            .addItem(ctrl.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Lägg till'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FAB mini option button ─────────────────────────────────────────────────

class _FabOption extends StatelessWidget {
  const _FabOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Recipe picker sheet ────────────────────────────────────────────────────

class _RecipePickerSheet extends ConsumerStatefulWidget {
  const _RecipePickerSheet({required this.recipes});
  final List<Recipe> recipes;

  @override
  ConsumerState<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends ConsumerState<_RecipePickerSheet> {
  Recipe? _selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Välj recept',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // ── Recipe list ────────────────────────────────
            Expanded(
              child: ListView.separated(
                itemCount: widget.recipes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = widget.recipes[i];
                  final isSelected = _selected?.id == r.id;
                  return InkWell(
                    onTap: () => setState(() {
                      _selected = r;
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Emoji circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: r.category.color.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                r.category.icon,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${r.ingredients.length} ingredienser',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Add button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () {
                        ref
                            .read(shoppingProvider.notifier)
                            .addFromRecipe(
                              recipeId: _selected!.id,
                              recipeName: _selected!.name,
                              ingredients: _selected!.ingredients,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_selected!.ingredients.length} ingredienser tillagda',
                            ),
                          ),
                        );
                      },
                child: Text(
                  _selected == null
                      ? 'Välj ett recept'
                      : 'Lägg till ${_selected!.name}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyShopping extends StatelessWidget {
  const _EmptyShopping();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 68, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Listan är tom',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tryck på + för att lägga till varor eller importera från ett recept',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
