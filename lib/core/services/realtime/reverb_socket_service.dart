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
    _reconnectTimer?.cancel();
    _setStatus(_retryAttempt == 0 ? RealtimeStatus.connecting : RealtimeStatus.reconnecting);

    final scheme = useTLS ? 'wss' : 'ws';
    final uri = Uri.parse(
      '$scheme://$wsHost:$wsPort/app/$appKey?protocol=7&client=flutter&version=1.0&flash=false',
    );

    try {
      _socket = WebSocketChannel.connect(uri);
    } catch (_) {
      _scheduleReconnect();
      return;
    }

    _sub = _socket!.stream.listen(
      _onFrame,
      onError: (_) => _scheduleReconnect(),
      onDone: () => _scheduleReconnect(),
      cancelOnError: true,
    );
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _pingTimer?.cancel();
    _socketId = null;
    _setStatus(RealtimeStatus.reconnecting);
    _retryAttempt++;
    final seconds = [1, 2, 4, 8, 15][_retryAttempt.clamp(1, 5) - 1];
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  // ==========================================================================
  // INCOMING FRAMES
  // ==========================================================================

  void _onFrame(dynamic raw) {
    Map<String, dynamic> frame;
    try {
      frame = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final event = frame['event']?.toString();
    final channel = frame['channel']?.toString();
    final rawData = frame['data'];

    if (event == 'pusher:connection_established') {
      final payload = _decodeData(rawData);
      _socketId = payload['socket_id']?.toString();
      _retryAttempt = 0;
      _setStatus(RealtimeStatus.connected);
      _startKeepAlive();
      // Re-subscribe to every channel that was registered before this
      // (re)connect — covers both first connect and reconnects.
      for (final name in _channelHandlers.keys) {
        _authorizeAndSubscribe(name);
      }
      return;
    }

    if (event == 'pusher:ping') {
      _socket?.sink.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      return;
    }

    if (event == 'pusher:error') {
      // Bad/expired auth, over-capacity, etc. Let the reconnect loop retry —
      // a stale bearer token will keep failing until the caller re-logs in,
      // which is a UX concern for the screen, not this transport layer.
      return;
    }

    if (channel == null || event == null) return;
    if (event == 'pusher_internal:subscription_succeeded') return;

    final handlers = _channelHandlers[channel];
    if (handlers == null) return;
    final handler = handlers[event];
    if (handler == null) return;

    handler(_decodeData(rawData));
  }

  Map<String, dynamic> _decodeData(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  void _startKeepAlive() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _socket?.sink.add(jsonEncode({'event': 'pusher:ping', 'data': {}}));
    });
  }

  // ==========================================================================
  // SUBSCRIBE / UNSUBSCRIBE (private channels only)
  // ==========================================================================

  /// Registers [handlers] (event name -> callback) for [channelName] and
  /// subscribes right away if already connected. Safe to call before
  /// [connect] — the subscription is replayed once the socket opens.
  void subscribePrivate(String channelName, Map<String, RealtimeEventHandler> handlers) {
    _channelHandlers[channelName] = handlers;
    if (_socketId != null) {
      _authorizeAndSubscribe(channelName);
    }
  }

  Future<void> _authorizeAndSubscribe(String channelName) async {
    final socketId = _socketId;
    if (socketId == null) return;

    Map<String, dynamic> authRes;
    try {
      authRes = await ApiClient.instance.post('/broadcasting/auth', {
        'socket_id': socketId,
        'channel_name': channelName,
      });
    } catch (_) {
      // Token may have expired mid-session, or the driver isn't
      // linked/checked-in for a vehicle channel (403 per the API docs).
      // Nothing to draw for this channel until the caller fixes that.
      return;
    }

    final auth = authRes['auth']?.toString();
    if (auth == null) return;

    _socket?.sink.add(jsonEncode({
      'event': 'pusher:subscribe',
      'data': {'channel': channelName, 'auth': auth},
    }));
  }

  void unsubscribe(String channelName) {
    _channelHandlers.remove(channelName);
    _socket?.sink.add(jsonEncode({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    }));
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _sub?.cancel();
    _socket?.sink.close();
    _channelHandlers.clear();
    _setStatus(RealtimeStatus.disconnected);
  }
}
