import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/src/app/recipe/domain/repository/recipe_repository.dart';
import 'package:mobile/src/app/recipe/domain/usecase/recipe_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late _MockRecipeRepository repository;
  late RecipeUseCase useCase;

  setUp(() {
    repository = _MockRecipeRepository();
    useCase = RecipeUseCase(repository);
  });

  test(
    'normalizes and de-duplicates ingredients before calling repo',
    () async {
      when(
        () => repository.generateRecipes(any()),
      ).thenAnswer((_) async => const Right([]));

      await useCase.generateRecipes([' Egg', 'egg ', '', 'Rice']);

      verify(() => repository.generateRecipes(['egg', 'rice'])).called(1);
    },
  );

  test('returns a RecipeFailure without calling repo when empty', () async {
    final result = await useCase.generateRecipes(['  ']);

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), isA<RecipeFailure>());
    verifyNever(() => repository.generateRecipes(any()));
  });
}
