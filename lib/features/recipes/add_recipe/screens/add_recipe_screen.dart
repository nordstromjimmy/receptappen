import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/recipe.dart';
import '../../../home/providers/recipes_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key, this.prefillUrl, this.existingRecipe});

  final String? prefillUrl;
  final Recipe? existingRecipe;

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _cookCtrl;
  late final TextEditingController _servingsCtrl;

  RecipeCategory _category = RecipeCategory.vardagsmat;
  final List<TextEditingController> _ingredientCtrls = [];
  final List<TextEditingController> _instructionCtrls = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _urlCtrl = TextEditingController(
      text: r?.sourceUrl ?? widget.prefillUrl ?? '',
    );
    _sourceCtrl = TextEditingController(text: r?.sourceName ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _imageCtrl = TextEditingController(text: r?.imageUrl ?? '');
    _prepCtrl = TextEditingController(
      text: r?.prepTimeMinutes?.toString() ?? '',
    );
    _cookCtrl = TextEditingController(
      text: r?.cookTimeMinutes?.toString() ?? '',
    );
    _servingsCtrl = TextEditingController(text: r?.servings.toString() ?? '4');
    _category = r?.category ?? RecipeCategory.vardagsmat;

    // Seed ingredient / instruction controllers
    final ingredients = r?.ingredients ?? [];
    final instructions = r?.instructions ?? [];
    for (final i in ingredients) {
      _ingredientCtrls.add(TextEditingController(text: i));
    }
    for (final s in instructions) {
      _instructionCtrls.add(TextEditingController(text: s));
    }
    // Always at least one empty row
    if (_ingredientCtrls.isEmpty) _addIngredient();
    if (_instructionCtrls.isEmpty) _addInstruction();
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _urlCtrl,
      _sourceCtrl,
      _descCtrl,
      _imageCtrl,
      _prepCtrl,
      _cookCtrl,
      _servingsCtrl,
      ..._ingredientCtrls,
      ..._instructionCtrls,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredient() =>
      setState(() => _ingredientCtrls.add(TextEditingController()));

  void _removeIngredient(int i) {
    setState(() {
      _ingredientCtrls[i].dispose();
      _ingredientCtrls.removeAt(i);
    });
  }

  void _addInstruction() =>
      setState(() => _instructionCtrls.add(TextEditingController()));

  void _removeInstruction(int i) {
    setState(() {
      _instructionCtrls[i].dispose();
      _instructionCtrls.removeAt(i);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final ingredients = _ingredientCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final instructions = _instructionCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.existingRecipe?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      sourceUrl: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
      sourceName: _sourceCtrl.text.trim().isEmpty
          ? null
          : _sourceCtrl.text.trim(),
      category: _category,
      prepTimeMinutes: int.tryParse(_prepCtrl.text),
      cookTimeMinutes: int.tryParse(_cookCtrl.text),
      servings: int.tryParse(_servingsCtrl.text) ?? 4,
      ingredients: ingredients,
      instructions: instructions,
      isFavorite: widget.existingRecipe?.isFavorite ?? false,
      createdAt: widget.existingRecipe?.createdAt,
    );

    try {
      if (widget.existingRecipe != null) {
        await ref.read(recipesProvider.notifier).update(recipe);
      } else {
        await ref.read(recipesProvider.notifier).add(recipe);
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.savedOk)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.errorSaving)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingRecipe != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? AppStrings.editRecipeTitle : AppStrings.addRecipeTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      AppStrings.saveRecipe,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // ── Basic info ──────────────────────────────────
            _SectionHeader(AppStrings.sectionBasic),
            const SizedBox(height: 12),

            _FormField(
              controller: _nameCtrl,
              label: AppStrings.fieldName,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Namn krävs' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _urlCtrl,
              label: AppStrings.fieldUrl,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _sourceCtrl,
              label: AppStrings.fieldSource,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _descCtrl,
              label: AppStrings.fieldDesc,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _imageCtrl,
              label: AppStrings.fieldImageUrl,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 10),

            // ── Category dropdown ───────────────────────────
            DropdownButtonFormField<RecipeCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldCategory,
              ),
              items: RecipeCategory.values
                  .where((c) => c != RecipeCategory.all)
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(
                            c.icon,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(c.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),

            // ── Timing & servings ───────────────────────────
            const SizedBox(height: 24),
            _SectionHeader(AppStrings.sectionTiming),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: _prepCtrl,
                    label: AppStrings.fieldPrepTime,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FormField(
                    controller: _cookCtrl,
                    label: AppStrings.fieldCookTime,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 140,
              child: _FormField(
                controller: _servingsCtrl,
                label: AppStrings.fieldServings,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),

            // ── Ingredients ─────────────────────────────────
            const SizedBox(height: 24),
            _SectionHeader(AppStrings.sectionIngredients),
            const SizedBox(height: 12),

            ..._ingredientCtrls.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: e.value,
                        decoration: InputDecoration(
                          hintText: AppStrings.fieldIngredient,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (_ingredientCtrls.length > 1)
                      IconButton(
                        onPressed: () => _removeIngredient(e.key),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.addIngredient),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),

            // ── Instructions ────────────────────────────────
            const SizedBox(height: 24),
            _SectionHeader(AppStrings.sectionInstructions),
            const SizedBox(height: 12),

            ..._instructionCtrls.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number circle
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 10, right: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: e.value,
                        decoration: InputDecoration(
                          hintText: '${AppStrings.fieldStep} ${e.key + 1}',
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (_instructionCtrls.length > 1)
                      IconButton(
                        onPressed: () => _removeInstruction(e.key),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            TextButton.icon(
              onPressed: _addInstruction,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.addStep),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }
}
