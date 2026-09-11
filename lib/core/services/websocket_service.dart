import 'dart:async';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../app/app_config.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

enum WsConnectionState { connecting, connected, disconnected, error }

@lazySingleton
class WebSocketService {
  WebSocketService(this._config) {
    _stateController.add(WsConnectionState.disconnected);
  }

  final AppConfig _config;

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

  void _establishConnection() {
    if (_channel != null || _isDisposed) return;

    final wsUrl = _config.wsUrl;
    AppLogger.i('Connecting to WebSocket: $wsUrl');
    _stateController.add(WsConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _stateController.add(WsConnectionState.connected);
      _reconnectDelaySecs = AppConstants.wsBaseReconnectDelaySecs;

      _channel!.stream.listen(
        (message) {
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        },
        onError: (Object err) {
          AppLogger.e('WebSocket stream error', error: err);
          _stateController.add(WsConnectionState.error);
          _handleConnectionClosedOrFailed();
        },
        onDone: () {
          AppLogger.i('WebSocket stream completed/closed');
          _stateController.add(WsConnectionState.disconnected);
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
      _stateController.add(WsConnectionState.error);
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
    _stateController.add(WsConnectionState.disconnected);
  }

  @disposeMethod
  void dispose() {
    _isDisposed = true;
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}
