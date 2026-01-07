import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:web_server/web_server.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

/// BLoC for managing web terminal server and sessions.
class WebSessionBloc extends Bloc<WebSessionEvent, WebSessionState> {
  final String staticFilesPath;
  final int defaultPort;
  final bool debugMode;

  ServerConfig get _config => ServerConfig(
        staticFilesPath: staticFilesPath,
        port: defaultPort,
        debugMode: debugMode,
      );

  late final SessionManager _sessionManager;
  late final WebTerminalServer _server;

  StreamSubscription? _sessionManagerSubscription;

  WebSessionBloc({
    required this.staticFilesPath,
    this.defaultPort = 8080,
    this.debugMode = false,
  }) : super(const WebSessionState.initial()) {
    _sessionManager = SessionManager();
    _server = WebTerminalServer(
      config: _config,
      sessionManager: _sessionManager,
    );

    // Register event handlers
    on<StartWebServer>(_onStartServer);
    on<StopWebServer>(_onStopServer);
    on<CreateToken>(_onCreateToken);
    on<RevokeToken>(_onRevokeToken);
    on<ApproveSession>(_onApproveSession);
    on<RejectSession>(_onRejectSession);
    on<DisconnectSession>(_onDisconnectSession);
    on<SessionManagerEventReceived>(_onSessionManagerEvent);
    on<RefreshStateEvent>(_onRefreshState);

    // Subscribe to session manager events
    _sessionManagerSubscription = _sessionManager.events.listen((event) {
      add(SessionManagerEventReceived(event));
    });

    // Auto-start server in debug mode
    if (debugMode) {
      add(const StartWebServer());
    }
  }

  /// Get the session manager (for UI access).
  SessionManager get sessionManager => _sessionManager;

  /// Get the server (for status checks).
  WebTerminalServer get server => _server;

  Future<void> _onStartServer(
    StartWebServer event,
    Emitter<WebSessionState> emit,
  ) async {
    if (_server.isRunning) return;

    emit(state.copyWith(isStarting: true, clearError: true));

    try {
      // Update config if port specified
      if (event.port != null) {
        // Note: In a real implementation, you'd recreate the server with new config
        // For now, we use the initial config
      }

      await _server.start();

      emit(state.copyWith(
        serverRunning: true,
        serverPort: _server.port,
        serverAddress: _server.address,
        isStarting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isStarting: false,
        error: 'Failed to start server: $e',
      ));
    }
  }

  Future<void> _onStopServer(
    StopWebServer event,
    Emitter<WebSessionState> emit,
  ) async {
    if (!_server.isRunning) return;

    try {
      await _server.stop();

      emit(state.copyWith(
        serverRunning: false,
        clearServerPort: true,
        clearServerAddress: true,
        activeSessions: const [],
        pendingSessions: const [],
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to stop server: $e'));
    }
  }

  void _onCreateToken(
    CreateToken event,
    Emitter<WebSessionState> emit,
  ) {
    final token = _sessionManager.createToken(
      label: event.label,
      validity: event.validity ?? const Duration(hours: 24),
    );

    emit(state.copyWith(
      tokens: [...state.tokens, token],
    ));
  }

  void _onRevokeToken(
    RevokeToken event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.revokeToken(event.tokenId);

    emit(state.copyWith(
      tokens: state.tokens.where((t) => t.id != event.tokenId).toList(),
    ));

    // Refresh sessions as some may have been invalidated
    add(const RefreshStateEvent());
  }

  void _onApproveSession(
    ApproveSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.approveSession(event.sessionId);
    // State will be updated via _SessionManagerEvent
  }

  void _onRejectSession(
    RejectSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.rejectSession(event.sessionId);
    // State will be updated via _SessionManagerEvent
  }

  void _onDisconnectSession(
    DisconnectSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.disconnectSession(event.sessionId);
    // State will be updated via _SessionManagerEvent
  }

  void _onSessionManagerEvent(
    SessionManagerEventReceived event,
    Emitter<WebSessionState> emit,
  ) {
    // Refresh state when session manager events occur
    _refreshState(emit);
  }

  void _onRefreshState(
    RefreshStateEvent event,
    Emitter<WebSessionState> emit,
  ) {
    _refreshState(emit);
  }

  void _refreshState(Emitter<WebSessionState> emit) {
    emit(state.copyWith(
      tokens: _sessionManager.tokens,
      pendingSessions: _sessionManager.pendingSessions,
      activeSessions: _sessionManager.activeSessions,
    ));
  }

  @override
  Future<void> close() async {
    await _sessionManagerSubscription?.cancel();
    await _server.stop();
    await _sessionManager.dispose();
    return super.close();
  }
}
