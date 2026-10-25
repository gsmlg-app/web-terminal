import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

import 'pty_session.dart';

/// Status of a web session.
enum WebSessionStatus {
  /// Session created, waiting for app approval.
  pending,

  /// Session approved by user in Flutter app.
  approved,

  /// Session rejected by user.
  rejected,

  /// Session expired.
  expired,

  /// Session actively connected via WebSocket.
  connected,

  /// Session disconnected.
  disconnected,
}

/// PTY size data for a session.
class PtySize {
  final int cols;
  final int rows;

  const PtySize({required this.cols, required this.rows});
}

/// A web terminal session representing a browser connection.
///
/// Sessions are created when a browser first accesses the web terminal.
/// Each session gets a unique ID (stored in HTTP-only cookie) and a
/// 6-character approval code that the user must approve in the Flutter app.
class WebSession {
  /// Unique identifier for this session (stored in cookie).
  final String id;

  /// 6-character approval code shown to user for approval.
  final String approvalCode;

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
  bool _wasApproved = false;
  bool _closed = false;
  Future<void>? _closeFuture;
  final _pendingPtys = <String, Future<PtySession>>{};

  WebSession({
    required this.id,
    required this.approvalCode,
    required this.clientAddress,
    this.userAgent,
    this.status = WebSessionStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Generate a random 6-character approval code.
  static String generateApprovalCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude confusing chars
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Stream of session events.
  Stream<WsSessionInternalEvent> get events => _eventController.stream;

  /// Whether the session is connected via WebSocket.
  bool get isConnected =>
      _channel != null && status == WebSessionStatus.connected;

  /// Whether the session is approved (can connect WebSocket).
  bool get isApproved =>
      !_closed &&
      (status == WebSessionStatus.approved ||
          status == WebSessionStatus.connected ||
          (status == WebSessionStatus.disconnected && _wasApproved));

  /// Whether the session is pending approval.
  bool get isPending => status == WebSessionStatus.pending;

  /// Number of active PTY sessions.
  int get ptyCount => ptySessions.length;

  /// PTY size map for matching client dimensions.
  final Map<String, PtySize> ptySizes = {};

  /// PTY output buffers for attach viewer.
  final Map<String, String> ptyBuffers = {};

  /// Total bytes received from client.
  int bytesReceived = 0;

  /// Total bytes sent to client.
  int bytesSent = 0;

  /// Current inbound transfer rate in bytes/sec.
  double inboundRate = 0;

  /// Current outbound transfer rate in bytes/sec.
  double outboundRate = 0;

  /// Latest measured latency in milliseconds.
  int? latencyMs;

  int _lastBytesReceived = 0;
  int _lastBytesSent = 0;
  DateTime _lastRateSampleAt = DateTime.now();

  /// Record bytes received from client.
  bool recordIncomingBytes(int bytes) {
    bytesReceived += bytes;
    return _updateRates();
  }

  /// Record bytes sent to client.
  bool recordOutgoingBytes(int bytes) {
    bytesSent += bytes;
    return _updateRates();
  }

  /// Update latency measurement.
  void updateLatency(int latencyMs) {
    this.latencyMs = latencyMs;
  }

  bool _updateRates() {
    final now = DateTime.now();
    final elapsedMs = now.difference(_lastRateSampleAt).inMilliseconds;
    if (elapsedMs < 1000) {
      return false;
    }

    final elapsedSeconds = elapsedMs / 1000;
    inboundRate = (bytesReceived - _lastBytesReceived) / elapsedSeconds;
    outboundRate = (bytesSent - _lastBytesSent) / elapsedSeconds;
    _lastBytesReceived = bytesReceived;
    _lastBytesSent = bytesSent;
    _lastRateSampleAt = now;
    return true;
  }

  /// Attach a WebSocket channel to this session.
  void attach(WebSocketChannel channel) {
    if (_closed) return;
    if (isApproved) {
      _wasApproved = true;
      status = WebSessionStatus.connected;
    }
    _channel = channel;
  }

  /// Detach the WebSocket channel.
  void detach({bool preservePtys = false}) {
    _channel = null;
    if (status == WebSessionStatus.connected) {
      _wasApproved = true;
      status = WebSessionStatus.disconnected;
    }
    if (!preservePtys) unawaited(closeAllPtys());
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
  }) {
    final existing = ptySessions[ptyId];
    if (existing != null) return Future.value(existing);
    return _pendingPtys.putIfAbsent(
      ptyId,
      () => _createPty(ptyId, cols, rows, environment),
    );
  }

  Future<PtySession> _createPty(
    String ptyId,
    int cols,
    int rows,
    Map<String, String>? environment,
  ) async {
    try {
      if (_closed) throw StateError('Session is closed');
      if (_host == null) {
        await initializeHost();
      }

      final executionSession = await _host!.shell(
        width: cols,
        height: rows,
        environment: environment,
      );
      if (_closed) {
        await executionSession.close();
        throw StateError('Session is closed');
      }

      final ptySession = PtySession(
        id: ptyId,
        executionSession: executionSession,
        onOutput: _onPtyOutput,
        onExit: _onPtyExit,
      );

      ptySessions[ptyId] = ptySession;
      ptySizes[ptyId] = PtySize(cols: cols, rows: rows);
      ptyBuffers[ptyId] = '';
      _eventController.add(WsPtyCreatedEvent(ptyId));

      return ptySession;
    } finally {
      _pendingPtys.remove(ptyId);
    }
  }

  /// Close a specific PTY session.
  Future<void> closePty(String ptyId) async {
    final pty = ptySessions.remove(ptyId);
    if (pty != null) {
      await pty.close();
      ptySizes.remove(ptyId);
      ptyBuffers.remove(ptyId);
      _eventController.add(WsPtyClosedEvent(ptyId, 0));
    }
  }

  /// Close all PTY sessions.
  Future<void> closeAllPtys() async {
    final ptys = ptySessions.values.toList();
    ptySessions.clear();
    ptySizes.clear();
    ptyBuffers.clear();
    await Future.wait(ptys.map((pty) => pty.close()));
  }

  /// Update PTY size and notify listeners.
  void updatePtySize(String ptyId, int cols, int rows) {
    if (!ptySessions.containsKey(ptyId)) return;
    ptySizes[ptyId] = PtySize(cols: cols, rows: rows);
    _eventController.add(WsPtyResizedEvent(ptyId, cols, rows));
  }

  /// Append output to PTY buffer for attach view.
  void appendPtyBuffer(String ptyId, String chunk) {
    if (!ptyBuffers.containsKey(ptyId)) {
      return;
    }
    const maxBufferSize = 100000;
    final updated = ptyBuffers[ptyId]! + chunk;
    if (updated.length > maxBufferSize) {
      ptyBuffers[ptyId] = updated.substring(updated.length - maxBufferSize);
    } else {
      ptyBuffers[ptyId] = updated;
    }
  }

  /// Get buffered output for a PTY.
  String getPtyBuffer(String ptyId) => ptyBuffers[ptyId] ?? '';

  /// Send data through the WebSocket.
  void send(dynamic data) {
    _channel?.sink.add(data);
  }

  /// Handle PTY output data.
  void _onPtyOutput(String ptyId, Uint8List data) {
    if (_closed) return;
    appendPtyBuffer(ptyId, String.fromCharCodes(data));
    _eventController.add(WsPtyOutputEvent(ptyId, data));
  }

  /// Handle PTY exit.
  void _onPtyExit(String ptyId, int exitCode) {
    if (_closed) return;
    ptySessions.remove(ptyId);
    ptySizes.remove(ptyId);
    _eventController.add(WsPtyClosedEvent(ptyId, exitCode));
  }

  /// Close the session and cleanup.
  Future<void> close() => _closeFuture ??= _close();

  Future<void> _close() async {
    _closed = true;
    _wasApproved = false;
    final channel = _channel;
    _channel = null;
    await closeAllPtys();
    await channel?.sink.close();
    await _eventController.close();
    _host = null;
  }

  /// Convert to JSON for serialization.
  Map<String, dynamic> toJson() => {
        'id': id,
        'approvalCode': approvalCode,
        'createdAt': createdAt.toIso8601String(),
        'clientAddress': clientAddress,
        'userAgent': userAgent,
        'status': status.name,
        'ptyCount': ptyCount,
        'bytesReceived': bytesReceived,
        'bytesSent': bytesSent,
        'inboundRate': inboundRate,
        'outboundRate': outboundRate,
        'latencyMs': latencyMs,
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

/// Event: PTY resized.
class WsPtyResizedEvent extends WsSessionInternalEvent {
  final String ptyId;
  final int cols;
  final int rows;
  const WsPtyResizedEvent(this.ptyId, this.cols, this.rows);
}
