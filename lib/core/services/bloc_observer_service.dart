import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs bloc events, transitions and errors. Installed in debug builds only.
class BlocObserverService extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log('${bloc.runtimeType} event: $event', name: 'Bloc');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log(
      '${bloc.runtimeType}: ${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
      name: 'Bloc',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log(
      '${bloc.runtimeType} error',
      name: 'Bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
