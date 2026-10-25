import 'package:equatable/equatable.dart';

enum RecipeDifficulty { easy, medium, hard }

/// Kind of dish. Picks the illustration shown when there is no photo.
enum RecipeCategory {
  rice,
  noodles,
  soup,
  egg,
  meat,
  seafood,
  vegetable,
  bread,
  dessert,
  drink,
  snack,
}

class RecipeEntities extends Equatable {
  const RecipeEntities({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.usedIngredients,
    required this.missingIngredients,
    required this.steps,
    this.category = RecipeCategory.meat,
    this.imageUrl,
    this.imageCredit,
  });

  final String id;
  final String name;
  final String description;
  final int cookingTimeMinutes;
  final int servings;
  final RecipeDifficulty difficulty;

  /// Ingredients from the user's list that this recipe uses.
  final List<String> usedIngredients;

  /// Ingredients the recipe needs that the user didn't list.
  final List<String> missingIngredients;
  final List<String> steps;
  final RecipeCategory category;

  /// Absolute photo URL, or null to show the category illustration.
  final String? imageUrl;

  /// Attribution to show with the photo, e.g. "Photo: Jane Doe (CC BY 2.0)".
  final String? imageCredit;

  bool get canCookNow => missingIngredients.isEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    cookingTimeMinutes,
    servings,
    difficulty,
    usedIngredients,
    missingIngredients,
    steps,
    category,
    imageUrl,
    imageCredit,
  ];
}
