import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:meta/meta.dart';

part 'terminal_tab_event.dart';
part 'terminal_tab_state.dart';

class TerminalTabBloc extends Bloc<TerminalTabEvent, TerminalTabState> {
  TerminalTabBloc() : super(TerminalTabInitial()) {
    on<TerminalTabStart>(_onTerminalTabStart);
    on<TerminalTabStop>(_onTerminalTabStop);
    on<TerminalTabOpenTab>(_onTerminalTabOpenTab);
  }

  _onTerminalTabStart(TerminalTabStart event, Emitter<TerminalTabState> emit) {
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

  _onTerminalTabStop(TerminalTabStop event, Emitter<TerminalTabState> emit) {
    if (state is TerminalTabLoaded) {
      emit((state as TerminalTabLoaded).copyWith(isMounted: false));
    } else {
      emit(TerminalTabInitial());
    }
  }

  _onTerminalTabOpenTab(
      TerminalTabOpenTab event, Emitter<TerminalTabState> emit) {
    if (state is TerminalTabLoaded) {
      final tabs = (state as TerminalTabLoaded).tabs;
      tabs.add(event.tabItem);
      if (event.activate) {
        event.tabItem.activate();
      }
      emit((state as TerminalTabLoaded).copyWith(tabs: tabs));
    }
  }
}
