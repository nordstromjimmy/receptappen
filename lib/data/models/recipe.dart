import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

// ── Category enum ──────────────────────────────────────────────────────────

enum RecipeCategory {
  all(AppStrings.catAll, Icons.restaurant_outlined, AppColors.surface),
  vardagsmat(
    AppStrings.catEveryday,
    Icons.dinner_dining_outlined,
    AppColors.imgEveryday,
  ),
  bakning(
    AppStrings.catBaking,
    Icons.bakery_dining_outlined,
    AppColors.imgBaking,
  ),
  vegetariskt(
    AppStrings.catVegetarian,
    Icons.eco_outlined,
    AppColors.imgVegetarian,
  ),
  soppa(AppStrings.catSoup, Icons.ramen_dining_outlined, AppColors.imgSoup),
  dessert(AppStrings.catDessert, Icons.cake_outlined, AppColors.imgDessert),
  frukost(
    AppStrings.catBreakfast,
    Icons.free_breakfast_outlined,
    AppColors.imgBreakfast,
  );

  const RecipeCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

// ── Recipe model ───────────────────────────────────────────────────────────

class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? sourceUrl;
  final String? sourceName;
  final RecipeCategory category;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final bool isFavorite;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sourceUrl,
    this.sourceName,
    this.category = RecipeCategory.vardagsmat,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings = 4,
    this.ingredients = const [],
    this.instructions = const [],
    this.isFavorite = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // ── Computed ────────────────────────────────────────────

  int? get totalTimeMinutes {
    if (prepTimeMinutes == null && cookTimeMinutes == null) return null;
    return (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
  }

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get hasSource => sourceUrl != null && sourceUrl!.isNotEmpty;

  // ── CopyWith ────────────────────────────────────────────

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? sourceUrl,
    String? sourceName,
    RecipeCategory? category,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    List<String>? ingredients,
    List<String>? instructions,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      category: category ?? this.category,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── JSON ────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'sourceUrl': sourceUrl,
    'sourceName': sourceName,
    'category': category.name,
    'prepTimeMinutes': prepTimeMinutes,
    'cookTimeMinutes': cookTimeMinutes,
    'servings': servings,
    'ingredients': ingredients,
    'instructions': instructions,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    imageUrl: json['imageUrl'] as String?,
    sourceUrl: json['sourceUrl'] as String?,
    sourceName: json['sourceName'] as String?,
    category: RecipeCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => RecipeCategory.vardagsmat,
    ),
    prepTimeMinutes: json['prepTimeMinutes'] as int?,
    cookTimeMinutes: json['cookTimeMinutes'] as int?,
    servings: json['servings'] as int? ?? 4,
    ingredients: List<String>.from(json['ingredients'] as List? ?? []),
    instructions: List<String>.from(json['instructions'] as List? ?? []),
    isFavorite: json['isFavorite'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Recipe && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
