part of 'generate_recipes_bloc.dart';

sealed class GenerateRecipesState extends Equatable {
  const GenerateRecipesState();

  @override
  List<Object?> get props => [];
}

final class GenerateRecipesInitial extends GenerateRecipesState {
  const GenerateRecipesInitial();
}

final class GenerateRecipesLoading extends GenerateRecipesState {
  const GenerateRecipesLoading();
}

final class GenerateRecipesSuccess extends GenerateRecipesState {
  const GenerateRecipesSuccess(this.recipes);

  final List<RecipeEntities> recipes;

  @override
  List<Object?> get props => [recipes];
}

final class GenerateRecipesFailure extends GenerateRecipesState {
  const GenerateRecipesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
