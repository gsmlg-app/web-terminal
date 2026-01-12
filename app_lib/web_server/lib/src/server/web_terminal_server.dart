import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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

/// Cookie name for session ID.
const String _sessionCookieName = 'wt_session';

/// Web terminal server using Shelf.
///
/// Authentication flow:
/// 1. Browser accesses / → Server creates session, sets HTTP-only cookie,
///    returns page with 6-character approval code
/// 2. User sees code in browser, finds it in Flutter app's pending list
/// 3. User approves session in Flutter app
/// 4. Browser connects WebSocket using session ID from cookie
/// 5. Approved session can create PTY connections
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
    router.get('/api/session', _sessionStatusHandler);

    // Main page handler (creates session if needed)
    router.get('/', _mainPageHandler);

    // Check if static files exist
    final indexFile = File('${config.staticFilesPath}/index.html');
    final hasStaticFiles = await indexFile.exists();

    // Static file handler for other assets
    Handler staticHandler;
    if (hasStaticFiles) {
      staticHandler = createStaticHandler(
        config.staticFilesPath,
        defaultDocument: 'index.html',
      );
    } else {
      staticHandler = _notFoundHandler;
    }

    // Combine handlers
    final handler = const Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(Cascade().add(router.call).add(staticHandler).handler);

    // Start server
    final bindAddress = config.bindAddress ?? InternetAddress.anyIPv4.address;
    final securityContext =
        config.useSsl ? await _createSecurityContext() : null;
    _server = await shelf_io.serve(
      handler,
      bindAddress,
      config.port,
      securityContext: securityContext,
    );

    // Subscribe to session manager events for approval notifications
    _subscribeToSessionEvents();
  }

  Future<SecurityContext> _createSecurityContext() async {
    final certDir = Directory('${Directory.systemTemp.path}/web-terminal-cert');
    if (!await certDir.exists()) {
      await certDir.create(recursive: true);
    }

    final certFile = File('${certDir.path}/certificate.pem');
    final keyFile = File('${certDir.path}/private_key.pem');
    if (!await certFile.exists() || !await keyFile.exists()) {
      await _generateSelfSignedCertificate(certFile, keyFile);
    }

    final context = SecurityContext();
    context.useCertificateChain(certFile.path);
    context.usePrivateKey(keyFile.path);
    return context;
  }

  Future<void> _generateSelfSignedCertificate(
    File certFile,
    File keyFile,
  ) async {
    final sans = <String>['DNS:localhost', 'IP:127.0.0.1'];
    final bindAddress = config.bindAddress;
    if (bindAddress != null &&
        bindAddress.isNotEmpty &&
        bindAddress != '0.0.0.0' &&
        bindAddress != '::') {
      sans.add('IP:$bindAddress');
    }

    final args = [
      'req',
      '-x509',
      '-nodes',
      '-newkey',
      'rsa:2048',
      '-keyout',
      keyFile.path,
      '-out',
      certFile.path,
      '-days',
      '365',
      '-subj',
      '/CN=web-terminal',
      '-addext',
      'subjectAltName=${sans.join(',')}',
    ];

    var result = await Process.run('openssl', args);
    if (result.exitCode != 0) {
      result = await Process.run(
        'openssl',
        [
          'req',
          '-x509',
          '-nodes',
          '-newkey',
          'rsa:2048',
          '-keyout',
          keyFile.path,
          '-out',
          certFile.path,
          '-days',
          '365',
          '-subj',
          '/CN=web-terminal',
        ],
      );
    }

    if (result.exitCode != 0) {
      throw StateError('Failed to generate SSL certificate: ${result.stderr}');
    }
  }

  /// Handle main page request - creates session and sets cookie.
  Future<Response> _mainPageHandler(Request request) async {
    // Get existing session ID from cookie
    final existingSessionId = _getSessionIdFromCookie(request);

    // Get or create session
    final clientAddress = _getClientAddress(request);
    final userAgent = request.headers['user-agent'];

    final session = sessionManager.getOrCreateSession(
      existingSessionId: existingSessionId,
      clientAddress: clientAddress,
      userAgent: userAgent,
    );

    // Debug logging
    final isNewSession = existingSessionId != session.id;
    print('[WebServer] ===== Request to / =====');
    print('[WebServer] Client: $clientAddress');
    print(
        '[WebServer] Existing cookie: ${existingSessionId?.substring(0, 8) ?? 'none'}...');
    print('[WebServer] Session ID: ${session.id.substring(0, 8)}...');
    print('[WebServer] New session created: $isNewSession');
    print('[WebServer] Approval code: ${session.approvalCode}');
    print('[WebServer] Status: ${session.status.name}');
    print(
        '[WebServer] Injecting window.__SESSION__ = ${_sessionToJson(session)}');
    print('[WebServer] ===========================');

    // Check if we have static files
    final indexFile = File('${config.staticFilesPath}/index.html');
    final hasStaticFiles = await indexFile.exists();

    Response response;
    if (hasStaticFiles) {
      // Serve index.html with session info injected
      final indexContent = await indexFile.readAsString();
      // Inject session data as JSON in a script tag
      final sessionJson = '''
<script>
  window.__SESSION__ = ${_sessionToJson(session)};
</script>
''';
      final modifiedContent = indexContent.replaceFirst(
        '</head>',
        '$sessionJson</head>',
      );
      response = Response.ok(
        modifiedContent,
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    } else {
      // Serve fallback page with approval code
      response = Response.ok(
        _buildFallbackPage(session),
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    }

    // Set session cookie if this is a new session
    if (existingSessionId != session.id) {
      response = response.change(headers: {
        ...response.headers,
        'Set-Cookie': _buildSessionCookie(session.id),
      });
    }

    return response;
  }

  /// Build session cookie header value.
  String _buildSessionCookie(String sessionId) {
    return '$_sessionCookieName=$sessionId; '
        'HttpOnly; '
        'SameSite=Strict; '
        'Path=/; '
        'Max-Age=${24 * 60 * 60}'; // 24 hours
  }

  /// Get session ID from request cookie.
  String? _getSessionIdFromCookie(Request request) {
    final cookieHeader = request.headers['cookie'];
    if (cookieHeader == null) return null;

    for (final cookie in cookieHeader.split(';')) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == _sessionCookieName) {
        return parts[1];
      }
    }
    return null;
  }

  /// Get client address from request.
  String _getClientAddress(Request request) {
    // Try X-Forwarded-For first (for proxied requests)
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null) {
      return forwarded.split(',').first.trim();
    }

    final realIp = request.headers['x-real-ip'];
    if (realIp != null && realIp.isNotEmpty) {
      return realIp;
    }

    final connectionInfo =
        request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
    return connectionInfo?.remoteAddress.address ?? '0.0.0.0';
  }

  /// Convert session to JSON string for injection.
  String _sessionToJson(WebSession session) {
    return '{'
        '"id": "${session.id}", '
        '"approvalCode": "${session.approvalCode}", '
        '"status": "${session.status.name}"'
        '}';
  }

  /// Build fallback page when no static files are present.
  String _buildFallbackPage(WebSession session) {
    final statusMessage = switch (session.status) {
      WebSessionStatus.pending =>
        'Waiting for approval. Share this code with the app owner:',
      WebSessionStatus.approved ||
      WebSessionStatus.connected =>
        'Session approved! Connecting...',
      WebSessionStatus.rejected => 'Session was rejected.',
      WebSessionStatus.expired => 'Session expired. Please refresh.',
      WebSessionStatus.disconnected => 'Disconnected. Please refresh.',
    };

    final codeDisplay = session.isPending
        ? '''
    <div class="code">${session.approvalCode}</div>
    <p class="hint">Enter this code in the WebTerminal app to approve access.</p>
'''
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Web Terminal</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1e1e2e;
      color: #cdd6f4;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      padding: 20px;
    }
    .card {
      background: #313244;
      padding: 40px;
      border-radius: 16px;
      text-align: center;
      max-width: 400px;
      width: 100%;
      box-shadow: 0 4px 24px rgba(0, 0, 0, 0.3);
    }
    h1 {
      color: #cba6f7;
      margin: 0 0 8px 0;
      font-size: 24px;
    }
    .subtitle {
      color: #a6adc8;
      margin: 0 0 24px 0;
      font-size: 14px;
    }
    .status {
      color: #a6adc8;
      margin: 0 0 16px 0;
      line-height: 1.6;
    }
    .code {
      font-family: 'SF Mono', Monaco, 'Courier New', monospace;
      font-size: 36px;
      font-weight: bold;
      letter-spacing: 8px;
      color: #89dceb;
      background: #45475a;
      padding: 16px 24px;
      border-radius: 8px;
      margin: 16px 0;
      user-select: all;
    }
    .hint {
      color: #6c7086;
      font-size: 13px;
      margin: 16px 0 0 0;
    }
    .connected {
      color: #a6e3a1;
    }
    .rejected {
      color: #f38ba8;
    }
  </style>
  <script>
    window.__SESSION__ = ${_sessionToJson(session)};

    // Poll for status changes
    if (window.__SESSION__.status === 'pending') {
      setInterval(async () => {
        try {
          const res = await fetch('/api/session');
          const data = await res.json();
          if (data.status !== 'pending') {
            window.location.reload();
          }
        } catch (e) {}
      }, 2000);
    }
  </script>
</head>
<body>
  <div class="card">
    <h1>Web Terminal</h1>
    <p class="subtitle">Remote Terminal Access</p>
    <p class="status ${session.isApproved ? 'connected' : ''} ${session.status == WebSessionStatus.rejected ? 'rejected' : ''}">
      $statusMessage
    </p>
    $codeDisplay
  </div>
</body>
</html>
''';
  }

  /// Handle session status API request.
  Response _sessionStatusHandler(Request request) {
    final sessionId = _getSessionIdFromCookie(request);
    if (sessionId == null) {
      return Response.ok(
        '{"status": "no_session"}',
        headers: {'Content-Type': 'application/json'},
      );
    }

    final session = sessionManager.getSession(sessionId);
    if (session == null) {
      return Response.ok(
        '{"status": "expired"}',
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      '{"status": "${session.status.name}", "approvalCode": "${session.approvalCode}"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 404 handler.
  Response _notFoundHandler(Request request) {
    return Response.notFound('Not found');
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
        'Access-Control-Allow-Credentials': 'true',
      };

  /// Health check handler.
  Response _healthHandler(Request request) {
    return Response.ok('{"status": "ok"}',
        headers: {'Content-Type': 'application/json'});
  }

  /// WebSocket handler.
  Handler _webSocketHandler() {
    return (Request request) {
      // Get session ID from cookie
      final sessionId = _getSessionIdFromCookie(request);

      return webSocketHandler((WebSocketChannel channel, String? protocol) {
        _handleWebSocket(channel, sessionId);
      })(request);
    };
  }

  /// Handle a new WebSocket connection.
  void _handleWebSocket(WebSocketChannel channel, String? sessionId) {
    final connection = _WebSocketConnection(
      channel: channel,
      server: this,
      sessionId: sessionId,
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
      sessionManager.markConnected(session.id);
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
  final String? sessionId;

  WebSession? _session;
  StreamSubscription? _channelSubscription;
  StreamSubscription? _sessionEventSubscription;
  Timer? _pingTimer;

  _WebSocketConnection({
    required this.channel,
    required this.server,
    required this.sessionId,
  });

  SessionManager get sessionManager => server.sessionManager;

  /// Start handling messages.
  void start() {
    // Validate session from cookie
    if (sessionId == null) {
      sendMessage(const ErrorMessage(
        code: 'no_session',
        message: 'No session cookie. Please refresh the page.',
      ));
      close();
      return;
    }

    final session = sessionManager.getSession(sessionId!);
    if (session == null) {
      sendMessage(const ErrorMessage(
        code: 'invalid_session',
        message: 'Session expired. Please refresh the page.',
      ));
      close();
      return;
    }

    _session = session;
    session.attach(channel);
    server._registerConnection(session.id, this);

    // Subscribe to session events
    _sessionEventSubscription = session.events.listen(_onSessionEvent);

    // Start listening to messages
    _channelSubscription = channel.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );

    // Send current status
    if (session.isApproved) {
      sessionManager.markConnected(session.id);
      sendMessage(const SessionStatus(
        status: 'connected',
        message: 'Session connected',
      ));
    } else if (session.isPending) {
      sendMessage(SessionStatus(
        status: 'pending',
        message: 'Waiting for approval. Code: ${session.approvalCode}',
      ));
    } else {
      sendMessage(SessionStatus(
        status: session.status.name,
        message: 'Session status: ${session.status.name}',
      ));
    }

    _startPing();
  }

  /// Handle incoming message.
  void _onMessage(dynamic data) {
    if (data is String) {
      _recordIncomingBytes(data.length);
      _handleJsonMessage(data);
    } else if (data is List<int>) {
      _recordIncomingBytes(data.length);
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
      case CreatePtyRequest(:final ptyId, :final cols, :final rows, :final env):
        _handleCreatePty(ptyId, cols, rows, env);
      case ClosePtyRequest(:final ptyId):
        _handleClosePty(ptyId);
      case ResizePtyRequest(:final ptyId, :final cols, :final rows):
        _handleResizePty(ptyId, cols, rows);
      case Ping(:final sentAt):
        sendMessage(Pong(sentAt: sentAt));
      case Pong(:final sentAt):
        _recordLatency(sentAt);
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
        error: 'Session not approved or connected',
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
      _session!.updatePtySize(ptyId, cols, rows);
      _notifySessionUpdated();
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
    _notifySessionUpdated();
  }

  /// Handle PTY resize request.
  void _handleResizePty(String ptyId, int cols, int rows) async {
    if (_session == null) return;
    final pty = _session!.ptySessions[ptyId];
    await pty?.resize(cols, rows);
    _session!.updatePtySize(ptyId, cols, rows);
  }

  /// Handle session events.
  void _onSessionEvent(WsSessionInternalEvent event) {
    switch (event) {
      case WsPtyCreatedEvent():
        _notifySessionUpdated();
      case WsPtyOutputEvent(:final ptyId, :final data):
        // Send binary frame
        final frame = encodeBinaryFrame(ptyId, data);
        _recordOutgoingBytes(frame.length);
        channel.sink.add(frame);
      case WsPtyClosedEvent(:final ptyId, :final exitCode):
        sendMessage(PtyExited(ptyId: ptyId, exitCode: exitCode));
        _notifySessionUpdated();
      default:
        break;
    }
  }

  void _recordIncomingBytes(int bytes) {
    if (_session == null) return;
    final updated = _session!.recordIncomingBytes(bytes);
    if (updated) {
      sessionManager.notifySessionUpdated(_session!);
    }
  }

  void _recordOutgoingBytes(int bytes) {
    if (_session == null) return;
    final updated = _session!.recordOutgoingBytes(bytes);
    if (updated) {
      sessionManager.notifySessionUpdated(_session!);
    }
  }

  void _recordLatency(int sentAt) {
    if (_session == null) return;
    final latency = DateTime.now().millisecondsSinceEpoch - sentAt;
    if (latency < 0) return;
    _session!.updateLatency(latency);
    sessionManager.notifySessionUpdated(_session!);
  }

  void _notifySessionUpdated() {
    if (_session == null) return;
    sessionManager.notifySessionUpdated(_session!);
  }

  void _startPing() {
    _stopPing();
    _sendPing();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendPing(),
    );
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    sendMessage(
      Ping(sentAt: DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Send a JSON message.
  void sendMessage(WsMessage message) {
    final payload = message.toJsonString();
    _recordOutgoingBytes(payload.length);
    channel.sink.add(payload);
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
    _stopPing();
    await _channelSubscription?.cancel();
    await _sessionEventSubscription?.cancel();

    if (_session != null) {
      server._unregisterConnection(_session!.id);
      _session!.detach();
      sessionManager.markDisconnected(_session!.id);
      // Don't disconnect the session - it can reconnect
      _session = null;
    }

    await channel.sink.close();
  }
}
