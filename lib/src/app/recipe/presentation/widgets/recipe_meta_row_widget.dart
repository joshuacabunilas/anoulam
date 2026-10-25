import 'package:flutter/material.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/common/theme/app_theme.dart';

import '../../domain/entities/recipe_entities.dart';

extension RecipeDifficultyLabel on RecipeDifficulty {
  String get label => switch (this) {
    RecipeDifficulty.easy => StringHelper.easy,
    RecipeDifficulty.medium => StringHelper.medium,
    RecipeDifficulty.hard => StringHelper.hard,
  };
}

extension RecipeCategoryLabel on RecipeCategory {
  String get label => switch (this) {
    RecipeCategory.rice => StringHelper.categoryRice,
    RecipeCategory.noodles => StringHelper.categoryNoodles,
    RecipeCategory.soup => StringHelper.categorySoup,
    RecipeCategory.egg => StringHelper.categoryEgg,
    RecipeCategory.meat => StringHelper.categoryMeat,
    RecipeCategory.seafood => StringHelper.categorySeafood,
    RecipeCategory.vegetable => StringHelper.categoryVegetable,
    RecipeCategory.bread => StringHelper.categoryBread,
    RecipeCategory.dessert => StringHelper.categoryDessert,
    RecipeCategory.drink => StringHelper.categoryDrink,
    RecipeCategory.snack => StringHelper.categorySnack,
  };
}

/// Cooking time, servings and difficulty in one row.
class RecipeMetaRowWidget extends StatelessWidget {
  const RecipeMetaRowWidget({super.key, required this.recipe, this.color});

  final RecipeEntities recipe;

  /// Text and icon colour; muted ink by default. Set it when the row sits
  /// on a colour field.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.xs,
      children: [
        _Meta(
          icon: Icons.schedule,
          text: StringHelper.minutes(recipe.cookingTimeMinutes),
          color: color,
        ),
        _Meta(
          icon: Icons.people_outline,
          text: StringHelper.servings(recipe.servings),
          color: color,
        ),
        _Meta(
          icon: Icons.signal_cellular_alt,
          text: recipe.difficulty.label,
          color: color,
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decorative: the text next to it carries the meaning.
        ExcludeSemantics(child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
