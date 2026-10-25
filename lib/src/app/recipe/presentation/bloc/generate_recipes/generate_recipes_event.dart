part of 'generate_recipes_bloc.dart';

sealed class GenerateRecipesEvent extends Equatable {
  const GenerateRecipesEvent();

  @override
  List<Object?> get props => [];
}

final class GenerateRecipesRequested extends GenerateRecipesEvent {
  const GenerateRecipesRequested(this.ingredients);

  final List<String> ingredients;

  @override
  List<Object?> get props => [ingredients];
}
