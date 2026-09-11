import 'app/app.dart';
import 'app/app_config.dart';
import 'main.dart';

Future<void> main() => bootstrap(Flavor.prod, NasamApp.new);
