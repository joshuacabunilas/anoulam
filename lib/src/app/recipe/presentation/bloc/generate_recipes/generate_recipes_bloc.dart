import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/error/failures.dart';

import '../../../domain/entities/recipe_entities.dart';
import '../../../domain/usecase/recipe_use_case.dart';

part 'generate_recipes_event.dart';
part 'generate_recipes_state.dart';

@injectable
class GenerateRecipesBloc
    extends Bloc<GenerateRecipesEvent, GenerateRecipesState> {
  GenerateRecipesBloc(this._recipeUseCase)
    : super(const GenerateRecipesInitial()) {
    on<GenerateRecipesRequested>(_onRequested);
  }

  final RecipeUseCase _recipeUseCase;

  Future<void> _onRequested(
    GenerateRecipesRequested event,
    Emitter<GenerateRecipesState> emit,
  ) async {
    emit(const GenerateRecipesLoading());
    final result = await _recipeUseCase.generateRecipes(event.ingredients);
    emit(result.fold(GenerateRecipesFailure.new, GenerateRecipesSuccess.new));
  }
}
