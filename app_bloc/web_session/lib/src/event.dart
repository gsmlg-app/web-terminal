import 'package:equatable/equatable.dart';
import 'package:web_server/web_server.dart';

/// Base class for web session events.
sealed class WebSessionEvent extends Equatable {
  const WebSessionEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// Server Control Events
// ============================================================================

/// Start the web server.
final class StartWebServer extends WebSessionEvent {
  final int? port;

  const StartWebServer({this.port});

  @override
  List<Object?> get props => [port];
}

/// Stop the web server.
final class StopWebServer extends WebSessionEvent {
  const StopWebServer();
}

// ============================================================================
// Token Management Events
// ============================================================================

/// Create a new session token.
final class CreateToken extends WebSessionEvent {
  final String? label;
  final Duration? validity;

  const CreateToken({this.label, this.validity});

  @override
  List<Object?> get props => [label, validity];
}

/// Revoke a token.
final class RevokeToken extends WebSessionEvent {
  final String tokenId;

  const RevokeToken(this.tokenId);

  @override
  List<Object?> get props => [tokenId];
}

// ============================================================================
// Session Approval Events
// ============================================================================

/// Approve a pending session.
final class ApproveSession extends WebSessionEvent {
  final String sessionId;

  const ApproveSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Reject a pending session.
final class RejectSession extends WebSessionEvent {
  final String sessionId;

  const RejectSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Disconnect an active session.
final class DisconnectSession extends WebSessionEvent {
  final String sessionId;

  const DisconnectSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

// ============================================================================
// Internal Events (from server) - Package internal, not for external use
// ============================================================================

/// Internal: Session manager event received.
/// @nodoc
final class SessionManagerEventReceived extends WebSessionEvent {
  final SessionManagerEvent event;

  const SessionManagerEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}

/// Internal: Refresh state from session manager.
/// @nodoc
final class RefreshStateEvent extends WebSessionEvent {
  const RefreshStateEvent();
}
