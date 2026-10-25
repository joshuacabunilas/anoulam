part of 'ingredients_bloc.dart';

final class IngredientsState extends Equatable {
  const IngredientsState({this.ingredients = const []});

  final List<String> ingredients;

  bool get isEmpty => ingredients.isEmpty;

  bool get isFull => ingredients.length >= IngredientEntities.maxCount;

  /// Case- and plural-insensitive: "Egg" on the list means "Eggs" is
  /// already there too (see [IngredientEntities.key]).
  bool contains(String name) =>
      ingredients.any((i) => IngredientEntities.same(i, name));

  @override
  List<Object?> get props => [ingredients];
}
