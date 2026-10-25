import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/src/common/constant/string_helper.dart';

import '../../domain/entities/recipe_entities.dart';
import '../../domain/entities/recipe_filter_entities.dart';
import '../../domain/repository/recipe_repository.dart';
import '../data_source/recipe_local_data_source.dart';
import '../data_source/recipe_remote_data_source.dart';
import '../mappers/recipe_mapper.dart';
import '../model/generate_recipes_response_model.dart';

@Singleton(as: RecipeRepository)
class RecipeRepositoryImpl implements RecipeRepository {
  const RecipeRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final RecipeRemoteDataSource _remoteDataSource;
  final RecipeLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<String>>> getSavedIngredients() async {
    try {
      return Right(_localDataSource.getSavedIngredients());
    } catch (e) {
      log('Get saved ingredients error: $e', name: 'RecipeRepository');
      return const Left(CacheFailure(StringHelper.couldNotLoadIngredients));
    }
  }

  @override
  Future<Either<Failure, RecipeFilterEntities>> getSavedFilter() async {
    try {
      return Right(
        RecipeFilterEntities.fromToggleNames(
          _localDataSource.getSavedFilters(),
        ),
      );
    } catch (e) {
      log('Get saved filter error: $e', name: 'RecipeRepository');
      return const Left(CacheFailure(StringHelper.somethingWentWrong));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveFilter(RecipeFilterEntities filter) async {
    try {
      await _localDataSource.saveFilters(filter.toggleNames);
      return const Right(unit);
    } catch (e) {
      log('Save filter error: $e', name: 'RecipeRepository');
      return const Left(CacheFailure(StringHelper.somethingWentWrong));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveIngredients(
    List<String> ingredients,
  ) async {
    try {
      await _localDataSource.saveIngredients(ingredients);
      return const Right(unit);
    } catch (e) {
      log('Save ingredients error: $e', name: 'RecipeRepository');
      return const Left(CacheFailure(StringHelper.couldNotSaveIngredients));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntities>>> generateRecipes(
    List<String> ingredients,
  ) async {
    try {
      final response = await _remoteDataSource.generateRecipes({
        'ingredients': ingredients,
      });
      if (response.statusCode == 200 && response.data is Map) {
        final responseEntities = GenerateRecipesResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        ).toRecipeEntitiesList(requestUri: response.requestOptions.uri);
        return Right(responseEntities);
      }
      log(
        'Generate Recipes unexpected response: ${response.statusCode}',
        name: 'RecipeRepository',
      );
      return Left(RecipeFailure(_serverMessage(response)));
    } on DioException catch (e) {
      log('Generate Recipes DioException: ${e.type}', name: 'RecipeRepository');
      if (_isNetworkError(e)) {
        return Left(RecipeFailure(_networkMessage(e)));
      }
      final response = e.response;
      return Left(
        RecipeFailure(
          response == null
              ? StringHelper.somethingWentWrong
              : _serverMessage(response),
        ),
      );
    } catch (e) {
      // Not a network problem: the response didn't match RecipeModel.
      log('Generate Recipes parse error: $e', name: 'RecipeRepository');
      return const Left(UnexpectedFailure(StringHelper.somethingWentWrong));
    }
  }

  static bool _isNetworkError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => e.error is SocketException,
    };
  }

  static String _networkMessage(DioException e) {
    return e.type == DioExceptionType.connectionError ||
            e.error is SocketException
        ? StringHelper.noInternet
        : StringHelper.requestTimedOut;
  }

  /// The backend's `{"detail": "..."}` message when there is one. Gateways
  /// (e.g. a hosting proxy while the server wakes up) can answer 502/503
  /// with an HTML page; never show that to users.
  static String _serverMessage(Response<dynamic> response) {
    final body = response.data;
    if (body is Map && body['detail'] is String) {
      return body['detail'] as String;
    }
    final status = response.statusCode ?? 0;
    if (status == 502 || status == 503 || status == 504) {
      return StringHelper.serviceUnavailable;
    }
    return StringHelper.somethingWentWrong;
  }
}
