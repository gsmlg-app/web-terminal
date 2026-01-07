import 'dart:async';

import 'package:uuid/uuid.dart';

import 'session.dart';
import 'session_token.dart';

/// Event types for session manager notifications.
sealed class SessionManagerEvent {
  const SessionManagerEvent();
}

/// Event: A new token was created.
class TokenCreatedEvent extends SessionManagerEvent {
  final SessionToken token;
  const TokenCreatedEvent(this.token);
}

/// Event: A token was revoked.
class TokenRevokedEvent extends SessionManagerEvent {
  final String tokenId;
  const TokenRevokedEvent(this.tokenId);
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

/// Manages session tokens and web sessions.
class SessionManager {
  final _uuid = const Uuid();

  /// All registered tokens.
  final Map<String, SessionToken> _tokens = {};

  /// All sessions (by session ID).
  final Map<String, WebSession> _sessions = {};

  /// Sessions indexed by token value for quick lookup.
  final Map<String, List<String>> _sessionsByToken = {};

  /// Event stream controller.
  final _eventController = StreamController<SessionManagerEvent>.broadcast();

  /// Stream of session manager events.
  Stream<SessionManagerEvent> get events => _eventController.stream;

  /// Create a new session token.
  SessionToken createToken({
    String? label,
    Duration validity = const Duration(hours: 24),
  }) {
    final token = SessionToken.generate(
      label: label,
      validity: validity,
    );

    _tokens[token.id] = token;
    _sessionsByToken[token.token] = [];
    _eventController.add(TokenCreatedEvent(token));

    return token;
  }

  /// Revoke a token and invalidate all its sessions.
  void revokeToken(String tokenId) {
    final token = _tokens.remove(tokenId);
    if (token != null) {
      // Close all sessions using this token
      final sessionIds = _sessionsByToken.remove(token.token) ?? [];
      for (final sessionId in sessionIds) {
        final session = _sessions.remove(sessionId);
        session?.close();
      }
      _eventController.add(TokenRevokedEvent(tokenId));
    }
  }

  /// Validate a token string and return the token if valid.
  SessionToken? validateToken(String tokenString) {
    for (final token in _tokens.values) {
      if (token.token == tokenString && token.isValid) {
        return token;
      }
    }
    return null;
  }

  /// Create a new pending session for a valid token.
  WebSession? createSession({
    required String tokenString,
    required String clientAddress,
    String? userAgent,
  }) {
    final token = validateToken(tokenString);
    if (token == null) {
      return null;
    }

    final sessionId = _uuid.v4();
    final session = WebSession(
      id: sessionId,
      tokenId: token.id,
      clientAddress: clientAddress,
      userAgent: userAgent,
      status: WebSessionStatus.pending,
    );

    _sessions[sessionId] = session;
    _sessionsByToken[tokenString]?.add(sessionId);
    _eventController.add(SessionPendingEvent(session));

    return session;
  }

  /// Approve a pending session.
  void approveSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null && session.status == WebSessionStatus.pending) {
      session.status = WebSessionStatus.approved;
      _eventController.add(SessionApprovedEvent(session));
    }
  }

  /// Reject a pending session.
  void rejectSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null && session.status == WebSessionStatus.pending) {
      session.status = WebSessionStatus.rejected;
      _eventController.add(SessionRejectedEvent(session));
      // Remove the session after rejection
      _sessions.remove(sessionId);
      session.close();
    }
  }

  /// Disconnect an active session.
  void disconnectSession(String sessionId) {
    final session = _sessions[sessionId];
    if (session != null) {
      session.status = WebSessionStatus.disconnected;
      _eventController.add(SessionDisconnectedEvent(session));
      _sessions.remove(sessionId);
      session.close();
    }
  }

  /// Get a session by ID.
  WebSession? getSession(String sessionId) => _sessions[sessionId];

  /// Get all tokens.
  List<SessionToken> get tokens => _tokens.values.toList();

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

  /// Clean up expired tokens and sessions.
  void cleanup() {
    // Remove expired tokens
    final expiredTokenIds = _tokens.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();

    for (final tokenId in expiredTokenIds) {
      revokeToken(tokenId);
    }
  }

  /// Dispose of the session manager.
  Future<void> dispose() async {
    for (final session in _sessions.values) {
      await session.close();
    }
    _sessions.clear();
    _tokens.clear();
    _sessionsByToken.clear();
    await _eventController.close();
  }
}
