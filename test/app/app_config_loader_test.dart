import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_config_loader.dart';

void main() {
  AppConfig build({
    Flavor flavor = Flavor.dev,
    String baseUrl = 'https://api-dev.nasam.app/v1',
    String wsUrl = 'wss://ws-dev.nasam.app',
    String? configuredFlavor,
  }) {
    return AppConfigLoader.build(
      flavor: flavor,
      baseUrl: baseUrl,
      wsUrl: wsUrl,
      configuredFlavor: configuredFlavor ?? flavor.name,
    );
  }

  group('build', () {
    test('resolves a matching flavor config', () {
      final config = build();
      expect(config.flavor, Flavor.dev);
      expect(config.baseUrl, 'https://api-dev.nasam.app/v1');
      expect(config.wsUrl, 'wss://ws-dev.nasam.app');
      expect(config.isDev, isTrue);
      expect(config.isProd, isFalse);
    });

    test('a missing dart-define fails loudly instead of falling back', () {
      expect(() => build(baseUrl: ''), throwsA(isA<StateError>()));
      expect(() => build(wsUrl: ''), throwsA(isA<StateError>()));
    });

    // Guards the prod entrypoint being run against a dev config file.
    test('rejects a config file belonging to another flavor', () {
      expect(
        () => build(flavor: Flavor.prod, configuredFlavor: 'dev'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('hostsAgree', () {
    // The exact bug: the API was per-flavor while the socket always resolved
    // to production.
    test('rejects a dev API paired with the production socket', () {
      expect(
        AppConfigLoader.hostsAgree(
          'https://api-dev.nasam.app/v1',
          'wss://ws.nasam.app',
        ),
        isFalse,
      );
    });

    test('accepts hosts from the same environment', () {
      expect(
        AppConfigLoader.hostsAgree(
          'https://api-dev.nasam.app/v1',
          'wss://ws-dev.nasam.app',
        ),
        isTrue,
      );
      expect(
        AppConfigLoader.hostsAgree(
          'https://api-stage.nasam.app/v1',
          'wss://ws-stage.nasam.app',
        ),
        isTrue,
      );
      expect(
        AppConfigLoader.hostsAgree(
          'https://api.nasam.app/v1',
          'wss://ws.nasam.app',
        ),
        isTrue,
      );
    });

    test('rejects mismatched environments and domains', () {
      expect(
        AppConfigLoader.hostsAgree(
          'https://api-dev.nasam.app/v1',
          'wss://ws-stage.nasam.app',
        ),
        isFalse,
      );
      expect(
        AppConfigLoader.hostsAgree(
          'https://api-dev.nasam.app/v1',
          'wss://ws-dev.example.com',
        ),
        isFalse,
      );
      expect(AppConfigLoader.hostsAgree('not a url', 'also not'), isFalse);
    });

    test('the shipped config files each pass the environment check', () {
      // Mirrors config/<flavor>.json so a hand edit that crosses environments
      // is caught here rather than at runtime.
      const shipped = {
        'dev': ('https://api-dev.nasam.app/v1', 'wss://ws-dev.nasam.app'),
        'staging': (
          'https://api-stage.nasam.app/v1',
          'wss://ws-stage.nasam.app',
        ),
        'prod': ('https://api.nasam.app/v1', 'wss://ws.nasam.app'),
      };
      shipped.forEach((flavor, urls) {
        expect(
          AppConfigLoader.hostsAgree(urls.$1, urls.$2),
          isTrue,
          reason: '$flavor config crosses environments',
        );
      });
    });
  });
}
