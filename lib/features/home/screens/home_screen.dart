import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receptappen/features/profile/screens/profile_screen.dart';
import 'package:receptappen/screens/shopping_screen.dart';
import 'package:receptappen/shared/widgets/app_bottom_nav_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/recipe.dart';
import '../providers/recipes_provider.dart';
import '../widgets/recipe_card_large.dart';
import '../widgets/recipe_card_small.dart';
import '../widgets/category_chips.dart';
import '../../favorites/screens/favorites_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push('/add-recipe'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _HomeTab(),
          FavoritesScreen(),
          ShoppingScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ── Home tab ───────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  final _searchController = TextEditingController();

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
    final query = ref.watch(searchQueryProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    final isFiltered = selectedCat != RecipeCategory.all || query.isNotEmpty;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.myRecipes,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
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
          ),

          // ── Search bar ──────────────────────────────────
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

          // ── Category chips ───────────────────────────────
          const SliverToBoxAdapter(child: CategoryChips()),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Explore banner ───────────────────────────────────────────────────
          if (!isFiltered && allRecipes.length >= 2)
            const SliverToBoxAdapter(child: _ExploreBanner()),
          // ── Content ─────────────────────────────────────
          if (isFiltered)
            _FilteredContent(recipes: filtered)
          else ...[
            if (recent.isNotEmpty)
              _RecipesSection(
                title: AppStrings.recentlyAdded,
                child: _LargeCardList(recipes: recent),
              ),

            if (allRecipes.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState()),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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

// ── Explore banner ─────────────────────────────────────────────────────────

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/explore'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Utforska dina recept',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bläddra bland dina recept och hitta inspiration',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
