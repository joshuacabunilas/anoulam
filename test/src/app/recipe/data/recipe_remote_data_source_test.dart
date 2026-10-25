import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/recipe/data/data_source/recipe_remote_data_source.dart';
import 'package:mobile/src/common/constant/api_helper.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

final _request = RequestOptions(path: ApiHelper.generateRecipes);

void main() {
  late _MockDio dio;
  late RecipeRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = RecipeRemoteDataSourceImpl(dio: dio);
  });

  void stubPost(Future<Response<dynamic>> Function() answer) {
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('posts the payload as JSON and returns the raw response', () async {
    final response = Response<dynamic>(
      requestOptions: _request,
      statusCode: 200,
      data: {'recipes': <dynamic>[]},
    );
    stubPost(() async => response);

    final result = await dataSource.generateRecipes({
      'ingredients': ['egg'],
    });

    expect(result, same(response));
    final captured = verify(
      () => dio.post<dynamic>(
        '${ApiHelper.baseUrl}${ApiHelper.generateRecipes}',
        data: {
          'ingredients': ['egg'],
        },
        options: captureAny(named: 'options'),
      ),
    ).captured;
    final options = captured.single as Options;
    expect(options.contentType, Headers.jsonContentType);
    expect(options.receiveTimeout, const Duration(seconds: 100));
  });

  test('rethrows HTTP errors', () async {
    final error = DioException(
      requestOptions: _request,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: _request, statusCode: 503),
    );
    stubPost(() => Future.error(error));

    expect(
      () => dataSource.generateRecipes({'ingredients': <String>[]}),
      throwsA(same(error)),
    );
  });

  test('rethrows network errors that have no response, without crashing', () {
    final error = DioException(
      requestOptions: _request,
      type: DioExceptionType.connectionError,
    );
    stubPost(() => Future.error(error));

    expect(
      () => dataSource.generateRecipes({'ingredients': <String>[]}),
      throwsA(same(error)),
    );
  });
}
