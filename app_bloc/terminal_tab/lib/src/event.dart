part of 'bloc.dart';

@immutable
sealed class TerminalTabEvent {}

class TerminalTabStart extends TerminalTabEvent {}

class TerminalTabStop extends TerminalTabEvent {}

class TerminalTabOpenTab extends TerminalTabEvent {
  final TabItem tabItem;
  final bool activate;

  TerminalTabOpenTab(this.tabItem, {this.activate = true});
}

/// Toggles fullscreen mode (hides/shows navigation shell).
class TerminalTabToggleFullscreen extends TerminalTabEvent {}

/// Selects a session by its ID (used by AppBar session selector).
class TerminalTabSelectSession extends TerminalTabEvent {
  final String sessionId;

  TerminalTabSelectSession(this.sessionId);
}

/// Closes a session by its ID.
class TerminalTabCloseSession extends TerminalTabEvent {
  final String sessionId;

  TerminalTabCloseSession(this.sessionId);
}
