import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/src/common/constant/env_vars.dart';

import 'get_it_configuration.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<GetIt> configureDependencies({
  String environment = AppEnv.current,
}) async {
  return getIt.init(environment: environment);
}
