import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/src/app/recipe/domain/entities/ingredient_entities.dart';
import 'package:mobile/src/app/recipe/domain/usecase/recipe_use_case.dart';
import 'package:mobile/src/app/recipe/presentation/bloc/ingredients/ingredients_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecipeUseCase extends Mock implements RecipeUseCase {}

void main() {
  late _MockRecipeUseCase useCase;

  setUp(() {
    useCase = _MockRecipeUseCase();
    when(
      () => useCase.saveIngredients(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => useCase.getSavedIngredients(),
    ).thenAnswer((_) async => const Right(<String>[]));
  });

  IngredientsBloc build() => IngredientsBloc(useCase);

  blocTest<IngredientsBloc, IngredientsState>(
    'loads the saved list on start',
    setUp: () => when(
      () => useCase.getSavedIngredients(),
    ).thenAnswer((_) async => const Right(['Egg', 'Rice'])),
    build: build,
    act: (bloc) => bloc.add(const IngredientsStarted()),
    expect: () => const [
      IngredientsState(ingredients: ['Egg', 'Rice']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'starts empty if the saved list cannot be loaded',
    setUp: () => when(
      () => useCase.getSavedIngredients(),
    ).thenAnswer((_) async => const Left(CacheFailure('broken'))),
    build: build,
    act: (bloc) => bloc.add(const IngredientsStarted()),
    expect: () => const <IngredientsState>[],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'adds trimmed ingredients and saves after each change',
    build: build,
    act: (bloc) => bloc
      ..add(const IngredientAdded('  Egg  '))
      ..add(const IngredientAdded('soy   sauce')),
    expect: () => const [
      IngredientsState(ingredients: ['Egg']),
      IngredientsState(ingredients: ['Egg', 'soy sauce']),
    ],
    verify: (_) {
      verify(() => useCase.saveIngredients(['Egg'])).called(1);
      verify(() => useCase.saveIngredients(['Egg', 'soy sauce'])).called(1);
    },
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'ignores blank and duplicate ingredients (case-insensitive)',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Egg']),
    act: (bloc) => bloc
      ..add(const IngredientAdded('   '))
      ..add(const IngredientAdded('egg')),
    expect: () => const <IngredientsState>[],
    verify: (_) => verifyNever(() => useCase.saveIngredients(any())),
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'removes an ingredient and saves',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Egg', 'Rice']),
    act: (bloc) => bloc.add(const IngredientRemoved('Egg')),
    expect: () => const [
      IngredientsState(ingredients: ['Rice']),
    ],
    verify: (_) => verify(() => useCase.saveIngredients(['Rice'])).called(1),
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'clears all ingredients and saves the empty list',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Egg', 'Rice']),
    act: (bloc) => bloc.add(const IngredientsCleared()),
    expect: () => const [IngredientsState()],
    verify: (_) => verify(() => useCase.saveIngredients([])).called(1),
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'a failed save keeps the new list on screen',
    setUp: () => when(
      () => useCase.saveIngredients(any()),
    ).thenAnswer((_) async => const Left(CacheFailure('disk full'))),
    build: build,
    act: (bloc) => bloc.add(const IngredientAdded('Egg')),
    expect: () => const [
      IngredientsState(ingredients: ['Egg']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'treats singular and plural as the same ingredient',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Egg', 'Tomato']),
    act: (bloc) => bloc
      ..add(const IngredientAdded('Eggs'))
      ..add(const IngredientAdded('tomatoes'))
      ..add(const IngredientRemoved('EGGS')),
    expect: () => const [
      IngredientsState(ingredients: ['Tomato']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'removes duplicates left in a saved list by older versions',
    setUp: () => when(
      () => useCase.getSavedIngredients(),
    ).thenAnswer((_) async => const Right(['Egg', 'Eggs', 'Rice'])),
    build: build,
    act: (bloc) => bloc.add(const IngredientsStarted()),
    expect: () => const [
      IngredientsState(ingredients: ['Egg', 'Rice']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'undo puts a removed ingredient back at its old position',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Egg', 'Milk']),
    act: (bloc) => bloc.add(const IngredientsRestored(['Rice'], index: 1)),
    expect: () => const [
      IngredientsState(ingredients: ['Egg', 'Rice', 'Milk']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'undo keeps anything added since and skips what is already back',
    build: build,
    seed: () => const IngredientsState(ingredients: ['Garlic', 'Eggs']),
    act: (bloc) => bloc.add(const IngredientsRestored(['Egg', 'Rice'])),
    expect: () => const [
      IngredientsState(ingredients: ['Rice', 'Garlic', 'Eggs']),
    ],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'refuses more than the backend limit',
    build: build,
    seed: () => IngredientsState(
      ingredients: [
        for (var i = 0; i < IngredientEntities.maxCount; i++) 'item $i',
      ],
    ),
    act: (bloc) => bloc.add(const IngredientAdded('One too many')),
    expect: () => const <IngredientsState>[],
  );

  blocTest<IngredientsBloc, IngredientsState>(
    'refuses names longer than the backend limit',
    build: build,
    act: (bloc) =>
        bloc.add(IngredientAdded('x' * (IngredientEntities.maxLength + 1))),
    expect: () => const <IngredientsState>[],
  );
}
