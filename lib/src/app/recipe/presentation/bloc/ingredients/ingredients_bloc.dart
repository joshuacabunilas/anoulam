import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/ingredient_entities.dart';
import '../../../domain/usecase/recipe_use_case.dart';

part 'ingredients_event.dart';
part 'ingredients_state.dart';

/// Holds the user's ingredient list and saves it on the device after every
/// change, so it is still there the next time the app opens.
///
/// Names are compared with [IngredientEntities.same] (case- and
/// plural-insensitive), so the list never holds both "Egg" and "Eggs".
@injectable
class IngredientsBloc extends Bloc<IngredientsEvent, IngredientsState> {
  IngredientsBloc(this._recipeUseCase) : super(const IngredientsState()) {
    on<IngredientsStarted>(_onStarted);
    on<IngredientAdded>(_onAdded);
    on<IngredientRemoved>(_onRemoved);
    on<IngredientsCleared>(_onCleared);
    on<IngredientsRestored>(_onRestored);
  }

  final RecipeUseCase _recipeUseCase;

  Future<void> _onStarted(
    IngredientsStarted event,
    Emitter<IngredientsState> emit,
  ) async {
    final result = await _recipeUseCase.getSavedIngredients();
    result.fold(
      (failure) => log(failure.message, name: 'IngredientsBloc'),
      // Saved lists from older versions may hold "Egg" and "Eggs"; keep the
      // first. Anything added while loading goes after the saved items.
      (saved) => emit(
        IngredientsState(
          ingredients: _merge(const [], [...saved, ...state.ingredients]),
        ),
      ),
    );
  }

  Future<void> _onAdded(
    IngredientAdded event,
    Emitter<IngredientsState> emit,
  ) async {
    final name = IngredientEntities.clean(event.name);
    if (name.isEmpty ||
        name.length > IngredientEntities.maxLength ||
        state.isFull ||
        state.contains(name)) {
      return;
    }
    await _update([...state.ingredients, name], emit);
  }

  Future<void> _onRemoved(
    IngredientRemoved event,
    Emitter<IngredientsState> emit,
  ) async {
    await _update(
      state.ingredients
          .where((i) => !IngredientEntities.same(i, event.name))
          .toList(),
      emit,
    );
  }

  Future<void> _onCleared(
    IngredientsCleared event,
    Emitter<IngredientsState> emit,
  ) async {
    await _update(const [], emit);
  }

  Future<void> _onRestored(
    IngredientsRestored event,
    Emitter<IngredientsState> emit,
  ) async {
    final current = state.ingredients;
    final index = event.index.clamp(0, current.length);
    final restored = _merge(current, event.names);
    final added = restored.sublist(current.length);
    if (added.isEmpty) return;
    await _update([
      ...current.sublist(0, index),
      ...added,
      ...current.sublist(index),
    ], emit);
  }

  /// [base] followed by the [extra] names it doesn't already hold, without
  /// duplicates and up to [IngredientEntities.maxCount].
  static List<String> _merge(List<String> base, List<String> extra) {
    final result = [...base];
    for (final raw in extra) {
      final name = IngredientEntities.clean(raw);
      if (result.length >= IngredientEntities.maxCount) break;
      if (name.isEmpty || result.any((i) => IngredientEntities.same(i, name))) {
        continue;
      }
      result.add(name);
    }
    return result;
  }

  /// Shows the new list right away, then saves it. A failed save is only
  /// logged: the list still works for this session.
  Future<void> _update(
    List<String> ingredients,
    Emitter<IngredientsState> emit,
  ) async {
    emit(IngredientsState(ingredients: ingredients));
    final result = await _recipeUseCase.saveIngredients(ingredients);
    result.fold(
      (failure) => log(failure.message, name: 'IngredientsBloc'),
      (_) {},
    );
  }
}
