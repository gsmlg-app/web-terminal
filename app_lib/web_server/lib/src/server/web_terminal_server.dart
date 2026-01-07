import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/server_config.dart';
import '../protocol/message.dart';
import '../session/session.dart';
import '../session/session_manager.dart';
import '../session/session_token.dart';

/// Web terminal server using Shelf.
class WebTerminalServer {
  final ServerConfig config;
  final SessionManager sessionManager;

  HttpServer? _server;
  final _connections = <String, _WebSocketConnection>{};

  WebTerminalServer({
    required this.config,
    required this.sessionManager,
  });

  /// Whether the server is running.
  bool get isRunning => _server != null;

  /// Server address.
  String? get address => _server?.address.address;

  /// Server port.
  int? get port => _server?.port;

  /// Start the server.
  Future<void> start() async {
    if (_server != null) {
      throw StateError('Server is already running');
    }

    // Ensure static files directory exists
    final staticDir = Directory(config.staticFilesPath);
    if (!await staticDir.exists()) {
      await staticDir.create(recursive: true);
    }

    final router = Router();

    // WebSocket endpoint
    router.get('/ws', _webSocketHandler());

    // API endpoints
    router.get('/api/health', _healthHandler);

    // Check if static files exist
    final indexFile = File('${config.staticFilesPath}/index.html');
    final hasStaticFiles = await indexFile.exists();

    // Static file handler for web frontend (or fallback)
    Handler staticHandler;
    if (hasStaticFiles) {
      staticHandler = createStaticHandler(
        config.staticFilesPath,
        defaultDocument: 'index.html',
      );
    } else {
      // Fallback handler when no static files are present
      staticHandler = _noStaticFilesHandler;
    }

    // Combine handlers
    final handler = const Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(Cascade().add(router.call).add(staticHandler).handler);

    // Start server
    final bindAddress = config.bindAddress ?? InternetAddress.anyIPv4.address;
    _server = await shelf_io.serve(
      handler,
      bindAddress,
      config.port,
    );

    // Subscribe to session manager events for approval notifications
    _subscribeToSessionEvents();
  }

  /// Fallback handler when static files are not available.
  Response _noStaticFilesHandler(Request request) {
    return Response.ok(
      '''
<!DOCTYPE html>
<html>
<head>
  <title>Web Terminal - Setup Required</title>
  <style>
    body { font-family: system-ui; background: #1e1e2e; color: #cdd6f4;
           display: flex; justify-content: center; align-items: center;
           height: 100vh; margin: 0; }
    .card { background: #313244; padding: 40px; border-radius: 16px;
            text-align: center; max-width: 500px; }
    h1 { color: #cba6f7; }
    p { color: #a6adc8; line-height: 1.6; }
    code { background: #45475a; padding: 2px 8px; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Web Terminal</h1>
    <p>The web client files are not installed yet.</p>
    <p>To install, run:</p>
    <p><code>cd web/terminal-client && npm install && npm run build</code></p>
    <p>Then copy the <code>dist/</code> contents to the app's static files directory.</p>
  </div>
</body>
</html>
''',
      headers: {'Content-Type': 'text/html'},
    );
  }

  /// Stop the server.
  Future<void> stop() async {
    // Close all WebSocket connections
    for (final conn in _connections.values) {
      await conn.close();
    }
    _connections.clear();

    // Close server
    await _server?.close();
    _server = null;
  }

  /// CORS middleware.
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }

        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
        'Access-Control-Allow-Origin': config.allowedOrigins.contains('*')
            ? '*'
            : config.allowedOrigins.join(', '),
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      };

  /// Health check handler.
  Response _healthHandler(Request request) {
    return Response.ok('{"status": "ok"}',
        headers: {'Content-Type': 'application/json'});
  }

  /// WebSocket handler.
  Handler _webSocketHandler() {
    return webSocketHandler((WebSocketChannel channel, String? protocol) {
      _handleWebSocket(channel);
    });
  }

  /// Handle a new WebSocket connection.
  void _handleWebSocket(WebSocketChannel channel) {
    final connection = _WebSocketConnection(
      channel: channel,
      server: this,
    );
    connection.start();
  }

  /// Subscribe to session manager events.
  void _subscribeToSessionEvents() {
    sessionManager.events.listen((event) {
      switch (event) {
        case SessionApprovedEvent(:final session):
          _notifySessionApproved(session);
        case SessionRejectedEvent(:final session):
          _notifySessionRejected(session);
        default:
          break;
      }
    });
  }

  /// Notify WebSocket connection that session was approved.
  void _notifySessionApproved(WebSession session) {
    final conn = _connections[session.id];
    if (conn != null) {
      session.status = WebSessionStatus.connected;
      conn.sendMessage(const SessionStatus(
        status: 'approved',
        message: 'Session approved',
      ));
    }
  }

  /// Notify WebSocket connection that session was rejected.
  void _notifySessionRejected(WebSession session) {
    final conn = _connections[session.id];
    if (conn != null) {
      conn.sendMessage(const SessionStatus(
        status: 'rejected',
        message: 'Session rejected by user',
      ));
      conn.close();
    }
  }

  /// Register a connection.
  void _registerConnection(String sessionId, _WebSocketConnection conn) {
    _connections[sessionId] = conn;
  }

  /// Unregister a connection.
  void _unregisterConnection(String sessionId) {
    _connections.remove(sessionId);
  }
}

/// Manages a single WebSocket connection.
class _WebSocketConnection {
  final WebSocketChannel channel;
  final WebTerminalServer server;

  WebSession? _session;
  StreamSubscription? _channelSubscription;
  StreamSubscription? _sessionEventSubscription;

  _WebSocketConnection({
    required this.channel,
    required this.server,
  });

  SessionManager get sessionManager => server.sessionManager;

  /// Start handling messages.
  void start() {
    _channelSubscription = channel.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );

    // Send initial auth required message
    sendMessage(const SessionStatus(status: 'auth_required'));
  }

  /// Handle incoming message.
  void _onMessage(dynamic data) {
    if (data is String) {
      _handleJsonMessage(data);
    } else if (data is List<int>) {
      _handleBinaryMessage(Uint8List.fromList(data));
    }
  }

  /// Handle JSON control message.
  void _handleJsonMessage(String jsonString) {
    final message = parseMessage(jsonString);
    if (message == null) {
      sendMessage(const ErrorMessage(
        code: 'invalid_message',
        message: 'Could not parse message',
      ));
      return;
    }

    switch (message) {
      case AuthRequest(:final token):
        _handleAuth(token);
      case CreatePtyRequest(:final ptyId, :final cols, :final rows, :final env):
        _handleCreatePty(ptyId, cols, rows, env);
      case ClosePtyRequest(:final ptyId):
        _handleClosePty(ptyId);
      case ResizePtyRequest(:final ptyId, :final cols, :final rows):
        _handleResizePty(ptyId, cols, rows);
      case Ping():
        sendMessage(const Pong());
      default:
        sendMessage(const ErrorMessage(
          code: 'unknown_message',
          message: 'Unknown message type',
        ));
    }
  }

  /// Handle binary terminal data.
  void _handleBinaryMessage(Uint8List data) {
    if (_session == null || _session!.status != WebSessionStatus.connected) {
      return;
    }

    final frame = decodeBinaryFrame(data);
    if (frame == null) return;

    final pty = _session!.ptySessions[frame.ptyId];
    pty?.write(frame.data);
  }

  /// Handle authentication.
  void _handleAuth(String token) {
    if (_session != null) {
      sendMessage(const ErrorMessage(
        code: 'already_authenticated',
        message: 'Session already authenticated',
      ));
      return;
    }

    // Get client address from channel (best effort)
    const clientAddress = 'unknown';

    // In debug mode, skip token validation and auto-approve
    if (server.config.debugMode) {
      _handleDebugAuth(clientAddress);
      return;
    }

    final session = sessionManager.createSession(
      tokenString: token,
      clientAddress: clientAddress,
    );

    if (session == null) {
      sendMessage(const AuthResponse(
        success: false,
        error: 'Invalid or expired token',
      ));
      close();
      return;
    }

    _session = session;
    session.attach(channel);
    server._registerConnection(session.id, this);

    // Subscribe to session events
    _sessionEventSubscription = session.events.listen(_onSessionEvent);

    // Notify client about pending status
    sendMessage(const SessionStatus(
      status: 'pending',
      message: 'Waiting for approval in the app',
    ));
  }

  /// Handle authentication in debug mode (auto-approve).
  void _handleDebugAuth(String clientAddress) {
    // Create a debug token if none exists
    final tokens = sessionManager.tokens;
    SessionToken debugToken;
    if (tokens.isEmpty) {
      debugToken = sessionManager.createToken(label: 'Debug Token');
    } else {
      debugToken = tokens.first;
    }

    // Create session using the debug token
    final session = sessionManager.createSession(
      tokenString: debugToken.token,
      clientAddress: clientAddress,
    );

    if (session == null) {
      sendMessage(const AuthResponse(
        success: false,
        error: 'Failed to create debug session',
      ));
      close();
      return;
    }

    _session = session;
    session.attach(channel);
    server._registerConnection(session.id, this);

    // Subscribe to session events
    _sessionEventSubscription = session.events.listen(_onSessionEvent);

    // Auto-approve the session immediately in debug mode
    sessionManager.approveSession(session.id);
    session.status = WebSessionStatus.connected;

    // Send approval immediately
    sendMessage(const AuthResponse(success: true));
    sendMessage(const SessionStatus(
      status: 'approved',
      message: 'Debug mode: auto-approved',
    ));
  }

  /// Handle PTY creation request.
  void _handleCreatePty(
    String ptyId,
    int cols,
    int rows,
    Map<String, String>? env,
  ) async {
    if (_session == null || _session!.status != WebSessionStatus.connected) {
      sendMessage(CreatePtyResponse(
        ptyId: ptyId,
        success: false,
        error: 'Session not connected',
      ));
      return;
    }

    if (_session!.ptyCount >= server.config.maxPtySessions) {
      sendMessage(CreatePtyResponse(
        ptyId: ptyId,
        success: false,
        error: 'Maximum PTY sessions reached',
      ));
      return;
    }

    try {
      await _session!.createPty(
        ptyId: ptyId,
        cols: cols,
        rows: rows,
        environment: env,
      );
      sendMessage(CreatePtyResponse(ptyId: ptyId, success: true));
    } catch (e) {
      sendMessage(CreatePtyResponse(
        ptyId: ptyId,
        success: false,
        error: e.toString(),
      ));
    }
  }

  /// Handle PTY close request.
  void _handleClosePty(String ptyId) async {
    if (_session == null) return;
    await _session!.closePty(ptyId);
  }

  /// Handle PTY resize request.
  void _handleResizePty(String ptyId, int cols, int rows) async {
    if (_session == null) return;
    final pty = _session!.ptySessions[ptyId];
    await pty?.resize(cols, rows);
  }

  /// Handle session events.
  void _onSessionEvent(WsSessionInternalEvent event) {
    switch (event) {
      case WsPtyOutputEvent(:final ptyId, :final data):
        // Send binary frame
        final frame = encodeBinaryFrame(ptyId, data);
        channel.sink.add(frame);
      case WsPtyClosedEvent(:final ptyId, :final exitCode):
        sendMessage(PtyExited(ptyId: ptyId, exitCode: exitCode));
      default:
        break;
    }
  }

  /// Send a JSON message.
  void sendMessage(WsMessage message) {
    channel.sink.add(message.toJsonString());
  }

  /// Handle error.
  void _onError(dynamic error) {
    close();
  }

  /// Handle connection close.
  void _onDone() {
    close();
  }

  /// Close the connection.
  Future<void> close() async {
    await _channelSubscription?.cancel();
    await _sessionEventSubscription?.cancel();

    if (_session != null) {
      server._unregisterConnection(_session!.id);
      _session!.detach();
      sessionManager.disconnectSession(_session!.id);
      _session = null;
    }

    await channel.sink.close();
  }
}
