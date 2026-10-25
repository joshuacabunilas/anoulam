/// Environment names, selected with `--dart-define=ENV=<name>`.
///
/// Also used as injectable environments, e.g.
/// `@Injectable(as: X, env: [AppEnv.dev, AppEnv.stg, AppEnv.prod])`.
class AppEnv {
  AppEnv._();

  static const String dev = 'dev';
  static const String stg = 'stg';
  static const String prod = 'prod';

  static const List<String> all = [dev, stg, prod];

  /// The environment this build runs in. Defaults to [dev], the local
  /// backend.
  static const String current = String.fromEnvironment(
    'ENV',
    defaultValue: dev,
  );
}
