import 'env_vars.dart';

class ApiHelper {
  ApiHelper._();

  /// Overrides [baseUrl], e.g. to reach the backend from a physical phone:
  /// `--dart-define=API_BASE_URL=http://192.168.1.20:8000`.
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Local FastAPI backend (backend/). 10.0.2.2 is the host machine as seen
  /// from the Android emulator.
  static const String baseUrlDev = 'http://10.0.2.2:8000';

  // TODO: replace once staging and production are deployed.
  static const String baseUrlStg = 'https://stg-api.example.com';
  static const String baseUrlProd = 'https://api.example.com';

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    return switch (AppEnv.current) {
      AppEnv.dev => baseUrlDev,
      AppEnv.stg => baseUrlStg,
      AppEnv.prod => baseUrlProd,
      _ => throw StateError(
        'Unknown ENV "${AppEnv.current}". Use one of ${AppEnv.all}.',
      ),
    };
  }

  /// POST `{"ingredients": ["egg", "rice"]}` returns
  /// `{"recipes": [RecipeModel, ...]}`.
  static const String generateRecipes = '/recipes/generate';
}
