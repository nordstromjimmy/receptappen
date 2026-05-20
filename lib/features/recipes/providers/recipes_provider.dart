import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/recipe.dart';
import '../../../data/repositories/recipe_repository.dart';

// ── Search & filter state ─────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<RecipeCategory>(
  (_) => RecipeCategory.all,
);

final searchQueryProvider = StateProvider<String>((_) => '');

// ── Recipes notifier ──────────────────────────────────────────────────────

class RecipesNotifier extends Notifier<List<Recipe>> {
  RecipeRepository get _repo => ref.read(recipeRepositoryProvider);

  @override
  List<Recipe> build() => _repo.getAll();

  Future<void> add(Recipe recipe) async {
    await _repo.save(recipe);
    state = _repo.getAll();
  }

  Future<void> update(Recipe recipe) async {
    await _repo.save(recipe);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }

  Future<void> toggleFavorite(String id) async {
    await _repo.toggleFavorite(id);
    state = _repo.getAll();
  }
}

final recipesProvider = NotifierProvider<RecipesNotifier, List<Recipe>>(
  RecipesNotifier.new,
);

// ── Derived providers ─────────────────────────────────────────────────────

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final all = ref.watch(recipesProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  var result = all;

  if (category != RecipeCategory.all) {
    result = result.where((r) => r.category == category).toList();
  }

  if (query.isNotEmpty) {
    result = result
        .where(
          (r) =>
              r.name.toLowerCase().contains(query) ||
              (r.description?.toLowerCase().contains(query) ?? false) ||
              (r.sourceName?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  return result;
});

final recentRecipesProvider = Provider<List<Recipe>>((ref) {
  final sorted = [...ref.watch(recipesProvider)]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted.take(5).toList();
});

final favoriteRecipesProvider = Provider<List<Recipe>>(
  (ref) => ref.watch(recipesProvider).where((r) => r.isFavorite).toList(),
);

final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  return ref.watch(recipesProvider).where((r) => r.id == id).firstOrNull;
});
