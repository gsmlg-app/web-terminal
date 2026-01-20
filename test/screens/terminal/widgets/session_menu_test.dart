import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/terminal/widgets/session_menu.dart';

void main() {
  group('SessionMenu Tests', () {
    late bool localShellCalled;
    late bool sshSessionCalled;
    late bool sftpSessionCalled;

    setUp(() {
      localShellCalled = false;
      sshSessionCalled = false;
      sftpSessionCalled = false;
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              SessionMenu(
                onNewLocalShell: () => localShellCalled = true,
                onNewSshSession: () => sshSessionCalled = true,
                onNewSftpSession: () => sftpSessionCalled = true,
              ),
            ],
          ),
          body: const SizedBox(),
        ),
      );
    }

    testWidgets('renders add button icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('opens popup menu on tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Local Shell'), findsOneWidget);
      expect(find.text('SSH Shell'), findsOneWidget);
      expect(find.text('SFTP Server'), findsOneWidget);
    });

    testWidgets('shows correct subtitles in menu', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Open a terminal on this device'), findsOneWidget);
      expect(find.text('Connect to a remote server'), findsOneWidget);
      expect(find.text('Browse remote files (coming soon)'), findsOneWidget);
    });

    testWidgets('shows correct icons in menu', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.terminal), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('calls onNewLocalShell when Local Shell selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell'));
      await tester.pumpAndSettle();

      expect(localShellCalled, isTrue);
      expect(sshSessionCalled, isFalse);
      expect(sftpSessionCalled, isFalse);
    });

    testWidgets('calls onNewSshSession when SSH Shell selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SSH Shell'));
      await tester.pumpAndSettle();

      expect(localShellCalled, isFalse);
      expect(sshSessionCalled, isTrue);
      expect(sftpSessionCalled, isFalse);
    });

    testWidgets('SFTP option is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Tap on SFTP - since it's disabled, callback should not be called
      await tester.tap(find.text('SFTP Server'));
      await tester.pumpAndSettle();

      // SFTP is disabled so menu should still be open and callback not called
      expect(sftpSessionCalled, isFalse);
    });

    testWidgets('menu closes after selection', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Local Shell'), findsOneWidget);

      await tester.tap(find.text('Local Shell'));
      await tester.pumpAndSettle();

      // Menu should be closed
      expect(find.text('Open a terminal on this device'), findsNothing);
    });
  });
}
