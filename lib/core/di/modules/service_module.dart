import 'package:injectable/injectable.dart';

@module
abstract class ServiceModule {
  // Service classes use direct annotations (@lazySingleton, @LazySingleton(as: ...))
  // keeping this module ready for third-party service bindings if needed in the future.
}
