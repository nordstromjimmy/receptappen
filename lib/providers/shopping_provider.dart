import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receptappen/data/models/shopping_item.dart';

import '../../../data/repositories/recipe_repository.dart';

const _kShoppingKey = 'shopping_v1';

class ShoppingNotifier extends Notifier<List<ShoppingItem>> {
  @override
  List<ShoppingItem> build() => _load();

  // ── Read ──────────────────────────────────────────────────

  List<ShoppingItem> _load() {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_kShoppingKey);
    if (raw == null) return [];
    final list = json.decode(raw) as List;
    return list
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final encoded = json.encode(state.map((i) => i.toJson()).toList());
    await prefs.setString(_kShoppingKey, encoded);
  }

  Future<void> addItem(
    String name, {
    String? recipeId,
    String? recipeName,
  }) async {
    state = [
      ...state,
      ShoppingItem(
        name: name,
        sourceRecipeId: recipeId,
        sourceRecipeName: recipeName,
      ),
    ];
    await _persist();
  }

  Future<void> addFromRecipe({
    required String recipeId,
    required String recipeName,
    required List<String> ingredients,
  }) async {
    final items = ingredients
        .map(
          (ing) => ShoppingItem(
            name: ing,
            sourceRecipeId: recipeId,
            sourceRecipeName: recipeName,
          ),
        )
        .toList();

    final existingNames = state
        .where((i) => i.sourceRecipeId == recipeId)
        .map((i) => i.name)
        .toSet();

    final newItems = items
        .where((i) => !existingNames.contains(i.name))
        .toList();
    state = [...state, ...newItems];
    await _persist();
  }

  Future<void> toggle(String id) async {
    state = state
        .map((i) => i.id == id ? i.copyWith(isChecked: !i.isChecked) : i)
        .toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((i) => i.id != id).toList();
    await _persist();
  }

  Future<void> clearChecked() async {
    state = state.where((i) => !i.isChecked).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = [];
    await _persist();
  }
}

final shoppingProvider = NotifierProvider<ShoppingNotifier, List<ShoppingItem>>(
  ShoppingNotifier.new,
);

// Grouped: { recipeName/Övrigt → [items] }
final groupedShoppingProvider = Provider<Map<String, List<ShoppingItem>>>((
  ref,
) {
  final items = ref.watch(shoppingProvider);
  final map = <String, List<ShoppingItem>>{};
  for (final item in items) {
    final key = item.sourceRecipeName ?? 'Övrigt';
    map.putIfAbsent(key, () => []).add(item);
  }
  return map;
});

final checkedCountProvider = Provider<int>(
  (ref) => ref.watch(shoppingProvider).where((i) => i.isChecked).length,
);
