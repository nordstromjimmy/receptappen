import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

const _kRecipesKey = 'recipes_v1';

// ── Providers ──────────────────────────────────────────────────────────────

/// Overridden in main.dart with the real SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(sharedPreferencesProvider));
});

// ── Repository ─────────────────────────────────────────────────────────────

class RecipeRepository {
  RecipeRepository(this._prefs);

  final SharedPreferences _prefs;

  // ── Read ──────────────────────────────────────────────────

  List<Recipe> getAll() {
    final raw = _prefs.getString(_kRecipesKey);
    if (raw == null) return [];
    final list = json.decode(raw) as List;
    return list.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

  Recipe? getById(String id) => getAll().where((r) => r.id == id).firstOrNull;

  // ── Write ─────────────────────────────────────────────────

  Future<void> save(Recipe recipe) async {
    final recipes = getAll();
    final idx = recipes.indexWhere((r) => r.id == recipe.id);
    if (idx == -1) {
      recipes.insert(0, recipe); // newest first
    } else {
      recipes[idx] = recipe;
    }
    await _persist(recipes);
  }

  Future<void> delete(String id) async {
    final recipes = getAll()..removeWhere((r) => r.id == id);
    await _persist(recipes);
  }

  Future<void> toggleFavorite(String id) async {
    final recipes = getAll();
    final idx = recipes.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    recipes[idx] = recipes[idx].copyWith(isFavorite: !recipes[idx].isFavorite);
    await _persist(recipes);
  }

  // ── Internal ──────────────────────────────────────────────

  Future<void> _persist(List<Recipe> recipes) async {
    final encoded = json.encode(recipes.map((r) => r.toJson()).toList());
    await _prefs.setString(_kRecipesKey, encoded);
  }
}
