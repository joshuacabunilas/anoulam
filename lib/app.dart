import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/common/constant/string_helper.dart';
import 'src/common/theme/app_theme.dart';
import 'src/routes/app_router.dart';

class App extends StatefulWidget {
  const App({super.key, this.router});

  /// Overrides the app's router, e.g. in tests.
  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Created once so rebuilds don't reset navigation.
  late final GoRouter _router = widget.router ?? AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: StringHelper.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
