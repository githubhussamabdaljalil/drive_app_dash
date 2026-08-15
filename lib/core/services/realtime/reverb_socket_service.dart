import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/api_client.dart';

/// Connection status exposed to listeners (drive a small badge in the UI).
enum RealtimeStatus { disconnected, connecting, connected, reconnecting }

typedef RealtimeEventHandler = void Function(Map<String, dynamic> data);

/// Minimal Pusher-protocol (v7) client over a raw WebSocket — works against
/// Laravel Reverb, which speaks the same protocol.
///
/// Not a singleton on purpose: each screen that needs live data creates its
/// own instance and disposes it when it's done (mirrors the driver app's
/// "start on check-in, stop on check-out" pattern from FRONTEND_QUICKSTART).
///
/// Only handles PRIVATE channels (auth via POST /broadcasting/auth), which is
/// all the manager dashboard needs. Public/guest channels don't need this.
class ReverbSocketService {
  ReverbSocketService({
    required this.wsHost,
    this.wsPort = 443,
    this.useTLS = true,
    required this.appKey,
    this.onStatusChange,
  });

  final String wsHost;
  final int wsPort;
  final bool useTLS;
  final String appKey;
  final void Function(RealtimeStatus status)? onStatusChange;

  WebSocketChannel? _socket;
  StreamSubscription? _sub;
  String? _socketId;

  bool _disposed = false;
  bool _connecting = false;

  int _retryAttempt = 0;

  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final Map<String, Map<String, RealtimeEventHandler>> _channelHandlers = {};

  RealtimeStatus _status = RealtimeStatus.disconnected;

  RealtimeStatus get status => _status;

  void _setStatus(RealtimeStatus s) {
    _status = s;
    onStatusChange?.call(s);
  }

  // ==========================================================================
  // CONNECT
  // ==========================================================================

  void connect() {
    if (_disposed) return;

    // Prevent opening multiple WebSocket connections at the same time.
    if (_connecting || _status == RealtimeStatus.connected) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _connecting = true;

    _setStatus(
      _retryAttempt == 0
          ? RealtimeStatus.connecting
          : RealtimeStatus.reconnecting,
    );

    final scheme = useTLS ? 'wss' : 'ws';

    final uri = Uri.parse(
      '$scheme://$wsHost:$wsPort/app/$appKey'
      '?protocol=7'
      '&client=flutter'
      '&version=1.0'
      '&flash=false',
    );

    // Close any old socket/subscription before opening a new one.
    _sub?.cancel();
    _sub = null;

    try {
      _socket?.sink.close();
    } catch (_) {}

    _socket = null;

    try {
      _socket = WebSocketChannel.connect(uri);

      _sub = _socket!.stream.listen(
        _onFrame,
        onError: (error) {
          _log('WebSocket error: $error');
          _handleConnectionFailure();
        },
        onDone: () {
          _log('WebSocket connection closed.');
          _handleConnectionFailure();
        },
        cancelOnError: false,
      );
    } catch (error) {
      _log('WebSocket connection exception: $error');
      _handleConnectionFailure();
    }
  }

  void _handleConnectionFailure() {
    if (_disposed) return;

    _connecting = false;

    _pingTimer?.cancel();
    _pingTimer = null;

    _socketId = null;

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;

    // Don't create multiple reconnect timers.
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }

    _connecting = false;

    _pingTimer?.cancel();
    _pingTimer = null;

    _socketId = null;

    _setStatus(RealtimeStatus.reconnecting);

    _retryAttempt++;

    final retryIndex = _retryAttempt.clamp(1, 5) - 1;

    final seconds = [1, 2, 4, 8, 15][retryIndex];

    _log(
      'Reverb reconnect scheduled in $seconds seconds '
      '(attempt $_retryAttempt).',
    );

    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      connect();
    });
  }

  // ==========================================================================
  // INCOMING FRAMES
  // ==========================================================================

  void _onFrame(dynamic raw) {
    if (_disposed) return;

    Map<String, dynamic> frame;

    try {
      if (raw is String) {
        final decoded = jsonDecode(raw);

        if (decoded is! Map) {
          _log('Received non-map WebSocket frame: $raw');
          return;
        }

        frame = Map<String, dynamic>.from(decoded);
      } else if (raw is List<int>) {
        final decoded = jsonDecode(utf8.decode(raw));

        if (decoded is! Map) {
          _log('Received invalid binary WebSocket frame.');
          return;
        }

        frame = Map<String, dynamic>.from(decoded);
      } else {
        _log('Received unsupported WebSocket frame type: ${raw.runtimeType}');
        return;
      }
    } catch (error) {
      _log('Failed to decode WebSocket frame: $error');
      return;
    }

    final event = frame['event']?.toString();
    final channel = frame['channel']?.toString();
    final rawData = frame['data'];

    _log(
      'Reverb event: event=$event, '
      'channel=$channel, '
      'data=$rawData',
    );

    // ========================================================================
    // CONNECTION ESTABLISHED
    // ========================================================================

    if (event == 'pusher:connection_established') {
      final payload = _decodeData(rawData);

      _socketId = payload['socket_id']?.toString();

      if (_socketId == null || _socketId!.isEmpty) {
        _log(
          'pusher:connection_established received but socket_id is missing.',
        );

        _handleConnectionFailure();
        return;
      }

      // Connection is now fully established.
      _connecting = false;

      // Reset retry counter after successful connection.
      _retryAttempt = 0;

      _setStatus(RealtimeStatus.connected);

      _startKeepAlive();

      _log('Reverb connected. Socket ID: $_socketId');

      // Re-subscribe to every channel that was registered before this
      // (re)connect — covers both first connect and reconnects.
      for (final name in _channelHandlers.keys) {
        if (name.startsWith('private-')) {
          _authorizeAndSubscribe(name);
        } else {
          _sendFrame({
            'event': 'pusher:subscribe',
            'data': {'channel': name},
          });
        }
      }

      return;
    }

    // ========================================================================
    // SERVER PING
    // ========================================================================

    if (event == 'pusher:ping') {
      _sendFrame({'event': 'pusher:pong', 'data': {}});

      return;
    }

    // ========================================================================
    // SERVER ERROR
    // ========================================================================

    if (event == 'pusher:error') {
      final payload = _decodeData(rawData);

      final code = payload['code']?.toString();
      final message = payload['message']?.toString();

      _log(
        'Pusher/Reverb ERROR'
        '${code != null ? ' | code=$code' : ''}'
        '${message != null ? ' | message=$message' : ''}',
      );

      // IMPORTANT:
      //
      // Previously this block only returned:
      //
      //   return;
      //
      // That caused the UI to remain forever in "connecting" when Reverb
      // returned a pusher:error frame without closing the socket.
      //
      // We now explicitly handle the failed connection and start the
      // reconnect mechanism.

      _handleConnectionFailure();

      return;
    }

    // ========================================================================
    // SUBSCRIPTION ERROR
    // ========================================================================

    if (event == 'pusher:subscription_error') {
      final payload = _decodeData(rawData);

      final code = payload['code']?.toString();
      final message = payload['message']?.toString();

      _log(
        'Subscription error'
        '${channel != null ? ' | channel=$channel' : ''}'
        '${code != null ? ' | code=$code' : ''}'
        '${message != null ? ' | message=$message' : ''}',
      );

      // This is a channel-level error, not necessarily a socket-level error.
      //
      // We intentionally DON'T reconnect the whole socket here.
      // The socket itself may still be perfectly healthy.
      return;
    }

    // ========================================================================
    // SUBSCRIPTION SUCCESS
    // ========================================================================

    if (event == 'pusher_internal:subscription_succeeded') {
      _log(
        'Successfully subscribed to channel: '
        '${channel ?? 'unknown'}',
      );

      return;
    }

    // ========================================================================
    // OTHER EVENTS
    // ========================================================================

    if (channel == null || event == null) {
      return;
    }

    final handlers = _channelHandlers[channel];

    if (handlers == null) {
      _log(
        'Received event for unregistered channel: '
        '$channel',
      );

      return;
    }

    final handler = handlers[event];

    if (handler == null) {
      _log(
        'No handler registered for event "$event" '
        'on channel "$channel".',
      );

      return;
    }

    try {
      handler(_decodeData(rawData));
    } catch (error) {
      _log(
        'Realtime event handler failed '
        '(event=$event, channel=$channel): $error',
      );
    }
  }

  Map<String, dynamic> _decodeData(dynamic rawData) {
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }

    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (error) {
        _log('Failed to decode frame data: $error');
      }
    }

    return {};
  }

  // ==========================================================================
  // KEEP ALIVE
  // ==========================================================================

  void _startKeepAlive() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_disposed) return;

      if (_socketId == null) {
        return;
      }

      _sendFrame({'event': 'pusher:ping', 'data': {}});
    });
  }

  // ==========================================================================
  // SEND FRAME
  // ==========================================================================

  void _sendFrame(Map<String, dynamic> frame) {
    if (_disposed) return;

    try {
      _socket?.sink.add(jsonEncode(frame));
    } catch (error) {
      _log('Failed to send WebSocket frame: $error');
      _handleConnectionFailure();
    }
  }

  // ==========================================================================
  // SUBSCRIBE / UNSUBSCRIBE (private channels only)
  // ==========================================================================

  /// Registers [handlers] for a **public** channel and subscribes right away
  /// if already connected. Public channels don't need auth.
  void subscribePublic(
    String channelName,
    Map<String, RealtimeEventHandler> handlers,
  ) {
    if (_disposed) return;

    _channelHandlers[channelName] = handlers;

    _log('Registered public channel: $channelName');

    if (_socketId != null) {
      _sendFrame({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName},
      });
    }
  }

  /// Registers [handlers] (event name -> callback) for [channelName] and
  /// subscribes right away if already connected. Safe to call before
  /// [connect] — the subscription is replayed once the socket opens.
  void subscribePrivate(
    String channelName,
    Map<String, RealtimeEventHandler> handlers,
  ) {
    if (_disposed) return;

    _channelHandlers[channelName] = handlers;

    _log('Registered private channel: $channelName');

    if (_socketId != null) {
      _authorizeAndSubscribe(channelName);
    }
  }

  Future<void> _authorizeAndSubscribe(String channelName) async {
    final socketId = _socketId;

    if (socketId == null || socketId.isEmpty) {
      _log('Cannot subscribe to $channelName: socket ID is null.');

      return;
    }

    Map<String, dynamic> authRes;

    try {
      _log(
        'Authorizing private channel: '
        '$channelName',
      );

      authRes = await ApiClient.instance.post('/broadcasting/auth', {
        'socket_id': socketId,
        'channel_name': channelName,
      });
    } catch (error) {
      // Token may have expired mid-session, or the driver isn't
      // linked/checked-in for a vehicle channel (403 per the API docs).
      // Nothing to draw for this channel until the caller fixes that.

      _log(
        'Private channel authorization failed '
        '(channel=$channelName): $error',
      );

      return;
    }

    // Socket might have been disconnected while the auth request was running.
    if (_disposed) return;

    if (_socketId != socketId) {
      _log(
        'Socket changed while authorizing $channelName. '
        'Skipping old authorization response.',
      );

      return;
    }

    final auth = authRes['auth']?.toString();

    if (auth == null || auth.isEmpty) {
      _log(
        'Broadcasting auth response did not contain "auth" '
        'for channel $channelName.',
      );

      return;
    }

    _sendFrame({
      'event': 'pusher:subscribe',
      'data': {'channel': channelName, 'auth': auth},
    });

    _log(
      'Subscription request sent for channel: '
      '$channelName',
    );
  }

  void unsubscribe(String channelName) {
    _channelHandlers.remove(channelName);

    _log('Unsubscribing from channel: $channelName');

    _sendFrame({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    });
  }

  // ==========================================================================
  // LOGGING
  // ==========================================================================

  void _log(String message) {
    // ignore: avoid_print
    print('[ReverbSocketService] $message');
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  void dispose() {
    if (_disposed) return;

    _disposed = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _pingTimer?.cancel();
    _pingTimer = null;

    _socketId = null;
    _connecting = false;

    _sub?.cancel();
    _sub = null;

    try {
      _socket?.sink.close();
    } catch (_) {}

    _socket = null;

    _channelHandlers.clear();

    _setStatus(RealtimeStatus.disconnected);
  }
}
