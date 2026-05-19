import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:receptappen/data/models/recipe.dart';

import 'core/theme/app_theme.dart';
import 'features/add_recipe/screens/add_recipe_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/recipe_detail/screens/recipe_detail_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/recipe/:id',
      builder: (_, state) =>
          RecipeDetailScreen(recipeId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/add-recipe',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AddRecipeScreen(
          prefillUrl: extra?['url'] as String?,
          existingRecipe: extra?['recipe'] as Recipe?,
        );
      },
    ),
  ],
);

class MatreceptApp extends StatelessWidget {
  const MatreceptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Matrecept',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
