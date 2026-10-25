// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mobile/src/app/recipe/data/data_source/recipe_local_data_source.dart'
    as _i949;
import 'package:mobile/src/app/recipe/data/data_source/recipe_remote_data_source.dart'
    as _i1046;
import 'package:mobile/src/app/recipe/data/repositories/recipe_repository_impl.dart'
    as _i912;
import 'package:mobile/src/app/recipe/domain/repository/recipe_repository.dart'
    as _i333;
import 'package:mobile/src/app/recipe/domain/usecase/recipe_use_case.dart'
    as _i9;
import 'package:mobile/src/app/recipe/presentation/bloc/generate_recipes/generate_recipes_bloc.dart'
    as _i629;
import 'package:mobile/src/app/recipe/presentation/bloc/ingredients/ingredients_bloc.dart'
    as _i982;
import 'package:mobile/src/app/recipe/presentation/bloc/recipe_filter/recipe_filter_bloc.dart'
    as _i135;

const String _dev = 'dev';
const String _stg = 'stg';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i949.RecipeLocalDataSource>(
      () => const _i949.RecipeLocalDataSource(),
    );
    gh.factory<_i1046.RecipeRemoteDataSource>(
      () => _i1046.RecipeRemoteDataSourceImpl(),
      registerFor: {_dev, _stg, _prod},
    );
    gh.singleton<_i333.RecipeRepository>(
      () => _i912.RecipeRepositoryImpl(
        gh<_i1046.RecipeRemoteDataSource>(),
        gh<_i949.RecipeLocalDataSource>(),
      ),
    );
    gh.factory<_i9.RecipeUseCase>(
      () => _i9.RecipeUseCase(gh<_i333.RecipeRepository>()),
    );
    gh.factory<_i629.GenerateRecipesBloc>(
      () => _i629.GenerateRecipesBloc(gh<_i9.RecipeUseCase>()),
    );
    gh.factory<_i982.IngredientsBloc>(
      () => _i982.IngredientsBloc(gh<_i9.RecipeUseCase>()),
    );
    gh.factory<_i135.RecipeFilterBloc>(
      () => _i135.RecipeFilterBloc(gh<_i9.RecipeUseCase>()),
    );
    return this;
  }
}
