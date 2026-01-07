import 'dart:convert';
import 'dart:typed_data';

/// Base class for WebSocket messages.
sealed class WsMessage {
  const WsMessage();

  String get type;

  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());
}

// ============================================================================
// Authentication Messages
// ============================================================================

/// Client sends token for authentication.
class AuthRequest extends WsMessage {
  @override
  final String type = 'auth';

  final String token;

  const AuthRequest({required this.token});

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'token': token,
      };

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      AuthRequest(token: json['token'] as String);
}

/// Server response to authentication.
class AuthResponse extends WsMessage {
  @override
  final String type = 'auth_response';

  final bool success;
  final String? sessionId;
  final String? error;

  const AuthResponse({
    required this.success,
    this.sessionId,
    this.error,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'success': success,
        if (sessionId != null) 'sessionId': sessionId,
        if (error != null) 'error': error,
      };

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json['success'] as bool,
        sessionId: json['sessionId'] as String?,
        error: json['error'] as String?,
      );
}

/// Server notifies client about session status.
class SessionStatus extends WsMessage {
  @override
  final String type = 'session_status';

  final String status; // 'pending', 'approved', 'rejected', 'expired'
  final String? message;

  const SessionStatus({
    required this.status,
    this.message,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'status': status,
        if (message != null) 'message': message,
      };

  factory SessionStatus.fromJson(Map<String, dynamic> json) => SessionStatus(
        status: json['status'] as String,
        message: json['message'] as String?,
      );
}

// ============================================================================
// PTY Session Messages
// ============================================================================

/// Client requests to create a PTY session.
class CreatePtyRequest extends WsMessage {
  @override
  final String type = 'create_pty';

  final String ptyId;
  final int cols;
  final int rows;
  final Map<String, String>? env;

  const CreatePtyRequest({
    required this.ptyId,
    required this.cols,
    required this.rows,
    this.env,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ptyId': ptyId,
        'cols': cols,
        'rows': rows,
        if (env != null) 'env': env,
      };

  factory CreatePtyRequest.fromJson(Map<String, dynamic> json) =>
      CreatePtyRequest(
        ptyId: json['ptyId'] as String,
        cols: (json['cols'] as int?) ?? 80,
        rows: (json['rows'] as int?) ?? 24,
        env: json['env'] != null
            ? Map<String, String>.from(json['env'] as Map)
            : null,
      );
}

/// Server response to PTY creation.
class CreatePtyResponse extends WsMessage {
  @override
  final String type = 'create_pty_response';

  final String ptyId;
  final bool success;
  final String? error;

  const CreatePtyResponse({
    required this.ptyId,
    required this.success,
    this.error,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ptyId': ptyId,
        'success': success,
        if (error != null) 'error': error,
      };

  factory CreatePtyResponse.fromJson(Map<String, dynamic> json) =>
      CreatePtyResponse(
        ptyId: json['ptyId'] as String,
        success: json['success'] as bool,
        error: json['error'] as String?,
      );
}

/// Client requests to close a PTY session.
class ClosePtyRequest extends WsMessage {
  @override
  final String type = 'close_pty';

  final String ptyId;

  const ClosePtyRequest({required this.ptyId});

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ptyId': ptyId,
      };

  factory ClosePtyRequest.fromJson(Map<String, dynamic> json) =>
      ClosePtyRequest(ptyId: json['ptyId'] as String);
}

/// Server response to PTY close or PTY exit event.
class PtyExited extends WsMessage {
  @override
  final String type = 'pty_exited';

  final String ptyId;
  final int exitCode;

  const PtyExited({
    required this.ptyId,
    required this.exitCode,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ptyId': ptyId,
        'exitCode': exitCode,
      };

  factory PtyExited.fromJson(Map<String, dynamic> json) => PtyExited(
        ptyId: json['ptyId'] as String,
        exitCode: json['exitCode'] as int,
      );
}

/// Client requests to resize a PTY.
class ResizePtyRequest extends WsMessage {
  @override
  final String type = 'resize_pty';

  final String ptyId;
  final int cols;
  final int rows;

  const ResizePtyRequest({
    required this.ptyId,
    required this.cols,
    required this.rows,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'ptyId': ptyId,
        'cols': cols,
        'rows': rows,
      };

  factory ResizePtyRequest.fromJson(Map<String, dynamic> json) =>
      ResizePtyRequest(
        ptyId: json['ptyId'] as String,
        cols: json['cols'] as int,
        rows: json['rows'] as int,
      );
}

// ============================================================================
// Heartbeat Messages
// ============================================================================

/// Client ping.
class Ping extends WsMessage {
  @override
  final String type = 'ping';

  const Ping();

  @override
  Map<String, dynamic> toJson() => {'type': type};

  factory Ping.fromJson(Map<String, dynamic> json) => const Ping();
}

/// Server pong.
class Pong extends WsMessage {
  @override
  final String type = 'pong';

  const Pong();

  @override
  Map<String, dynamic> toJson() => {'type': type};

  factory Pong.fromJson(Map<String, dynamic> json) => const Pong();
}

// ============================================================================
// Error Message
// ============================================================================

/// Generic error message.
class ErrorMessage extends WsMessage {
  @override
  final String type = 'error';

  final String code;
  final String message;

  const ErrorMessage({
    required this.code,
    required this.message,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'message': message,
      };

  factory ErrorMessage.fromJson(Map<String, dynamic> json) => ErrorMessage(
        code: json['code'] as String,
        message: json['message'] as String,
      );
}

// ============================================================================
// Message Parsing
// ============================================================================

/// Parse a JSON message from string.
WsMessage? parseMessage(String jsonString) {
  try {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return parseMessageFromJson(json);
  } catch (e) {
    return null;
  }
}

/// Parse a message from JSON map.
WsMessage? parseMessageFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  if (type == null) return null;

  return switch (type) {
    'auth' => AuthRequest.fromJson(json),
    'auth_response' => AuthResponse.fromJson(json),
    'session_status' => SessionStatus.fromJson(json),
    'create_pty' => CreatePtyRequest.fromJson(json),
    'create_pty_response' => CreatePtyResponse.fromJson(json),
    'close_pty' => ClosePtyRequest.fromJson(json),
    'pty_exited' => PtyExited.fromJson(json),
    'resize_pty' => ResizePtyRequest.fromJson(json),
    'ping' => Ping.fromJson(json),
    'pong' => Pong.fromJson(json),
    'error' => ErrorMessage.fromJson(json),
    _ => null,
  };
}

// ============================================================================
// Binary Protocol for Terminal I/O
// ============================================================================

/// Encode terminal input/output as binary frame.
/// Format: [1 byte: ptyId length][ptyId bytes][terminal data]
Uint8List encodeBinaryFrame(String ptyId, Uint8List data) {
  final ptyIdBytes = utf8.encode(ptyId);
  final result = Uint8List(1 + ptyIdBytes.length + data.length);
  result[0] = ptyIdBytes.length;
  result.setRange(1, 1 + ptyIdBytes.length, ptyIdBytes);
  result.setRange(1 + ptyIdBytes.length, result.length, data);
  return result;
}

/// Decode binary frame to get ptyId and data.
/// Returns null if frame is malformed.
({String ptyId, Uint8List data})? decodeBinaryFrame(Uint8List frame) {
  if (frame.isEmpty) return null;

  final ptyIdLength = frame[0];
  if (frame.length < 1 + ptyIdLength) return null;

  final ptyIdBytes = frame.sublist(1, 1 + ptyIdLength);
  final ptyId = utf8.decode(ptyIdBytes);
  final data = frame.sublist(1 + ptyIdLength);

  return (ptyId: ptyId, data: Uint8List.fromList(data));
}
