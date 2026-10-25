import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';

import '../entities/recipe_entities.dart';
import '../entities/recipe_filter_entities.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<RecipeEntities>>> generateRecipes(
    List<String> ingredients,
  );

  /// The ingredient list saved on the device (empty if none).
  Future<Either<Failure, List<String>>> getSavedIngredients();

  Future<Either<Failure, Unit>> saveIngredients(List<String> ingredients);

  /// The result filters saved on the device. The dish type is not saved.
  Future<Either<Failure, RecipeFilterEntities>> getSavedFilter();

  Future<Either<Failure, Unit>> saveFilter(RecipeFilterEntities filter);
}
