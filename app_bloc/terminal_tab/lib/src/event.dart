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
