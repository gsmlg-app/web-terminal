import 'package:equatable/equatable.dart';
import 'package:web_server/web_server.dart';

/// State for web session BLoC.
class WebSessionState extends Equatable {
  /// Whether the web server is running.
  final bool serverRunning;

  /// Server port (if running).
  final int? serverPort;

  /// Server address (if running).
  final String? serverAddress;

  /// All active tokens.
  final List<SessionToken> tokens;

  /// Sessions pending approval.
  final List<WebSession> pendingSessions;

  /// Active/connected sessions.
  final List<WebSession> activeSessions;

  /// Error message (if any).
  final String? error;

  /// Whether the server is starting.
  final bool isStarting;

  const WebSessionState({
    this.serverRunning = false,
    this.serverPort,
    this.serverAddress,
    this.tokens = const [],
    this.pendingSessions = const [],
    this.activeSessions = const [],
    this.error,
    this.isStarting = false,
  });

  /// Initial state.
  const WebSessionState.initial()
      : this(
          serverRunning: false,
          tokens: const [],
          pendingSessions: const [],
          activeSessions: const [],
        );

  @override
  List<Object?> get props => [
        serverRunning,
        serverPort,
        serverAddress,
        tokens,
        pendingSessions,
        activeSessions,
        error,
        isStarting,
      ];

  WebSessionState copyWith({
    bool? serverRunning,
    int? serverPort,
    String? serverAddress,
    List<SessionToken>? tokens,
    List<WebSession>? pendingSessions,
    List<WebSession>? activeSessions,
    String? error,
    bool? isStarting,
    bool clearError = false,
    bool clearServerPort = false,
    bool clearServerAddress = false,
  }) {
    return WebSessionState(
      serverRunning: serverRunning ?? this.serverRunning,
      serverPort: clearServerPort ? null : (serverPort ?? this.serverPort),
      serverAddress:
          clearServerAddress ? null : (serverAddress ?? this.serverAddress),
      tokens: tokens ?? this.tokens,
      pendingSessions: pendingSessions ?? this.pendingSessions,
      activeSessions: activeSessions ?? this.activeSessions,
      error: clearError ? null : (error ?? this.error),
      isStarting: isStarting ?? this.isStarting,
    );
  }

  /// Total number of active PTY sessions across all connections.
  int get totalPtySessions =>
      activeSessions.fold(0, (sum, s) => sum + s.ptyCount);

  /// Whether there are pending sessions to approve.
  bool get hasPendingSessions => pendingSessions.isNotEmpty;
}
