import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/app/app_config_loader.dart';

void main() {
  AppConfig build({
    Flavor flavor = Flavor.dev,
    String baseUrl = 'https://api-dev.nasam.app/v1',
    String wsUrl = 'wss://ws-dev.nasam.app',
    String tenant = 'saudi-tracking',
    String? configuredFlavor,
  }) {
    return AppConfigLoader.build(
      flavor: flavor,
      baseUrl: baseUrl,
      wsUrl: wsUrl,
      tenant: tenant,
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
      expect(() => build(tenant: ''), throwsA(isA<StateError>()));
    });

    // Every request is scoped to a tenant; without one the API answers 404,
    // which looks like a missing endpoint rather than a missing setting.
    test('an empty TENANT fails loudly, like BASE_URL', () {
      expect(
        () => build(tenant: ''),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('TENANT'),
          ),
        ),
      );
    });

    test('the tenant comes from the config and reaches the API headers', () {
      final config = build(tenant: 'another-tenant');
      expect(config.tenant, 'another-tenant');
      expect(config.apiHeaders, {
        'X-Client': 'mobile',
        'x-tenant': 'another-tenant',
      });
    });

    // Guards the prod entrypoint being run against a dev config file.
    test('rejects a config file belonging to another flavor', () {
      expect(
        () => build(flavor: Flavor.prod, configuredFlavor: 'dev'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('an API/socket environment mismatch', () {
    AppConfig mismatched(Flavor flavor) => build(
      flavor: flavor,
      baseUrl: 'https://api-stage.nasam.app/v1',
      wsUrl: 'wss://ws.nasam.app',
    );

    test('fails a staging build', () {
      expect(() => mismatched(Flavor.staging), throwsStateError);
    });

    test('fails a prod build', () {
      expect(() => mismatched(Flavor.prod), throwsStateError);
    });

    test('only warns in dev', () {
      expect(mismatched(Flavor.dev).flavor, Flavor.dev);
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

    // Read from config/<flavor>.json itself, so a hand edit that crosses
    // environments is caught here rather than by a release build refusing
    // to start.
    for (final flavor in Flavor.values) {
      test('the shipped ${flavor.name} config loads', () {
        final json =
            jsonDecode(File('config/${flavor.name}.json').readAsStringSync())
                as Map<String, dynamic>;
        expect(
          () => AppConfigLoader.build(
            flavor: flavor,
            baseUrl: json['BASE_URL'] as String,
            wsUrl: json['WS_URL'] as String,
            tenant: json['TENANT'] as String,
            configuredFlavor: json['FLAVOR'] as String,
          ),
          returnsNormally,
        );
      });
    }
  });
}
