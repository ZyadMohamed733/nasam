import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_config_loader.dart';

void main() {
  setUp(() {
    dotenv.testLoad(
      fileInput: '''
DEV_BASE_URL=https://api-dev.nasam.app/v1
DEV_WS_URL=wss://ws-dev.nasam.app
STAGE_BASE_URL=https://api-stage.nasam.app/v1
STAGE_WS_URL=wss://ws-stage.nasam.app
PROD_BASE_URL=https://api.nasam.app/v1
PROD_WS_URL=wss://ws.nasam.app
''',
    );
  });

  test('each flavor resolves its own API and socket hosts', () {
    final dev = AppConfigLoader.forFlavor(Flavor.dev);
    final staging = AppConfigLoader.forFlavor(Flavor.staging);
    final prod = AppConfigLoader.forFlavor(Flavor.prod);

    expect(dev.baseUrl, 'https://api-dev.nasam.app/v1');
    expect(dev.wsUrl, 'wss://ws-dev.nasam.app');
    expect(staging.wsUrl, 'wss://ws-stage.nasam.app');
    expect(prod.wsUrl, 'wss://ws.nasam.app');

    // The bug this guards: every flavor previously fell through to the
    // production socket because the key it looked up did not exist.
    expect({dev.wsUrl, staging.wsUrl, prod.wsUrl}, hasLength(3));
    expect({dev.baseUrl, staging.baseUrl, prod.baseUrl}, hasLength(3));
  });

  test('flavor flags are mutually exclusive', () {
    final dev = AppConfigLoader.forFlavor(Flavor.dev);
    expect((dev.isDev, dev.isStaging, dev.isProd), (true, false, false));

    final prod = AppConfigLoader.forFlavor(Flavor.prod);
    expect((prod.isDev, prod.isStaging, prod.isProd), (false, false, true));
  });

  test('a missing key fails loudly instead of falling back', () {
    dotenv.testLoad(fileInput: 'DEV_BASE_URL=https://api-dev.nasam.app/v1');
    expect(
      () => AppConfigLoader.forFlavor(Flavor.dev),
      throwsA(isA<StateError>()),
    );
  });
}
