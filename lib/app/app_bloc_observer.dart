import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.d('Bloc Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.d('Bloc Event: ${bloc.runtimeType} | Event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d('Bloc Change: ${bloc.runtimeType} | CurrentState: ${change.currentState} -> NextState: ${change.nextState}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.e('Bloc Error: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLogger.d('Bloc Closed: ${bloc.runtimeType}');
  }
}
