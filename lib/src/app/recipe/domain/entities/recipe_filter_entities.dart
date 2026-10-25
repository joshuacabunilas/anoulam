import 'package:equatable/equatable.dart';

import 'recipe_entities.dart';

/// Filters the user can apply to a list of recipes. All set filters must
/// match (AND). An empty filter keeps every recipe.
class RecipeFilterEntities extends Equatable {
  const RecipeFilterEntities({
    this.readyToCook = false,
    this.quick = false,
    this.easy = false,
    this.vegetarian = false,
    this.category,
  });

  /// "Under 30 min" cutoff, in minutes.
  static const quickMinutes = 30;

  /// Ingredients that make a recipe non-vegetarian.
  static const _nonVegetarian = {
    'chicken',
    'pork',
    'beef',
    'bacon',
    'hotdog',
    'fish',
    'shrimp',
    'salmon',
    'tuna',
    'fish sauce',
    'shrimp paste',
    'liver spread',
    'chicken broth',
  };

  final bool readyToCook;
  final bool quick;
  final bool easy;
  final bool vegetarian;

  /// Only this kind of dish; null for any.
  final RecipeCategory? category;

  /// Names of the switched-on toggles, for saving. The dish type is left out:
  /// it depends on each search's results.
  List<String> get toggleNames => [
    if (readyToCook) 'readyToCook',
    if (quick) 'quick',
    if (easy) 'easy',
    if (vegetarian) 'vegetarian',
  ];

  factory RecipeFilterEntities.fromToggleNames(List<String> names) =>
      RecipeFilterEntities(
        readyToCook: names.contains('readyToCook'),
        quick: names.contains('quick'),
        easy: names.contains('easy'),
        vegetarian: names.contains('vegetarian'),
      );

  bool get isEmpty =>
      !readyToCook && !quick && !easy && !vegetarian && category == null;

  bool matches(RecipeEntities recipe) {
    if (readyToCook && !recipe.canCookNow) return false;
    if (quick && recipe.cookingTimeMinutes > quickMinutes) return false;
    if (easy && recipe.difficulty != RecipeDifficulty.easy) return false;
    if (vegetarian && !isVegetarian(recipe)) return false;
    if (category != null && recipe.category != category) return false;
    return true;
  }

  List<RecipeEntities> apply(List<RecipeEntities> recipes) =>
      recipes.where(matches).toList();

  static bool isVegetarian(RecipeEntities recipe) => [
    ...recipe.usedIngredients,
    ...recipe.missingIngredients,
  ].every((i) => !_nonVegetarian.contains(i.toLowerCase()));

  RecipeFilterEntities copyWith({
    bool? readyToCook,
    bool? quick,
    bool? easy,
    bool? vegetarian,
    RecipeCategory? Function()? category,
  }) {
    return RecipeFilterEntities(
      readyToCook: readyToCook ?? this.readyToCook,
      quick: quick ?? this.quick,
      easy: easy ?? this.easy,
      vegetarian: vegetarian ?? this.vegetarian,
      category: category != null ? category() : this.category,
    );
  }

  @override
  List<Object?> get props => [readyToCook, quick, easy, vegetarian, category];
}
