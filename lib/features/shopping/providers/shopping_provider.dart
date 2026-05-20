import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receptappen/data/models/shopping_item.dart';

import '../../../main.dart';

// ── Provider ───────────────────────────────────────────────────────────────

final shoppingProvider = NotifierProvider<ShoppingNotifier, List<ShoppingItem>>(
  ShoppingNotifier.new,
);

// Grouped: { recipeName / 'Övrigt' → [items] }
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

// ── Notifier ───────────────────────────────────────────────────────────────

class ShoppingNotifier extends Notifier<List<ShoppingItem>> {
  Box<String> get _box => Hive.box<String>(kShoppingBox);

  @override
  List<ShoppingItem> build() => _load();

  // ── Read ──────────────────────────────────────────────────

  List<ShoppingItem> _load() {
    return _box.values
        .map(
          (raw) =>
              ShoppingItem.fromJson(json.decode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────

  Future<void> _persist() async {
    await _box.clear();
    for (final item in state) {
      await _box.put(item.id, json.encode(item.toJson()));
    }
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
    final existingNames = state
        .where((i) => i.sourceRecipeId == recipeId)
        .map((i) => i.name)
        .toSet();

    final newItems = ingredients
        .where((ing) => !existingNames.contains(ing))
        .map(
          (ing) => ShoppingItem(
            name: ing,
            sourceRecipeId: recipeId,
            sourceRecipeName: recipeName,
          ),
        )
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
    await _box.clear();
  }
}
