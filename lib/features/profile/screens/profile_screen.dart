import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe.dart';
import '../../home/providers/recipes_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    final favorites = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Profil',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 24),

            _SectionLabel('Statistik'),
            const SizedBox(height: 10),
            _StatsGrid(recipes: recipes, favorites: favorites),

            const SizedBox(height: 28),

            _SectionLabel('Din data'),
            _SectionDesc(
              'Om du behöver installera om appen eller vill installera appen på en ny enhet kan du exportera din data för att sedan importera filen på din nya enhet så att du inte förlorar dina sparade recept.',
            ),
            const SizedBox(height: 10),
            _DataCard(recipes: recipes),

            const SizedBox(height: 28),

            _SectionLabel('Om appen'),
            const SizedBox(height: 10),
            _AboutCard(),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SectionDesc extends StatelessWidget {
  const _SectionDesc(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w200,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ── Stats grid ─────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.recipes, required this.favorites});
  final List<Recipe> recipes;
  final List<Recipe> favorites;

  RecipeCategory? _topCategory(List<Recipe> recipes) {
    if (recipes.isEmpty) return null;
    final counts = <RecipeCategory, int>{};
    for (final r in recipes) {
      counts[r.category] = (counts[r.category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final top = _topCategory(recipes);
    final totalIngredients = recipes.fold<int>(
      0,
      (sum, r) => sum + r.ingredients.length,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book_outlined,
                value: '${recipes.length}',
                label: 'Recept',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.favorite_outline,
                value: '${favorites.length}',
                label: 'Favoriter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_outlined,
                value: top != null ? top.label : '–',
                label: 'Vanligaste kategorin',
                smallValue: top != null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.shopping_basket_outlined,
                value: '$totalIngredients',
                label: 'Ingredienser totalt',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.smallValue = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 108),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: smallValue ? 16 : 24,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data card ──────────────────────────────────────────────────────────────

class _DataCard extends ConsumerWidget {
  const _DataCard({required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _DataRow(
            icon: Icons.upload_outlined,
            label: 'Exportera recept',
            sublabel: 'Spara alla recept som en JSON-fil',
            iconColor: AppColors.primary,
            isFirst: true,
            onTap: recipes.isEmpty ? null : () => _export(context, recipes),
          ),
          const Divider(height: 1, indent: 52),
          _DataRow(
            icon: Icons.download_outlined,
            label: 'Importera recept',
            sublabel: 'Läs in recept från en JSON-fil',
            iconColor: AppColors.primary,
            isFirst: false,
            isLast: true,
            onTap: () => _import(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, List<Recipe> recipes) async {
    try {
      final jsonList = recipes.map((r) => r.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/matrecept_export.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/json'),
      ], subject: 'Matrecept export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export misslyckades: $e')));
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final list = json.decode(content) as List;
      final recipes = list
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!context.mounted) return;

      final action = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Importera recept'),
          content: Text(
            '${recipes.length} recept hittades. Vill du lägga till dem eller ersätta alla befintliga recept?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Avbryt'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'merge'),
              child: const Text('Lägg till'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'replace'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ersätt'),
            ),
          ],
        ),
      );

      if (action == null || !context.mounted) return;

      final notifier = ref.read(recipesProvider.notifier);

      if (action == 'replace') {
        final existing = ref.read(recipesProvider);
        for (final r in existing) {
          await notifier.delete(r.id);
        }
      }

      for (final r in recipes) {
        await notifier.add(r);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${recipes.length} recept importerade! 🎉')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import misslyckades: $e')));
      }
    }
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.iconColor,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── About card ─────────────────────────────────────────────────────────────

class _AboutCard extends StatefulWidget {
  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Matrecept',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Text(
                _version.isEmpty ? '–' : 'Version $_version',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
