import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/src/common/constant/api_helper.dart';
import 'package:mobile/src/common/constant/env_vars.dart';
import 'package:mobile/src/utils/global_data_config.dart';
import 'package:mobile/src/utils/network_utils.dart';

abstract class RecipeRemoteDataSource {
  /// POST [ApiHelper.generateRecipes] with `{"ingredients": [...]}`.
  ///
  /// Returns the raw response; the repository parses it. Throws
  /// [DioException] on HTTP or network errors.
  Future<Response> generateRecipes(Map<String, dynamic> mapData);
}

@Injectable(
  as: RecipeRemoteDataSource,
  env: [AppEnv.dev, AppEnv.stg, AppEnv.prod],
)
class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  /// [dio] is only for tests; the app always uses its own instance.
  RecipeRemoteDataSourceImpl({@ignoreParam Dio? dio})
    : _dio =
          dio ??
          (Dio(
            BaseOptions(
              connectTimeout: GlobalDataConfig.connectTimeout,
              receiveTimeout: GlobalDataConfig.receiveTimeout,
            ),
          )..interceptors.addAll(NetworkUtils.getNetworkInterceptor()));

  /// Longer than the default timeout: a sleeping free-tier server can take
  /// about a minute to wake up, and AI mode (RECIPE_SOURCE=claude) is slow
  /// too.
  static const _generateTimeout = Duration(seconds: 100);

  final Dio _dio;

  @override
  Future<Response> generateRecipes(Map<String, dynamic> mapData) async {
    try {
      final response = await _dio.post(
        '${ApiHelper.baseUrl}${ApiHelper.generateRecipes}',
        data: mapData,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {HttpHeaders.acceptHeader: Headers.jsonContentType},
          sendTimeout: GlobalDataConfig.sendTimeout,
          receiveTimeout: _generateTimeout,
        ),
      );

      log(
        'Generate Recipes Code: ${response.statusCode}',
        name: 'RecipeRemoteDataSource',
      );

      return response;
    } on DioException catch (e) {
      // `response` is null for timeouts and connection errors.
      log(
        'Generate Recipes Error: ${e.type} ${e.response?.statusCode} '
        '${e.response?.data}',
        name: 'RecipeRemoteDataSource',
      );
      rethrow;
    } catch (e) {
      log('Generate Recipes Catch Error: $e', name: 'RecipeRemoteDataSource');
      rethrow;
    }
  }
}
