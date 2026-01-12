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

  /// Sessions pending approval.
  final List<WebSession> pendingSessions;

  /// Active/connected sessions.
  final List<WebSession> activeSessions;

  /// Error message (if any).
  final String? error;

  /// Whether the server is starting.
  final bool isStarting;

  /// Revision counter for session updates.
  final int sessionsRevision;

  const WebSessionState({
    this.serverRunning = false,
    this.serverPort,
    this.serverAddress,
    this.pendingSessions = const [],
    this.activeSessions = const [],
    this.error,
    this.isStarting = false,
    this.sessionsRevision = 0,
  });

  /// Initial state.
  const WebSessionState.initial()
      : this(
          serverRunning: false,
          pendingSessions: const [],
          activeSessions: const [],
        );

  @override
  List<Object?> get props => [
        serverRunning,
        serverPort,
        serverAddress,
        pendingSessions,
        activeSessions,
        error,
        isStarting,
        sessionsRevision,
      ];

  WebSessionState copyWith({
    bool? serverRunning,
    int? serverPort,
    String? serverAddress,
    List<WebSession>? pendingSessions,
    List<WebSession>? activeSessions,
    String? error,
    bool? isStarting,
    int? sessionsRevision,
    bool clearError = false,
    bool clearServerPort = false,
    bool clearServerAddress = false,
  }) {
    return WebSessionState(
      serverRunning: serverRunning ?? this.serverRunning,
      serverPort: clearServerPort ? null : (serverPort ?? this.serverPort),
      serverAddress:
          clearServerAddress ? null : (serverAddress ?? this.serverAddress),
      pendingSessions: pendingSessions ?? this.pendingSessions,
      activeSessions: activeSessions ?? this.activeSessions,
      error: clearError ? null : (error ?? this.error),
      isStarting: isStarting ?? this.isStarting,
      sessionsRevision: sessionsRevision ?? this.sessionsRevision,
    );
  }

  /// Total number of active PTY sessions across all connections.
  int get totalPtySessions =>
      activeSessions.fold(0, (sum, s) => sum + s.ptyCount);

  /// Whether there are pending sessions to approve.
  bool get hasPendingSessions => pendingSessions.isNotEmpty;
}
