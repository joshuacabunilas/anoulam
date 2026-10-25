import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/services/bloc_observer_service.dart';
import 'get_it_configuration/get_it_configuration.dart' as di;
import 'src/common/constant/env_vars.dart';
import 'src/utils/storage_utils.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      log('Running with ENV=${AppEnv.current}', name: 'main');
      _registerFontLicenses();
      await di.configureDependencies();
      await StorageUtil.getInstance();
      if (kDebugMode) {
        Bloc.observer = BlocObserverService();
      }
      runApp(const App());
    },
    (error, stackTrace) => log(
      'Uncaught error',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

/// Bundled fonts are OFL-licensed; this lists them on the licenses page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in [('DM Sans', 'OFL-DMSans.txt')]) {
      final text = await rootBundle.loadString('assets/fonts/$file');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
