part of 'bloc.dart';

@immutable
sealed class TerminalTabState extends Equatable {
  const TerminalTabState();

  @override
  List<Object?> get props => [];

  TerminalTabState copyWith();
}

final class TerminalTabInitial extends TerminalTabState {
  @override
  List<Object?> get props => [];

  @override
  TerminalTabState copyWith() {
    return TerminalTabInitial();
  }
}

final class TerminalTabLoaded extends TerminalTabState {
  final Tabs tabs;
  final TabsDocument tabsDocument;
  final bool isMounted;
  final int version; // Force state change detection on tab operations

  const TerminalTabLoaded({
    required this.tabs,
    required this.tabsDocument,
    required this.isMounted,
    this.version = 0,
  });

  @override
  List<Object?> get props => [tabs, tabsDocument, isMounted, version];

  @override
  TerminalTabLoaded copyWith({
    Tabs? tabs,
    TabsDocument? tabsDocument,
    bool? isMounted,
    bool incrementVersion = false,
  }) {
    return TerminalTabLoaded(
      tabs: tabs ?? this.tabs,
      tabsDocument: tabsDocument ?? this.tabsDocument,
      isMounted: isMounted ?? this.isMounted,
      version: incrementVersion ? version + 1 : version,
    );
  }
}

final class TerminalTabError extends TerminalTabState {
  final Object error;

  const TerminalTabError(this.error);

  @override
  List<Object?> get props => [error];

  @override
  TerminalTabError copyWith({Object? error}) {
    return TerminalTabError(error ?? this.error);
  }
}
