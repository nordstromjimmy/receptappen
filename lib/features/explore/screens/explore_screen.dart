import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe.dart';
import '../../home/providers/recipes_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  List<Recipe> _shuffled = [];
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shuffled.isEmpty) {
      final recipes = ref.read(recipesProvider);
      _shuffle(recipes);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shuffle(List<Recipe> recipes) {
    _shuffled = [...recipes]..shuffle(Random());
  }

  void _next() {
    if (_currentIndex < _shuffled.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);

    if (recipes.isEmpty) {
      return const _EmptyExplore();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background blurred color from current card ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _BackgroundGlow(
              key: ValueKey(_currentIndex),
              color: _shuffled[_currentIndex].category.color,
            ),
          ),

          // ── Safe area content ────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Progress indicator
                      Text(
                        '${_currentIndex + 1} / ${_shuffled.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      // Shuffle again button
                      GestureDetector(
                        onTap: () => setState(() {
                          _shuffle(ref.read(recipesProvider));
                          _pageController.jumpToPage(0);
                          _currentIndex = 0;
                        }),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shuffle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Title ────────────────────────────────────
                Text(
                  'Utforska dina recept',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Card stack ───────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemCount: _shuffled.length,
                    itemBuilder: (_, i) {
                      return _RecipeSwipeCard(
                        recipe: _shuffled[i],
                        isActive: i == _currentIndex,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Nav arrows + dot indicator ───────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous
                    _NavButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: _previous,
                      enabled: _currentIndex > 0,
                    ),

                    const SizedBox(width: 24),

                    // Dots (max 5 visible)
                    _DotIndicator(
                      count: min(_shuffled.length, 5),
                      current: min(_currentIndex, 4),
                    ),

                    const SizedBox(width: 24),

                    // Next
                    _NavButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: _next,
                      enabled: _currentIndex < _shuffled.length - 1,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background glow ────────────────────────────────────────────────────────

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.2,
          colors: [color.withValues(alpha: 0.4), Colors.black],
        ),
      ),
    );
  }
}

// ── Recipe swipe card ──────────────────────────────────────────────────────

class _RecipeSwipeCard extends StatelessWidget {
  const _RecipeSwipeCard({required this.recipe, required this.isActive});

  final Recipe recipe;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () => context.push('/recipe/${recipe.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area ─────────────────────────────
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image or placeholder
                      recipe.hasImage
                          ? CachedNetworkImage(
                              imageUrl: recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _CardPlaceholder(recipe: recipe),
                            )
                          : _CardPlaceholder(recipe: recipe),

                      // Bottom gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Category badge
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                recipe.category.icon,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                recipe.category.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tap hint
                      Positioned(
                        bottom: 14,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Visa recept',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info area ──────────────────────────────
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (recipe.description != null)
                          Text(
                            recipe.description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        // Meta row
                        Row(
                          children: [
                            if (recipe.totalTimeMinutes != null) ...[
                              const Icon(
                                Icons.schedule_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.totalTimeMinutes} min',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                            const Icon(
                              Icons.people_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.servings} port.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            if (recipe.isFavorite)
                              const Icon(
                                Icons.favorite,
                                size: 18,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ],
                    ),
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

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: recipe.category.color,
      child: Center(
        child: Icon(recipe.category.icon, size: 80, color: Colors.white),
      ),
    );
  }
}

// ── Navigation button ──────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ── Dot indicator ──────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyExplore extends StatelessWidget {
  const _EmptyExplore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Inga recept att utforska ännu',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
