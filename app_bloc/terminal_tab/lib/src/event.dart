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

/// Activates the next tab (wraps around).
class TerminalTabNextTab extends TerminalTabEvent {}

/// Activates the previous tab (wraps around).
class TerminalTabPreviousTab extends TerminalTabEvent {}

/// Activates the tab at a specific index (0-based).
/// Index 8 always activates the last tab (Ctrl+9 convention).
class TerminalTabGoToTab extends TerminalTabEvent {
  final int index;

  TerminalTabGoToTab(this.index);
}
