/// Configuration for the web terminal server.
class ServerConfig {
  /// Port to listen on.
  final int port;

  /// Address to bind to. Null means all interfaces (0.0.0.0).
  final String? bindAddress;

  /// Allowed origins for CORS. Use ['*'] to allow all.
  final List<String> allowedOrigins;

  /// Path to static files directory for web frontend.
  final String staticFilesPath;

  /// Session timeout duration.
  final Duration sessionTimeout;

  /// Maximum browser sessions per client address (legacy option name).
  final int maxSessionsPerToken;

  final int maxPendingSessions;
  final int maxPendingSessionsPerClient;
  final int maxActiveSessions;
  final Duration pendingSessionTimeout;
  final int maxSessionCreationsPerMinute;
  final int maxSessionCreationsPerClientPerMinute;

  /// Maximum number of PTY sessions per WebSocket connection.
  final int maxPtySessions;

  /// Debug mode: skip authentication and auto-approve sessions.
  final bool debugMode;

  /// Whether to serve HTTPS.
  final bool useSsl;

  const ServerConfig({
    this.port = 8080,
    this.bindAddress,
    this.allowedOrigins = const ['*'],
    required this.staticFilesPath,
    this.sessionTimeout = const Duration(hours: 24),
    this.maxSessionsPerToken = 5,
    this.maxPendingSessions = 32,
    this.maxPendingSessionsPerClient = 3,
    this.maxActiveSessions = 32,
    this.pendingSessionTimeout = const Duration(minutes: 5),
    this.maxSessionCreationsPerMinute = 60,
    this.maxSessionCreationsPerClientPerMinute = 10,
    this.maxPtySessions = 10,
    this.debugMode = false,
    this.useSsl = false,
  });

  ServerConfig copyWith({
    int? port,
    String? bindAddress,
    List<String>? allowedOrigins,
    String? staticFilesPath,
    Duration? sessionTimeout,
    int? maxSessionsPerToken,
    int? maxPendingSessions,
    int? maxPendingSessionsPerClient,
    int? maxActiveSessions,
    Duration? pendingSessionTimeout,
    int? maxSessionCreationsPerMinute,
    int? maxSessionCreationsPerClientPerMinute,
    int? maxPtySessions,
    bool? debugMode,
    bool? useSsl,
  }) {
    return ServerConfig(
      port: port ?? this.port,
      bindAddress: bindAddress ?? this.bindAddress,
      allowedOrigins: allowedOrigins ?? this.allowedOrigins,
      staticFilesPath: staticFilesPath ?? this.staticFilesPath,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      maxSessionsPerToken: maxSessionsPerToken ?? this.maxSessionsPerToken,
      maxPendingSessions: maxPendingSessions ?? this.maxPendingSessions,
      maxPendingSessionsPerClient:
          maxPendingSessionsPerClient ?? this.maxPendingSessionsPerClient,
      maxActiveSessions: maxActiveSessions ?? this.maxActiveSessions,
      pendingSessionTimeout:
          pendingSessionTimeout ?? this.pendingSessionTimeout,
      maxSessionCreationsPerMinute:
          maxSessionCreationsPerMinute ?? this.maxSessionCreationsPerMinute,
      maxSessionCreationsPerClientPerMinute:
          maxSessionCreationsPerClientPerMinute ??
              this.maxSessionCreationsPerClientPerMinute,
      maxPtySessions: maxPtySessions ?? this.maxPtySessions,
      debugMode: debugMode ?? this.debugMode,
      useSsl: useSsl ?? this.useSsl,
    );
  }
}
