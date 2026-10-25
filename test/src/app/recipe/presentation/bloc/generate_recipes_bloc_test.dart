import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/domain/usecase/recipe_use_case.dart';
import 'package:mobile/src/app/recipe/presentation/bloc/generate_recipes/generate_recipes_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecipeUseCase extends Mock implements RecipeUseCase {}

void main() {
  late _MockRecipeUseCase useCase;

  const ingredients = ['egg', 'tomato'];
  const recipe = RecipeEntities(
    id: 'tomato-omelette',
    name: 'Tomato Omelette',
    description: 'Fluffy omelette.',
    cookingTimeMinutes: 10,
    servings: 1,
    difficulty: RecipeDifficulty.easy,
    usedIngredients: ['egg', 'tomato'],
    missingIngredients: ['onion'],
    steps: ['Cook it.'],
  );

  setUp(() => useCase = _MockRecipeUseCase());

  test('starts in the initial state', () {
    expect(GenerateRecipesBloc(useCase).state, const GenerateRecipesInitial());
  });

  blocTest<GenerateRecipesBloc, GenerateRecipesState>(
    'emits loading then success when recipes are found',
    setUp: () => when(
      () => useCase.generateRecipes(any()),
    ).thenAnswer((_) async => const Right([recipe])),
    build: () => GenerateRecipesBloc(useCase),
    act: (bloc) => bloc.add(const GenerateRecipesRequested(ingredients)),
    expect: () => const [
      GenerateRecipesLoading(),
      GenerateRecipesSuccess([recipe]),
    ],
    verify: (_) => verify(() => useCase.generateRecipes(ingredients)).called(1),
  );

  blocTest<GenerateRecipesBloc, GenerateRecipesState>(
    'emits loading then failure when the use case fails',
    setUp: () => when(
      () => useCase.generateRecipes(any()),
    ).thenAnswer((_) async => const Left(RecipeFailure('Server down'))),
    build: () => GenerateRecipesBloc(useCase),
    act: (bloc) => bloc.add(const GenerateRecipesRequested(ingredients)),
    expect: () => const [
      GenerateRecipesLoading(),
      GenerateRecipesFailure(RecipeFailure('Server down')),
    ],
  );
}
