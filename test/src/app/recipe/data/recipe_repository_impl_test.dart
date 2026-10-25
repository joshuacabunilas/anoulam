import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/src/app/recipe/data/data_source/recipe_local_data_source.dart';
import 'package:mobile/src/app/recipe/data/data_source/recipe_remote_data_source.dart';
import 'package:mobile/src/app/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_entities.dart';
import 'package:mobile/src/app/recipe/domain/entities/recipe_filter_entities.dart';
import 'package:mobile/src/common/constant/api_helper.dart';
import 'package:mobile/src/common/constant/string_helper.dart';
import 'package:mobile/src/utils/storage_utils.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_recipe_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRemoteDataSource extends Mock implements RecipeRemoteDataSource {}

final _request = RequestOptions(
  baseUrl: 'http://10.0.2.2:8000',
  path: ApiHelper.generateRecipes,
);

const _recipeJson = {
  'id': 'tomato-omelette',
  'name': 'Tomato Omelette',
  'description': 'Fluffy omelette.',
  'cooking_time_minutes': 10,
  'servings': 1,
  'difficulty': 'easy',
  'used_ingredients': ['egg', 'tomato'],
  'missing_ingredients': ['onion'],
  'steps': ['Cook it.'],
};

void main() {
  late _MockRemoteDataSource dataSource;
  late RecipeRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageUtil.reset();
    await StorageUtil.getInstance();
    dataSource = _MockRemoteDataSource();
    repository = RecipeRepositoryImpl(
      dataSource,
      const RecipeLocalDataSource(),
    );
  });

  void respond(Object? data) {
    when(() => dataSource.generateRecipes(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: _request,
        statusCode: 200,
        data: data,
      ),
    );
  }

  void fail(DioException error) {
    when(() => dataSource.generateRecipes(any())).thenThrow(error);
  }

  test('sends the ingredients and maps recipes to entities', () async {
    respond({
      'recipes': [
        {
          ..._recipeJson,
          'category': 'egg',
          'image_url': '/images/tomato-omelette.jpg',
          'image_credit': 'Photo: Someone (CC0)',
        },
        {..._recipeJson, 'id': 'no-photo'},
      ],
    });

    final result = await repository.generateRecipes(['egg', 'tomato']);
    final recipes = result.getOrElse((_) => fail_('expected Right'));

    verify(
      () => dataSource.generateRecipes({
        'ingredients': ['egg', 'tomato'],
      }),
    ).called(1);
    expect(recipes[0].name, 'Tomato Omelette');
    expect(recipes[0].category, RecipeCategory.egg);
    expect(
      recipes[0].imageUrl,
      'http://10.0.2.2:8000/images/tomato-omelette.jpg',
    );
    expect(recipes[0].imageCredit, 'Photo: Someone (CC0)');
    expect(recipes[1].imageUrl, isNull);
    expect(recipes[1].category, RecipeCategory.meat); // default
  });

  test('keeps absolute image URLs as they are', () async {
    respond({
      'recipes': [
        {..._recipeJson, 'image_url': 'https://cdn.example.com/a.jpg'},
      ],
    });

    final result = await repository.generateRecipes(['egg']);

    expect(
      result.getOrElse((_) => fail_('expected Right')).single.imageUrl,
      'https://cdn.example.com/a.jpg',
    );
  });

  test('uses the backend error detail when present', () async {
    fail(
      DioException(
        requestOptions: _request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: _request,
          statusCode: 503,
          data: {'detail': 'Too many requests right now.'},
        ),
      ),
    );

    final result = await repository.generateRecipes(['egg']);

    expect(result, const Left(RecipeFailure('Too many requests right now.')));
  });

  test('maps network errors to friendly messages', () async {
    fail(
      DioException(
        requestOptions: _request,
        type: DioExceptionType.connectionError,
      ),
    );
    expect(
      await repository.generateRecipes(['egg']),
      const Left(RecipeFailure(StringHelper.noInternet)),
    );

    fail(
      DioException(
        requestOptions: _request,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    expect(
      await repository.generateRecipes(['egg']),
      const Left(RecipeFailure(StringHelper.requestTimedOut)),
    );
  });

  test('a malformed response becomes an UnexpectedFailure', () async {
    respond({
      'recipes': [
        {'name': 'missing fields'},
      ],
    });

    final result = await repository.generateRecipes(['egg']);

    expect(
      result,
      const Left(UnexpectedFailure(StringHelper.somethingWentWrong)),
    );
  });

  test('works end to end with the mock data source', () async {
    final repo = RecipeRepositoryImpl(
      const FakeRecipeRemoteDataSource(),
      const RecipeLocalDataSource(),
    );

    final result = await repo.generateRecipes(['egg', 'tomato', 'onion']);
    final recipes = result.getOrElse((_) => fail_('expected Right'));

    expect(recipes.first.name, 'Tomato Omelette');
    expect(recipes.first.canCookNow, isTrue);
  });

  test('a gateway HTML error page shows "service unavailable"', () async {
    fail(
      DioException(
        requestOptions: _request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: _request,
          statusCode: 502,
          data: '<html><body>Bad Gateway</body></html>',
        ),
      ),
    );

    expect(
      await repository.generateRecipes(['egg']),
      const Left(RecipeFailure(StringHelper.serviceUnavailable)),
    );
  });

  test('a non-200 success response is a failure, not a crash', () async {
    when(() => dataSource.generateRecipes(any())).thenAnswer(
      (_) async => Response<dynamic>(requestOptions: _request, statusCode: 204),
    );

    expect(
      await repository.generateRecipes(['egg']),
      const Left(RecipeFailure(StringHelper.somethingWentWrong)),
    );
  });

  test('a socket error is reported as no internet', () async {
    fail(
      DioException(
        requestOptions: _request,
        type: DioExceptionType.unknown,
        error: const SocketException('Failed host lookup'),
      ),
    );

    expect(
      await repository.generateRecipes(['egg']),
      const Left(RecipeFailure(StringHelper.noInternet)),
    );
  });

  test('saved ingredients are empty at first', () async {
    final result = await repository.getSavedIngredients();

    expect(result.getOrElse((_) => fail_('expected Right')), isEmpty);
  });

  test('saves and loads the ingredient list', () async {
    await repository.saveIngredients(['Egg', 'soy sauce']);

    final result = await repository.getSavedIngredients();

    expect(result.getOrElse((_) => fail_('expected Right')), [
      'Egg',
      'soy sauce',
    ]);
  });

  test('saves and loads filter toggles, not the dish type', () async {
    await repository.saveFilter(
      const RecipeFilterEntities(
        vegetarian: true,
        quick: true,
        category: RecipeCategory.soup,
      ),
    );

    final result = await repository.getSavedFilter();

    expect(
      result.getOrElse((_) => fail_('expected Right')),
      const RecipeFilterEntities(vegetarian: true, quick: true),
    );
  });
}

Never fail_(String reason) => throw TestFailure(reason);
