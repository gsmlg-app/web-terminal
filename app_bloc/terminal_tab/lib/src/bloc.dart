import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:meta/meta.dart';

part 'event.dart';
part 'state.dart';

class TerminalTabBloc extends Bloc<TerminalTabEvent, TerminalTabState> {
  TerminalTabBloc() : super(TerminalTabInitial()) {
    on<TerminalTabStart>(_onTerminalTabStart);
    on<TerminalTabStop>(_onTerminalTabStop);
    on<TerminalTabOpenTab>(_onTerminalTabOpenTab);
    on<TerminalTabToggleFullscreen>(_onTerminalTabToggleFullscreen);
  }

  void _onTerminalTabStart(
    TerminalTabStart event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      emit((state as TerminalTabLoaded).copyWith(isMounted: true));
    } else {
      final tabs = Tabs();
      final tabsDocument = TabsDocument();
      tabsDocument.setRoot(tabs);
      emit(TerminalTabLoaded(
        tabs: tabs,
        tabsDocument: tabsDocument,
        isMounted: true,
      ));
    }
  }

  void _onTerminalTabStop(
    TerminalTabStop event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      emit((state as TerminalTabLoaded).copyWith(isMounted: false));
    } else {
      emit(TerminalTabInitial());
    }
  }

  void _onTerminalTabOpenTab(
      TerminalTabOpenTab event, Emitter<TerminalTabState> emit) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      currentState.tabs.add(event.tabItem);
      if (event.activate) {
        event.tabItem.activate();
      }
      emit(currentState.copyWith(incrementVersion: true));
    }
  }

  void _onTerminalTabToggleFullscreen(
    TerminalTabToggleFullscreen event,
    Emitter<TerminalTabState> emit,
  ) {
    if (state is TerminalTabLoaded) {
      final currentState = state as TerminalTabLoaded;
      emit(currentState.copyWith(isFullscreen: !currentState.isFullscreen));
    }
  }
}
