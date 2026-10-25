import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/recipe_filter_entities.dart';
import '../../../domain/usecase/recipe_use_case.dart';

part 'recipe_filter_event.dart';
part 'recipe_filter_state.dart';

/// The results filter. The on/off toggles are saved on the device so they
/// carry over to the next search; the dish type is per search.
@injectable
class RecipeFilterBloc extends Bloc<RecipeFilterEvent, RecipeFilterState> {
  RecipeFilterBloc(this._recipeUseCase) : super(const RecipeFilterState()) {
    on<RecipeFilterStarted>(_onStarted);
    on<RecipeFilterChanged>(_onChanged);
  }

  final RecipeUseCase _recipeUseCase;

  Future<void> _onStarted(
    RecipeFilterStarted event,
    Emitter<RecipeFilterState> emit,
  ) async {
    final result = await _recipeUseCase.getSavedFilter();
    result.fold((failure) => log(failure.message, name: 'RecipeFilterBloc'), (
      saved,
    ) {
      // Keep a dish type picked while loading.
      final filter = saved.copyWith(category: () => state.filter.category);
      if (filter != state.filter) emit(RecipeFilterState(filter: filter));
    });
  }

  Future<void> _onChanged(
    RecipeFilterChanged event,
    Emitter<RecipeFilterState> emit,
  ) async {
    final previous = state.filter;
    emit(RecipeFilterState(filter: event.filter));
    if (previous.toggleNames.join() == event.filter.toggleNames.join()) {
      return; // only the dish type changed; nothing to save
    }
    final result = await _recipeUseCase.saveFilter(event.filter);
    result.fold(
      (failure) => log(failure.message, name: 'RecipeFilterBloc'),
      (_) {},
    );
  }
}
