part of 'recipe_filter_bloc.dart';

final class RecipeFilterState extends Equatable {
  const RecipeFilterState({this.filter = const RecipeFilterEntities()});

  final RecipeFilterEntities filter;

  @override
  List<Object?> get props => [filter];
}
