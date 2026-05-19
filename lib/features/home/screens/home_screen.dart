import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receptappen/shared/widgets/app_bottom_nav_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/recipe.dart';
import '../providers/recipes_provider.dart';
import '../widgets/recipe_card_large.dart';
import '../widgets/recipe_card_small.dart';
import '../widgets/category_chips.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  int _navIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecipes = ref.watch(recipesProvider);
    final filtered = ref.watch(filteredRecipesProvider);
    final recent = ref.watch(recentRecipesProvider);
    final favorites = ref.watch(favoriteRecipesProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    final isSearching = query.isNotEmpty;
    final isFiltered = selectedCat != RecipeCategory.all || isSearching;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-recipe'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.myRecipes,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.recipesCount(allRecipes.length),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // ── Category chips ────────────────────────────────
            const SliverToBoxAdapter(child: CategoryChips()),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Content ───────────────────────────────────────
            if (isFiltered)
              _FilteredContent(recipes: filtered)
            else ...[
              if (recent.isNotEmpty)
                _RecipesSection(
                  title: AppStrings.recentlyAdded,
                  child: _LargeCardList(recipes: recent),
                ),
              if (favorites.isNotEmpty)
                _RecipesSection(
                  title: AppStrings.favoritesTitle,
                  child: _SmallCardGrid(recipes: favorites),
                ),
              if (allRecipes.isEmpty)
                const SliverToBoxAdapter(child: _EmptyState()),
            ],

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _RecipesSection extends StatelessWidget {
  const _RecipesSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _LargeCardList extends StatelessWidget {
  const _LargeCardList({required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: recipes
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecipeCardLarge(recipe: r),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SmallCardGrid extends StatelessWidget {
  const _SmallCardGrid({required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: recipes.length,
        itemBuilder: (_, i) => RecipeCardSmall(recipe: recipes[i]),
      ),
    );
  }
}

class _FilteredContent extends StatelessWidget {
  const _FilteredContent({required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptySearch());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => RecipeCardSmall(recipe: recipes[i]),
          childCount: recipes.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          const SizedBox(height: 46),
          Text(
            AppStrings.emptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.emptySubtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Text(
          AppStrings.emptySearch,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
