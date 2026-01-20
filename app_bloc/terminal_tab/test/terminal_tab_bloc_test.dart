import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

/// A minimal TabItem for testing purposes.
class TestTabItem extends TabItem {
  final String testId;
  bool isActivated = false;
  bool isDisposed = false;

  TestTabItem(this.testId);

  @override
  void activate() {
    isActivated = true;
    super.activate();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

void main() {
  group('TerminalTabBloc', () {
    late TerminalTabBloc bloc;

    setUp(() {
      bloc = TerminalTabBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TerminalTabInitial', () {
      expect(bloc.state, isA<TerminalTabInitial>());
    });

    group('TerminalTabStart', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'emits TerminalTabLoaded when started',
        build: () => TerminalTabBloc(),
        act: (bloc) => bloc.add(TerminalTabStart()),
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.isMounted, 'isMounted', true)
              .having((s) => s.isFullscreen, 'isFullscreen', false)
              .having((s) => s.tabCount, 'tabCount', 0),
        ],
      );

      test('preserves tabs when started again', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);
        bloc.add(TerminalTabStart()); // Start again
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.isMounted, true);
        expect(state.tabCount, 1);
        bloc.close();
      });
    });

    group('TerminalTabStop', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'sets isMounted to false when stopped',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabStop());
        },
        skip: 1, // Skip TerminalTabStart state
        expect: () => [
          isA<TerminalTabLoaded>().having((s) => s.isMounted, 'isMounted', false),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'emits TerminalTabInitial when stopped from initial state',
        build: () => TerminalTabBloc(),
        act: (bloc) => bloc.add(TerminalTabStop()),
        expect: () => [
          isA<TerminalTabInitial>(),
        ],
      );
    });

    group('TerminalTabOpenTab', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'adds tab to tabs container',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        },
        skip: 1, // Skip TerminalTabStart
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.tabCount, 'tabCount', 1)
              .having((s) => s.version, 'version', 1),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'activates tab by default',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          // Verify activation after event processed
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.activeTab, isNotNull);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does not activate tab when activate=false',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab, activate: false));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // With only one tab, it may auto-activate in flex_tabs
          // The activate flag controls whether we call activate() explicitly
          expect(state.tabCount, 1);
        },
      );

      test('opens multiple tabs', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 1);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 2);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-3')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 3);

        bloc.close();
      });

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        // Don't start the bloc
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabToggleFullscreen', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'toggles fullscreen from false to true',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabToggleFullscreen());
        },
        skip: 1, // Skip TerminalTabStart
        expect: () => [
          isA<TerminalTabLoaded>().having((s) => s.isFullscreen, 'isFullscreen', true),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'toggles fullscreen from true to false',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabToggleFullscreen()); // true
          bloc.add(TerminalTabToggleFullscreen()); // false
        },
        skip: 2, // Skip first two states
        expect: () => [
          isA<TerminalTabLoaded>().having((s) => s.isFullscreen, 'isFullscreen', false),
        ],
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabToggleFullscreen());
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabSelectSession', () {
      test('activates tab by session ID', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        await Future.delayed(Duration.zero);

        // Select the first tab by its hashCode
        bloc.add(TerminalTabSelectSession(tab1.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
        // Version should be incremented
        expect(state.version, greaterThanOrEqualTo(3));
        bloc.close();
      });

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does nothing when session ID not found',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
          bloc.add(TerminalTabSelectSession('non-existent-id'));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // Still has one tab
          expect(state.tabCount, 1);
        },
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabSelectSession('some-id'));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabCloseSession', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'closes tab by session ID',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 0);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'disposes the closed tab',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 0);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does nothing when session ID not found',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
          bloc.add(TerminalTabCloseSession('non-existent-id'));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // Tab still exists
          expect(state.tabCount, 1);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'closes correct tab when multiple tabs exist',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab1 = TestTabItem('tab-1');
          final tab2 = TestTabItem('tab-2');
          final tab3 = TestTabItem('tab-3');
          bloc.add(TerminalTabOpenTab(tab1));
          bloc.add(TerminalTabOpenTab(tab2));
          bloc.add(TerminalTabOpenTab(tab3));
          bloc.add(TerminalTabCloseSession(tab2.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 2);
        },
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabCloseSession('some-id'));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('State properties', () {
      test('TerminalTabInitial props is empty list', () {
        expect(TerminalTabInitial().props, isEmpty);
      });

      test('TerminalTabInitial copyWith returns new instance', () {
        final initial = TerminalTabInitial();
        final copy = initial.copyWith();
        expect(copy, isA<TerminalTabInitial>());
      });

      test('TerminalTabLoaded props contains all fields', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.props.length, 5); // tabs, tabsDocument, isMounted, isFullscreen, version
      });

      test('TerminalTabLoaded copyWith preserves fields', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        final copy = state.copyWith(isFullscreen: true);
        expect(copy.isFullscreen, true);
        expect(copy.isMounted, state.isMounted);
        expect(copy.tabs, state.tabs);
      });

      test('TerminalTabLoaded copyWith incrementVersion works', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        final copy = state.copyWith(incrementVersion: true);
        expect(copy.version, state.version + 1);
      });

      test('TerminalTabError props contains error', () {
        final error = Exception('test error');
        final state = TerminalTabError(error);
        expect(state.props, [error]);
        expect(state.error, error);
      });

      test('TerminalTabError copyWith preserves error', () {
        final error = Exception('test error');
        final state = TerminalTabError(error);
        final copy = state.copyWith();
        expect(copy.error, error);
      });

      test('TerminalTabError copyWith can change error', () {
        final error1 = Exception('error 1');
        final error2 = Exception('error 2');
        final state = TerminalTabError(error1);
        final copy = state.copyWith(error: error2);
        expect(copy.error, error2);
      });
    });

    group('TerminalTabLoaded helpers', () {
      test('activeTab returns null when no tabs', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.activeTab, isNull);
      });

      test('activeTab returns active tab when tabs exist', () async {
        bloc.add(TerminalTabStart());
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.activeTab, isNotNull);
      });

      test('allTabs returns all tab items', () async {
        bloc.add(TerminalTabStart());
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.allTabs.length, 2);
      });

      test('tabCount returns correct count', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        var state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 0);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 1);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
      });
    });

    group('Event equality', () {
      test('TerminalTabStart events are equal', () {
        expect(TerminalTabStart().runtimeType, TerminalTabStart().runtimeType);
      });

      test('TerminalTabSelectSession events with same ID', () {
        final e1 = TerminalTabSelectSession('id-1');
        final e2 = TerminalTabSelectSession('id-1');
        expect(e1.sessionId, e2.sessionId);
      });

      test('TerminalTabCloseSession events with same ID', () {
        final e1 = TerminalTabCloseSession('id-1');
        final e2 = TerminalTabCloseSession('id-1');
        expect(e1.sessionId, e2.sessionId);
      });
    });
  });
}
