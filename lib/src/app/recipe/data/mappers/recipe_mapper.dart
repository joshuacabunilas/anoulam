import '../../domain/entities/recipe_entities.dart';
import '../model/generate_recipes_response_model.dart';

extension GenerateRecipesMappers on GenerateRecipesResponseModel {
  /// [requestUri] is the URL the response came from; relative image paths
  /// are resolved against it.
  List<RecipeEntities> toRecipeEntitiesList({required Uri requestUri}) {
    return recipes
        .map(
          (recipe) =>
              recipe.withImageUrlResolvedAgainst(requestUri).toRecipeEntities(),
        )
        .toList();
  }
}

extension RecipeMappers on RecipeModel {
  RecipeEntities toRecipeEntities() {
    return RecipeEntities(
      id: id,
      name: name,
      description: description,
      cookingTimeMinutes: cookingTimeMinutes,
      servings: servings,
      difficulty: RecipeDifficulty.values.firstWhere(
        (d) => d.name == difficulty,
        orElse: () => RecipeDifficulty.medium,
      ),
      usedIngredients: usedIngredients,
      missingIngredients: missingIngredients,
      steps: steps,
      category: RecipeCategory.values.firstWhere(
        (c) => c.name == category,
        orElse: () => RecipeCategory.meat,
      ),
      imageUrl: imageUrl,
      imageCredit: imageCredit,
    );
  }
}
