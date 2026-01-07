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

  /// Maximum number of sessions per token.
  final int maxSessionsPerToken;

  /// Maximum number of PTY sessions per WebSocket connection.
  final int maxPtySessions;

  /// Debug mode: skip authentication and auto-approve sessions.
  final bool debugMode;

  const ServerConfig({
    this.port = 8080,
    this.bindAddress,
    this.allowedOrigins = const ['*'],
    required this.staticFilesPath,
    this.sessionTimeout = const Duration(hours: 24),
    this.maxSessionsPerToken = 5,
    this.maxPtySessions = 10,
    this.debugMode = false,
  });

  ServerConfig copyWith({
    int? port,
    String? bindAddress,
    List<String>? allowedOrigins,
    String? staticFilesPath,
    Duration? sessionTimeout,
    int? maxSessionsPerToken,
    int? maxPtySessions,
    bool? debugMode,
  }) {
    return ServerConfig(
      port: port ?? this.port,
      bindAddress: bindAddress ?? this.bindAddress,
      allowedOrigins: allowedOrigins ?? this.allowedOrigins,
      staticFilesPath: staticFilesPath ?? this.staticFilesPath,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      maxSessionsPerToken: maxSessionsPerToken ?? this.maxSessionsPerToken,
      maxPtySessions: maxPtySessions ?? this.maxPtySessions,
      debugMode: debugMode ?? this.debugMode,
    );
  }
}
