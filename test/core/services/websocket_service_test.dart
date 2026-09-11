import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasam/app/app_config.dart';
import 'package:nasam/core/constants/app_constants.dart';
import 'package:nasam/core/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A channel whose stream the test drives, so connection loss is explicit.
class _FakeChannel implements WebSocketChannel {
  _FakeChannel(this.controller);

  final StreamController<dynamic> controller;
  final sent = <dynamic>[];
  bool closed = false;

  @override
  Stream<dynamic> get stream => controller.stream;

  @override
  WebSocketSink get sink => _FakeSink(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.channel);
  final _FakeChannel channel;

  @override
  void add(dynamic data) => channel.sent.add(data);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    channel.closed = true;
    await channel.controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class SocketFailure implements Exception {
  const SocketFailure();
}

void main() {
  const config = AppConfig(
    flavor: Flavor.dev,
    appName: 'Nasam Dev',
    baseUrl: 'https://api-dev.nasam.app/v1',
    wsUrl: 'wss://ws-dev.nasam.app',
  );

  late List<Uri> connections;
  late List<_FakeChannel> channels;

  WebSocketService buildService() {
    connections = [];
    channels = [];
    final service = WebSocketService(config)
      ..channelFactory = (uri) {
        connections.add(uri);
        final channel = _FakeChannel(StreamController<dynamic>());
        channels.add(channel);
        return channel;
      };
    return service;
  }

  test('connects to the flavor socket, not a hardcoded production one', () {
    final service = buildService()..connect();
    expect(connections.single.toString(), 'wss://ws-dev.nasam.app');
    service.dispose();
  });

  test('emits connecting then connected', () async {
    final service = buildService();
    final states = <WsConnectionState>[];
    final sub = service.connectionState.listen(states.add);

    service.connect();
    await Future<void>.delayed(Duration.zero);

    expect(states, [WsConnectionState.connecting, WsConnectionState.connected]);
    await sub.cancel();
    service.dispose();
  });

  test('forwards messages from the channel', () async {
    final service = buildService()..connect();
    final received = <dynamic>[];
    final sub = service.messages.listen(received.add);

    channels.single.controller.add('{"type":"position"}');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['{"type":"position"}']);
    await sub.cancel();
    service.dispose();
  });

  test('send writes to the channel sink', () {
    final service = buildService()..connect();
    service.send('ping');
    expect(channels.single.sent, ['ping']);
    service.dispose();
  });

  group('reconnect backoff', () {
    test('doubles while attempts keep failing and caps at the maximum', () {
      fakeAsync((async) {
        final service = WebSocketService(config)
          ..channelFactory = (_) => throw const SocketFailure();
        service.connect();

        // The first attempt is already scheduled at the base delay, so the
        // field holds the *next* delay. Advance by exactly one interval per
        // iteration so a single retry fires each time.
        final observed = <int>[service.reconnectDelaySecs];
        for (var attempt = 0; attempt < 7; attempt++) {
          async.elapse(Duration(seconds: service.reconnectDelaySecs));
          observed.add(service.reconnectDelaySecs);
        }

        expect(observed.first, AppConstants.wsBaseReconnectDelaySecs * 2);
        // Doubling: 2, 4, 8, 16, then capped at 30.
        expect(observed.take(4), [2, 4, 8, 16]);
        expect(
          observed.every(
            (delay) => delay <= AppConstants.wsMaxReconnectDelaySecs,
          ),
          isTrue,
        );
        expect(observed.last, AppConstants.wsMaxReconnectDelaySecs);

        service.dispose();
      });
    });

    test('resets the delay after a successful reconnect', () {
      fakeAsync((async) {
        final service = buildService()..connect();

        channels.last.controller.close();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 60));

        expect(connections, hasLength(2));
        expect(
          service.reconnectDelaySecs,
          AppConstants.wsBaseReconnectDelaySecs,
        );

        service.dispose();
      });
    });
  });

  group('no reconnect after an intentional stop', () {
    test('disconnect() stops the reconnect loop', () {
      fakeAsync((async) {
        final service = buildService()..connect();
        service.disconnect();

        async.elapse(const Duration(minutes: 5));

        expect(connections, hasLength(1));
        service.dispose();
      });
    });

    test('dispose() stops the reconnect loop', () {
      fakeAsync((async) {
        final service = buildService()..connect();
        service.dispose();

        async.elapse(const Duration(minutes: 5));

        expect(connections, hasLength(1));
      });
    });

    test('connect() after dispose() is a no-op', () {
      final service = buildService()..connect();
      service.dispose();
      service.connect();
      expect(connections, hasLength(1));
    });
  });
}
