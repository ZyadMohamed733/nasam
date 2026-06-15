import 'dart:async';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/app_logger.dart';

enum WsConnectionState { connecting, connected, disconnected, error }

@lazySingleton
class WebSocketService {
  WebSocketService() {
    _stateController.add(WsConnectionState.disconnected);
  }

  WebSocketChannel? _channel;
  final StreamController<WsConnectionState> _stateController = StreamController<WsConnectionState>.broadcast();
  final StreamController<dynamic> _messageController = StreamController<dynamic>.broadcast();

  Stream<WsConnectionState> get connectionState => _stateController.stream;
  Stream<dynamic> get messages => _messageController.stream;

  bool _isDisposed = false;
  bool _shouldReconnect = false;
  int _reconnectDelaySecs = 1;

  void connect() {
    if (_isDisposed) return;
    _shouldReconnect = true;
    _establishConnection();
  }

  void _establishConnection() {
    if (_channel != null || _isDisposed) return;

    final wsUrl = dotenv.env['WS_URL'] ?? 'wss://ws.nasam.app';
    AppLogger.i('Connecting to WebSocket: $wsUrl');
    _stateController.add(WsConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _stateController.add(WsConnectionState.connected);
      _reconnectDelaySecs = 1; // Reset backoff delay on successful connection

      _channel!.stream.listen(
        (message) {
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        },
        onError: (err) {
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
      AppLogger.e('Failed to initiate WebSocket connection', error: e, stackTrace: stack);
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
      // Exponential backoff formula (capped at 30s)
      _reconnectDelaySecs = min(30, _reconnectDelaySecs * 2);
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
