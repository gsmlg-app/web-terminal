import 'dart:async';

import 'package:app_logging/app_logging.dart';
import 'package:uuid/uuid.dart';

import 'session.dart';

/// Event types for session manager notifications.
sealed class SessionManagerEvent {
  const SessionManagerEvent();
}

/// Event: A new session is pending approval.
class SessionPendingEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionPendingEvent(this.session);
}

/// Event: A session was approved.
class SessionApprovedEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionApprovedEvent(this.session);
}

/// Event: A session was connected.
class SessionConnectedEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionConnectedEvent(this.session);
}

/// Event: A session was rejected.
class SessionRejectedEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionRejectedEvent(this.session);
}

/// Event: A session was disconnected.
class SessionDisconnectedEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionDisconnectedEvent(this.session);
}

/// Event: A session was updated.
class SessionUpdatedEvent extends SessionManagerEvent {
  final WebSession session;
  const SessionUpdatedEvent(this.session);
}

/// Manages web terminal sessions.
///
/// Sessions are created when a browser first accesses the web terminal.
/// Each session gets a unique ID (stored in HTTP-only cookie) and a
/// 6-character approval code. The user must approve the session in the
/// Flutter app before the browser can create PTY connections.
class SessionManager {
  final _uuid = const Uuid();

  /// All sessions (by session ID).
  final Map<String, WebSession> _sessions = {};

  /// Sessions indexed by approval code for quick lookup.
  final Map<String, String> _sessionsByApprovalCode = {};

  /// Event stream controller.
  final _eventController = StreamController<SessionManagerEvent>.broadcast();

  /// Session expiry duration.
  final Duration sessionExpiry;

  /// Timer for cleanup.
  Timer? _cleanupTimer;

  SessionManager({
    this.sessionExpiry = const Duration(hours: 24),
  }) {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => cleanup(),
    );
  }

  /// Stream of session manager events.
  Stream<SessionManagerEvent> get events => _eventController.stream;

  /// Create a new pending session.
  ///
  /// Returns the created session with its approval code.
  /// The session ID should be stored in an HTTP-only cookie.
  WebSession createSession({
    required String clientAddress,
    String? userAgent,
  }) {
    final sessionId = _uuid.v4();
    final approvalCode = WebSession.generateApprovalCode();

    final session = WebSession(
      id: sessionId,
      approvalCode: approvalCode,
      clientAddress: clientAddress,
      userAgent: userAgent,
      status: WebSessionStatus.pending,
    );

    _sessions[sessionId] = session;
    _sessionsByApprovalCode[approvalCode] = sessionId;

    final logger = AppLogger();
    logger.d(
        '[SessionManager] Created session: id=${sessionId.substring(0, 8)}..., '
        'code=$approvalCode, total=${_sessions.length}');
    logger.d('[SessionManager] Emitting SessionPendingEvent');

    _eventController.add(SessionPendingEvent(session));

    return session;
  }

  /// Get or create a session for the given session ID.
  ///
  /// If the session ID exists and is valid, returns the existing session.
  /// If not, creates a new session.
  WebSession getOrCreateSession({
    required String? existingSessionId,
    required String clientAddress,
    String? userAgent,
  }) {
    if (existingSessionId != null) {
      final session = _sessions[existingSessionId];
      if (session != null && !_isExpired(session)) {
        return session;
      }
    }

    return createSession(
      clientAddress: clientAddress,
      userAgent: userAgent,
    );
  }

  /// Approve a pending session by its approval code.
  ///
  /// Returns true if the session was approved, false if not found or invalid.
  bool approveByCode(String approvalCode) {
    final sessionId = _sessionsByApprovalCode[approvalCode];
    if (sessionId == null) return false;

    return approveSession(sessionId);
  }

  /// Approve a pending session by its session ID.
  bool approveSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null && session.status == WebSessionStatus.pending) {
      session.status = WebSessionStatus.approved;
      _eventController.add(SessionApprovedEvent(session));
      return true;
    }
    return false;
  }

  /// Mark a session as connected.
  void markConnected(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return;

    session.status = WebSessionStatus.connected;
    _eventController.add(SessionConnectedEvent(session));
  }

  /// Mark a session as disconnected without removing it.
  void markDisconnected(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) return;

    session.status = WebSessionStatus.disconnected;
    _eventController.add(SessionDisconnectedEvent(session));
  }

  /// Notify listeners that a session was updated.
  void notifySessionUpdated(WebSession session) {
    _eventController.add(SessionUpdatedEvent(session));
  }

  /// Reject a pending session by its approval code.
  bool rejectByCode(String approvalCode) {
    final sessionId = _sessionsByApprovalCode[approvalCode];
    if (sessionId == null) return false;

    return rejectSession(sessionId);
  }

  /// Reject a pending session by its session ID.
  bool rejectSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null && session.status == WebSessionStatus.pending) {
      session.status = WebSessionStatus.rejected;
      _eventController.add(SessionRejectedEvent(session));
      // Remove the session after rejection
      _removeSession(session);
      return true;
    }
    return false;
  }

  /// Disconnect an active session.
  void disconnectSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null) {
      session.status = WebSessionStatus.disconnected;
      _eventController.add(SessionDisconnectedEvent(session));
      _removeSession(session);
    }
  }

  /// Get a session by ID.
  WebSession? getSession(String sessionId) => _sessions[sessionId];

  /// Get a session by approval code.
  WebSession? getSessionByApprovalCode(String approvalCode) {
    final sessionId = _sessionsByApprovalCode[approvalCode];
    if (sessionId == null) return null;
    return _sessions[sessionId];
  }

  /// Get all sessions.
  List<WebSession> get sessions => _sessions.values.toList();

  /// Get sessions by status.
  List<WebSession> sessionsByStatus(WebSessionStatus status) =>
      _sessions.values.where((s) => s.status == status).toList();

  /// Get pending sessions.
  List<WebSession> get pendingSessions =>
      sessionsByStatus(WebSessionStatus.pending);

  /// Get active/connected sessions.
  List<WebSession> get activeSessions =>
      sessionsByStatus(WebSessionStatus.connected);

  /// Get approved sessions (ready to connect).
  List<WebSession> get approvedSessions =>
      sessionsByStatus(WebSessionStatus.approved);

  /// Check if a session is expired.
  bool _isExpired(WebSession session) {
    return DateTime.now().difference(session.createdAt) > sessionExpiry;
  }

  /// Remove a session and clean up indexes.
  void _removeSession(WebSession session) {
    _sessions.remove(session.id);
    _sessionsByApprovalCode.remove(session.approvalCode);
    session.close();
  }

  /// Clean up expired sessions.
  void cleanup() {
    final expiredSessions =
        _sessions.values.where((s) => _isExpired(s)).toList();

    for (final session in expiredSessions) {
      session.status = WebSessionStatus.expired;
      _removeSession(session);
    }
  }

  /// Dispose of the session manager.
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    for (final session in _sessions.values) {
      await session.close();
    }
    _sessions.clear();
    _sessionsByApprovalCode.clear();
    await _eventController.close();
  }
}
