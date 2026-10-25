import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_filter_entities.dart';
import 'package:mobile/src/app/recipe/domain/usecase/recipe_use_case.dart';
import 'package:mobile/src/app/recipe/presentation/bloc/recipe_filter/recipe_filter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecipeUseCase extends Mock implements RecipeUseCase {}

void main() {
  late _MockRecipeUseCase useCase;

  setUpAll(() => registerFallbackValue(const RecipeFilterEntities()));
  setUp(() {
    useCase = _MockRecipeUseCase();
    when(
      () => useCase.saveFilter(any()),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => useCase.getSavedFilter(),
    ).thenAnswer((_) async => const Right(RecipeFilterEntities()));
  });

  blocTest<RecipeFilterBloc, RecipeFilterState>(
    'loads the saved toggles on start',
    setUp: () => when(() => useCase.getSavedFilter()).thenAnswer(
      (_) async => const Right(RecipeFilterEntities(vegetarian: true)),
    ),
    build: () => RecipeFilterBloc(useCase),
    act: (bloc) => bloc.add(const RecipeFilterStarted()),
    expect: () => const [
      RecipeFilterState(filter: RecipeFilterEntities(vegetarian: true)),
    ],
  );

  blocTest<RecipeFilterBloc, RecipeFilterState>(
    'saves when a toggle changes',
    build: () => RecipeFilterBloc(useCase),
    act: (bloc) =>
        bloc.add(const RecipeFilterChanged(RecipeFilterEntities(easy: true))),
    expect: () => const [
      RecipeFilterState(filter: RecipeFilterEntities(easy: true)),
    ],
    verify: (_) => verify(
      () => useCase.saveFilter(const RecipeFilterEntities(easy: true)),
    ).called(1),
  );

  blocTest<RecipeFilterBloc, RecipeFilterState>(
    'does not save when only the dish type changes',
    build: () => RecipeFilterBloc(useCase),
    act: (bloc) => bloc.add(
      const RecipeFilterChanged(
        RecipeFilterEntities(category: RecipeCategory.soup),
      ),
    ),
    expect: () => const [
      RecipeFilterState(
        filter: RecipeFilterEntities(category: RecipeCategory.soup),
      ),
    ],
    verify: (_) => verifyNever(() => useCase.saveFilter(any())),
  );
}
