part of 'ingredients_bloc.dart';

sealed class IngredientsEvent extends Equatable {
  const IngredientsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the saved ingredient list. Add once when the page opens.
final class IngredientsStarted extends IngredientsEvent {
  const IngredientsStarted();
}

final class IngredientAdded extends IngredientsEvent {
  const IngredientAdded(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class IngredientRemoved extends IngredientsEvent {
  const IngredientRemoved(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class IngredientsCleared extends IngredientsEvent {
  const IngredientsCleared();
}

/// Undo: puts [names] back at [index] (clamped to the list), skipping any
/// already on the list again, so anything added since the removal is kept.
final class IngredientsRestored extends IngredientsEvent {
  const IngredientsRestored(this.names, {this.index = 0});

  final List<String> names;
  final int index;

  @override
  List<Object?> get props => [names, index];
}
