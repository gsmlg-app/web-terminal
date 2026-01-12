import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_server/web_server.dart';

import 'event.dart';
import 'state.dart';

export 'event.dart';
export 'state.dart';

/// BLoC for managing web terminal server and sessions.
class WebSessionBloc extends Bloc<WebSessionEvent, WebSessionState> {
  static const String listenIpKey = 'web_server_listen_ip';
  static const String portKey = 'web_server_port';
  static const String sslKey = 'web_server_ssl';

  final String staticFilesPath;
  final int defaultPort;
  final bool debugMode;
  final SharedPreferences? sharedPreferences;

  ServerConfig get _config {
    final listenIp = sharedPreferences?.getString(listenIpKey);
    final port = sharedPreferences?.getInt(portKey) ?? defaultPort;
    final useSsl = sharedPreferences?.getBool(sslKey) ?? false;

    return ServerConfig(
      staticFilesPath: staticFilesPath,
      port: port,
      bindAddress: listenIp,
      debugMode: debugMode,
      useSsl: useSsl,
    );
  }

  late final SessionManager _sessionManager;
  late WebTerminalServer _server;

  StreamSubscription? _sessionManagerSubscription;

  WebSessionBloc({
    required this.staticFilesPath,
    this.defaultPort = 8080,
    this.debugMode = false,
    this.sharedPreferences,
  }) : super(const WebSessionState.initial()) {
    _sessionManager = SessionManager();
    _server = WebTerminalServer(
      config: _config,
      sessionManager: _sessionManager,
    );

    // Register event handlers
    on<StartWebServer>(_onStartServer);
    on<StopWebServer>(_onStopServer);
    on<ApproveSessionByCode>(_onApproveSessionByCode);
    on<ApproveSession>(_onApproveSession);
    on<RejectSessionByCode>(_onRejectSessionByCode);
    on<RejectSession>(_onRejectSession);
    on<DisconnectSession>(_onDisconnectSession);
    on<SessionManagerEventReceived>(_onSessionManagerEvent);
    on<RefreshStateEvent>(_onRefreshState);

    // Subscribe to session manager events
    _sessionManagerSubscription = _sessionManager.events.listen((event) {
      add(SessionManagerEventReceived(event));
    });
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
      // Recreate server with latest config settings.
      _server = WebTerminalServer(
        config: _config,
        sessionManager: _sessionManager,
      );

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

  void _onApproveSessionByCode(
    ApproveSessionByCode event,
    Emitter<WebSessionState> emit,
  ) {
    final success = _sessionManager.approveByCode(event.approvalCode);
    if (!success) {
      emit(state.copyWith(
        error: 'No pending session found with code: ${event.approvalCode}',
      ));
    }
    // State will be updated via SessionManagerEventReceived
  }

  void _onApproveSession(
    ApproveSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.approveSession(event.sessionId);
    // State will be updated via SessionManagerEventReceived
  }

  void _onRejectSessionByCode(
    RejectSessionByCode event,
    Emitter<WebSessionState> emit,
  ) {
    final success = _sessionManager.rejectByCode(event.approvalCode);
    if (!success) {
      emit(state.copyWith(
        error: 'No pending session found with code: ${event.approvalCode}',
      ));
    }
    // State will be updated via SessionManagerEventReceived
  }

  void _onRejectSession(
    RejectSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.rejectSession(event.sessionId);
    // State will be updated via SessionManagerEventReceived
  }

  void _onDisconnectSession(
    DisconnectSession event,
    Emitter<WebSessionState> emit,
  ) {
    _sessionManager.disconnectSession(event.sessionId);
    // State will be updated via SessionManagerEventReceived
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
    final pending = _sessionManager.pendingSessions;
    final active = _sessionManager.activeSessions;
    emit(state.copyWith(
      pendingSessions: pending,
      activeSessions: active,
      sessionsRevision: state.sessionsRevision + 1,
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
