import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app/app_config.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

enum WsConnectionState { connecting, connected, disconnected, error }
class WebSocketService {
  WebSocketService(this._config) {
    _emitState(WsConnectionState.disconnected);
  }

  final AppConfig _config;

  /// Swappable so the reconnect/backoff behaviour is testable without a server.
  @visibleForTesting
  WebSocketChannel Function(Uri url)? channelFactory;

  @visibleForTesting
  int get reconnectDelaySecs => _reconnectDelaySecs;

  WebSocketChannel? _channel;
  final StreamController<WsConnectionState> _stateController =
      StreamController<WsConnectionState>.broadcast();
  final StreamController<dynamic> _messageController =
      StreamController<dynamic>.broadcast();

  Stream<WsConnectionState> get connectionState => _stateController.stream;
  Stream<dynamic> get messages => _messageController.stream;

  bool _isDisposed = false;
  bool _shouldReconnect = false;
  int _reconnectDelaySecs = AppConstants.wsBaseReconnectDelaySecs;

  void connect() {
    if (_isDisposed) return;
    _shouldReconnect = true;
    _establishConnection();
  }

  /// Closing the sink makes the stream fire onDone, which arrives after
  /// dispose() has already closed the controller. Without this guard that
  /// throws "Cannot add new events after calling close" on every disposal.
  void _emitState(WsConnectionState state) {
    if (_stateController.isClosed) return;
    _stateController.add(state);
  }

  void _establishConnection() {
    if (_channel != null || _isDisposed) return;

    final wsUrl = _config.wsUrl;
    AppLogger.i('Connecting to WebSocket: $wsUrl');
    _emitState(WsConnectionState.connecting);

    try {
      final factory = channelFactory;
      final uri = Uri.parse(wsUrl);
      _channel = factory == null ? WebSocketChannel.connect(uri) : factory(uri);
      _emitState(WsConnectionState.connected);
      _reconnectDelaySecs = AppConstants.wsBaseReconnectDelaySecs;

      _channel!.stream.listen(
        (message) {
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        },
        onError: (Object err) {
          AppLogger.e('WebSocket stream error', error: err);
          _emitState(WsConnectionState.error);
          _handleConnectionClosedOrFailed();
        },
        onDone: () {
          AppLogger.i('WebSocket stream completed/closed');
          _emitState(WsConnectionState.disconnected);
          _handleConnectionClosedOrFailed();
        },
        cancelOnError: true,
      );
    } catch (e, stack) {
      AppLogger.e(
        'Failed to initiate WebSocket connection',
        error: e,
        stackTrace: stack,
      );
      _emitState(WsConnectionState.error);
      _handleConnectionClosedOrFailed();
    }
  }

  void _handleConnectionClosedOrFailed() {
    _channel = null;
    if (_shouldReconnect && !_isDisposed) {
      final backoff = Duration(seconds: _reconnectDelaySecs);
      AppLogger.w('WebSocket reconnecting in ${_reconnectDelaySecs}s...');
      Timer(backoff, () {
        if (_shouldReconnect && !_isDisposed) {
          _establishConnection();
        }
      });
      _reconnectDelaySecs = min(
        AppConstants.wsMaxReconnectDelaySecs,
        _reconnectDelaySecs * 2,
      );
    }
  }

  void send(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    } else {
      AppLogger.w('WebSocket channel is not active. Failed to send message.');
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _emitState(WsConnectionState.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}
