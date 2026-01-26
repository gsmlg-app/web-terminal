import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';

void main() {
  late TerminalTabBloc realBloc;
  late String? selectedSessionId;
  late bool localShellCalled;
  late List<SessionInfo> testSessions;
  late String? closedSessionId;

  setUp(() {
    realBloc = TerminalTabBloc();
    selectedSessionId = null;
    localShellCalled = false;
    closedSessionId = null;
    testSessions = [
      SessionInfo(
        id: 'session-1',
        name: 'Local Shell 1',
        onClose: () => closedSessionId = 'session-1',
      ),
      SessionInfo(
        id: 'session-2',
        name: 'SSH: server.example.com',
        onClose: () => closedSessionId = 'session-2',
      ),
      SessionInfo(
        id: 'session-3',
        name: 'Local Shell 2',
        onClose: () => closedSessionId = 'session-3',
      ),
    ];
  });

  tearDown(() {
    realBloc.close();
  });

  Widget buildTestWidget({
    String currentSessionName = 'Local Shell 1',
    List<SessionInfo>? sessions,
    bool startBloc = true,
  }) {
    if (startBloc) {
      realBloc.add(TerminalTabStart());
    }

    return MaterialApp(
      home: BlocProvider<TerminalTabBloc>.value(
        value: realBloc,
        child: Scaffold(
          appBar: TerminalAppBar(
            currentSessionName: currentSessionName,
            sessions: sessions ?? testSessions,
            onSessionSelected: (id) => selectedSessionId = id,
            onNewLocalShell: () => localShellCalled = true,
            onNewSshSession: () {},
            onNewSftpSession: () {},
          ),
          body: const SizedBox(),
        ),
      ),
    );
  }

  group('TerminalAppBar Tests', () {
    testWidgets('renders current session name in title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName: 'My Shell',
      ));
      await tester.pumpAndSettle();

      expect(find.text('My Shell'), findsOneWidget);
    });

    testWidgets('shows "Terminal" when no sessions exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName: 'Terminal',
        sessions: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Terminal'), findsOneWidget);
    });

    testWidgets('shows fullscreen icon when not in fullscreen mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit), findsNothing);
    });

    testWidgets('fullscreen button is tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify fullscreen button is present and tappable
      final fullscreenButton = find.byIcon(Icons.fullscreen);
      expect(fullscreenButton, findsOneWidget);

      // Tap should not throw
      await tester.tap(fullscreenButton);
      await tester.pump();

      // Verify the bloc received the event by checking state changed
      final state = realBloc.state;
      expect(state, isA<TerminalTabLoaded>());
      expect((state as TerminalTabLoaded).isFullscreen, isTrue);
    });

    testWidgets('fullscreen button has correct tooltip',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check tooltip via IconButton
      final iconButton = tester.widget<IconButton>(
        find.byType(IconButton).first,
      );
      expect(iconButton.tooltip, equals('Enter fullscreen'));
    });

    testWidgets('shows dropdown arrow next to session name',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('opens session selector popup when title tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on the session name to open dropdown
      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      // Should show all sessions in popup
      expect(find.text('Local Shell 1'),
          findsNWidgets(2)); // One in title, one in menu
      expect(find.text('SSH: server.example.com'), findsOneWidget);
      expect(find.text('Local Shell 2'), findsOneWidget);
    });

    testWidgets('shows check mark next to active session',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName: 'Local Shell 1',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      // The active session should have a check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onSessionSelected when different session tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName: 'Local Shell 1',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SSH: server.example.com'));
      await tester.pumpAndSettle();

      expect(selectedSessionId, equals('session-2'));
    });

    testWidgets('shows close button for each session in menu',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      // Should have close icons for all sessions
      expect(find.byIcon(Icons.close), findsNWidgets(3));
    });

    testWidgets('calls onClose callback when close button tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      // Find and tap the close button for the second session
      final closeButtons = find.byIcon(Icons.close);
      await tester.tap(closeButtons.at(1)); // Second close button
      await tester.pumpAndSettle();

      expect(closedSessionId, equals('session-2'));
    });

    testWidgets('renders SessionMenu with add button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('SessionMenu opens and shows options',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Local Shell'), findsOneWidget);
      expect(find.text('SSH Shell'), findsOneWidget);
    });

    testWidgets('passes callbacks correctly to SessionMenu',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell'));
      await tester.pumpAndSettle();

      expect(localShellCalled, isTrue);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const appBar = TerminalAppBar(
        currentSessionName: 'Test',
        sessions: [],
        onSessionSelected: _noOp,
        onNewLocalShell: _noOpCallback,
        onNewSshSession: _noOpCallback,
        onNewSftpSession: _noOpCallback,
      );

      expect(
          appBar.preferredSize, equals(const Size.fromHeight(kToolbarHeight)));
    });

    testWidgets('handles long session names with overflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName:
            'Very Long Session Name That Should Be Truncated With Ellipsis',
      ));
      await tester.pumpAndSettle();

      // Should still render without error
      expect(
          find.text(
              'Very Long Session Name That Should Be Truncated With Ellipsis'),
          findsOneWidget);
    });

    testWidgets('does not show session selector when sessions is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentSessionName: 'Terminal',
        sessions: [],
      ));
      await tester.pumpAndSettle();

      // With no sessions, tapping "Terminal" should not open a popup
      await tester.tap(find.text('Terminal'));
      await tester.pump();

      // Should not find popup menu items
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });
  });

  group('SessionInfo Tests', () {
    test('SessionInfo holds correct values', () {
      final sessionInfo = SessionInfo(
        id: 'test-id',
        name: 'Test Session',
        onClose: () {},
      );

      expect(sessionInfo.id, equals('test-id'));
      expect(sessionInfo.name, equals('Test Session'));
      expect(sessionInfo.onClose, isNotNull);
    });

    test('SessionInfo onClose is optional', () {
      const sessionInfo = SessionInfo(
        id: 'test-id',
        name: 'Test Session',
      );

      expect(sessionInfo.id, equals('test-id'));
      expect(sessionInfo.name, equals('Test Session'));
      expect(sessionInfo.onClose, isNull);
    });
  });
}

void _noOp(String _) {}
void _noOpCallback() {}
