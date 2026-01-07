import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

import 'pty_session.dart';

/// Status of a web session.
enum WebSessionStatus {
  /// Token submitted, waiting for app approval.
  pending,

  /// Session approved by user in Flutter app.
  approved,

  /// Session rejected by user.
  rejected,

  /// Token expired or session timed out.
  expired,

  /// Session actively connected.
  connected,

  /// Session disconnected.
  disconnected,
}

/// A web terminal session representing a single WebSocket connection.
class WebSession {
  /// Unique identifier for this session.
  final String id;

  /// ID of the token used to authenticate.
  final String tokenId;

  /// When the session was created.
  final DateTime createdAt;

  /// Client IP address.
  final String clientAddress;

  /// Client user agent string.
  final String? userAgent;

  /// Current session status.
  WebSessionStatus status;

  /// Active PTY sessions for this WebSocket connection.
  final Map<String, PtySession> ptySessions = {};

  /// The WebSocket channel for this session.
  WebSocketChannel? _channel;

  /// Stream controller for session events.
  final _eventController = StreamController<WsSessionInternalEvent>.broadcast();

  /// Host instance for creating PTY sessions.
  Host? _host;

  WebSession({
    required this.id,
    required this.tokenId,
    required this.clientAddress,
    this.userAgent,
    this.status = WebSessionStatus.pending,
  }) : createdAt = DateTime.now();

  /// Stream of session events.
  Stream<WsSessionInternalEvent> get events => _eventController.stream;

  /// Whether the session is connected.
  bool get isConnected => _channel != null && status == WebSessionStatus.connected;

  /// Number of active PTY sessions.
  int get ptyCount => ptySessions.length;

  /// Attach a WebSocket channel to this session.
  void attach(WebSocketChannel channel) {
    _channel = channel;
    if (status == WebSessionStatus.approved) {
      status = WebSessionStatus.connected;
    }
  }

  /// Detach the WebSocket channel.
  void detach() {
    _channel = null;
    if (status == WebSessionStatus.connected) {
      status = WebSessionStatus.disconnected;
    }
    closeAllPtys();
  }

  /// Initialize the host for PTY sessions.
  Future<void> initializeHost() async {
    _host ??= LocalHost();
  }

  /// Create a new PTY session.
  Future<PtySession> createPty({
    required String ptyId,
    required int cols,
    required int rows,
    Map<String, String>? environment,
  }) async {
    if (_host == null) {
      await initializeHost();
    }

    final executionSession = await _host!.shell(
      width: cols,
      height: rows,
      environment: environment,
    );

    final ptySession = PtySession(
      id: ptyId,
      executionSession: executionSession,
      onOutput: _onPtyOutput,
      onExit: _onPtyExit,
    );

    ptySessions[ptyId] = ptySession;
    _eventController.add(WsPtyCreatedEvent(ptyId));

    return ptySession;
  }

  /// Close a specific PTY session.
  Future<void> closePty(String ptyId) async {
    final pty = ptySessions.remove(ptyId);
    if (pty != null) {
      await pty.close();
      _eventController.add(WsPtyClosedEvent(ptyId, 0));
    }
  }

  /// Close all PTY sessions.
  void closeAllPtys() {
    for (final pty in ptySessions.values) {
      pty.close();
    }
    ptySessions.clear();
  }

  /// Send data through the WebSocket.
  void send(dynamic data) {
    _channel?.sink.add(data);
  }

  /// Handle PTY output data.
  void _onPtyOutput(String ptyId, Uint8List data) {
    _eventController.add(WsPtyOutputEvent(ptyId, data));
  }

  /// Handle PTY exit.
  void _onPtyExit(String ptyId, int exitCode) {
    ptySessions.remove(ptyId);
    _eventController.add(WsPtyClosedEvent(ptyId, exitCode));
  }

  /// Close the session and cleanup.
  Future<void> close() async {
    closeAllPtys();
    await _channel?.sink.close();
    await _eventController.close();
    _host = null;
  }

  /// Convert to JSON for serialization.
  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenId': tokenId,
        'createdAt': createdAt.toIso8601String(),
        'clientAddress': clientAddress,
        'userAgent': userAgent,
        'status': status.name,
        'ptyCount': ptyCount,
      };
}

/// Base class for internal web session PTY events.
sealed class WsSessionInternalEvent {
  const WsSessionInternalEvent();
}

/// Event: PTY session created.
class WsPtyCreatedEvent extends WsSessionInternalEvent {
  final String ptyId;
  const WsPtyCreatedEvent(this.ptyId);
}

/// Event: PTY output received.
class WsPtyOutputEvent extends WsSessionInternalEvent {
  final String ptyId;
  final Uint8List data;
  const WsPtyOutputEvent(this.ptyId, this.data);
}

/// Event: PTY session closed.
class WsPtyClosedEvent extends WsSessionInternalEvent {
  final String ptyId;
  final int exitCode;
  const WsPtyClosedEvent(this.ptyId, this.exitCode);
}
