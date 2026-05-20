import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../main.dart';
import '../models/recipe.dart';

// ── Provider ───────────────────────────────────────────────────────────────

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(Hive.box<String>(kRecipesBox));
});

// ── Repository ─────────────────────────────────────────────────────────────

class RecipeRepository {
  RecipeRepository(this._box);

  final Box<String> _box;

  // ── Read ──────────────────────────────────────────────────

  List<Recipe> getAll() {
    return _box.values
        .map((raw) => Recipe.fromJson(json.decode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
  }

  Recipe? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return Recipe.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  // ── Write ─────────────────────────────────────────────────

  Future<void> save(Recipe recipe) async {
    await _box.put(recipe.id, json.encode(recipe.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    final recipe = getById(id);
    if (recipe == null) return;
    await save(recipe.copyWith(isFavorite: !recipe.isFavorite));
  }
}
