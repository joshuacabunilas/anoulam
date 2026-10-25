import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/data/mappers/recipe_mapper.dart';
import 'package:mobile/src/app/recipe/data/model/generate_recipes_response_model.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';

RecipeModel _model({String category = 'soup', String difficulty = 'easy'}) =>
    RecipeModel(
      id: 'x',
      name: 'X',
      description: 'd',
      cookingTimeMinutes: 5,
      servings: 1,
      difficulty: difficulty,
      usedIngredients: const [],
      missingIngredients: const [],
      steps: const ['s'],
      category: category,
      imageUrl: 'http://host/x.jpg',
      imageCredit: 'Photo: A (CC0)',
    );

void main() {
  test('maps category and image fields', () {
    final recipe = _model().toRecipeEntities();

    expect(recipe.category, RecipeCategory.soup);
    expect(recipe.imageUrl, 'http://host/x.jpg');
    expect(recipe.imageCredit, 'Photo: A (CC0)');
  });

  test('unknown category or difficulty falls back instead of crashing', () {
    final recipe = _model(
      category: 'spaceship',
      difficulty: '??',
    ).toRecipeEntities();

    expect(recipe.category, RecipeCategory.meat);
    expect(recipe.difficulty, RecipeDifficulty.medium);
  });
}
