part of 'recipe_filter_bloc.dart';

sealed class RecipeFilterEvent extends Equatable {
  const RecipeFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the saved filter toggles. Add once when the results page opens.
final class RecipeFilterStarted extends RecipeFilterEvent {
  const RecipeFilterStarted();
}

final class RecipeFilterChanged extends RecipeFilterEvent {
  const RecipeFilterChanged(this.filter);

  final RecipeFilterEntities filter;

  @override
  List<Object?> get props => [filter];
}
