import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

void main() {
  group('TerminalTabBloc', () {
    test('initial state is TerminalTabInitial', () {
      final bloc = TerminalTabBloc();
      expect(bloc.state, isA<TerminalTabInitial>());
      bloc.close();
    });

    test('TerminalTabStart creates TerminalTabLoaded state', () async {
      final bloc = TerminalTabBloc();
      bloc.add(TerminalTabStart());
      await Future.delayed(Duration.zero);
      expect(bloc.state, isA<TerminalTabLoaded>());
      bloc.close();
    });
  });
}
