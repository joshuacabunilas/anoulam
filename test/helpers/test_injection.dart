import 'package:mobile/get_it_configuration/get_it_configuration.dart';
import 'package:mobile/src/app/recipe/data/data_source/recipe_local_data_source.dart';
import 'package:mobile/src/app/recipe/data/data_source/recipe_remote_data_source.dart';
import 'package:mobile/src/app/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:mobile/src/app/recipe/domain/repository/recipe_repository.dart';
import 'package:mobile/src/common/constant/env_vars.dart';
import 'package:mobile/src/utils/storage_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_recipe_remote_data_source.dart';

/// Resets GetIt, registers the app's dependencies with the backend swapped
/// for [FakeRecipeRemoteDataSource], and gives each test empty device
/// storage (pass [storage] to start with saved values).
Future<void> setUpTestDependencies({
  Map<String, Object> storage = const {},
}) async {
  SharedPreferences.setMockInitialValues(storage);
  StorageUtil.reset();
  await StorageUtil.getInstance();
  await getIt.reset();
  await configureDependencies(environment: AppEnv.dev);
  // The repository is an eager singleton built on the real data source,
  // so it is rebuilt on the fake too.
  getIt
    ..unregister<RecipeRemoteDataSource>()
    ..registerFactory<RecipeRemoteDataSource>(
      () => const FakeRecipeRemoteDataSource(),
    )
    ..unregister<RecipeRepository>()
    ..registerSingleton<RecipeRepository>(
      RecipeRepositoryImpl(
        getIt<RecipeRemoteDataSource>(),
        getIt<RecipeLocalDataSource>(),
      ),
    );
}
