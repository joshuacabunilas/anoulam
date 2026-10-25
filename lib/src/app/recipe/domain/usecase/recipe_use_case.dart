import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/error/failures.dart';

import '../entities/recipe_entities.dart';
import '../entities/recipe_filter_entities.dart';
import '../repository/recipe_repository.dart';

/// All recipe operations. Add one method per operation.
@injectable
class RecipeUseCase {
  const RecipeUseCase(this._recipeRepository);

  final RecipeRepository _recipeRepository;

  /// Trims, lowercases and de-duplicates [ingredients] before asking the
  /// repository. Fails without a request when nothing is left.
  Future<Either<Failure, List<RecipeEntities>>> generateRecipes(
    List<String> ingredients,
  ) async {
    final cleaned = ingredients
        .map((i) => i.trim().toLowerCase())
        .where((i) => i.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) {
      return const Left(RecipeFailure('Add at least one ingredient.'));
    }
    return _recipeRepository.generateRecipes(cleaned);
  }

  Future<Either<Failure, List<String>>> getSavedIngredients() =>
      _recipeRepository.getSavedIngredients();

  Future<Either<Failure, Unit>> saveIngredients(List<String> ingredients) =>
      _recipeRepository.saveIngredients(ingredients);

  Future<Either<Failure, RecipeFilterEntities>> getSavedFilter() =>
      _recipeRepository.getSavedFilter();

  Future<Either<Failure, Unit>> saveFilter(RecipeFilterEntities filter) =>
      _recipeRepository.saveFilter(filter);
}
