import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/terminal/widgets/tab_switcher.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';

void main() {
  const sessions = [
    SessionInfo(id: '1', name: '1 ~'),
    SessionInfo(id: '2', name: '2 ~', isRunning: true),
    SessionInfo(id: '3', name: '3 ~'),
  ];

  Future<ValueNotifier<TabSwitcherResult?>> pumpTabSwitcher(
    WidgetTester tester, {
    ValueChanged<List<String>>? onReorder,
    void Function(String sessionId, String title)? onRename,
  }) async {
    final result = ValueNotifier<TabSwitcherResult?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result.value = await showTabSwitcher(
                    context,
                    sessions: sessions,
                    currentSessionId: '1',
                    onReorder: onReorder,
                    onRename: onRename,
                  );
                },
                child: const Text('Open switcher'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open switcher'));
    await tester.pumpAndSettle();
    return result;
  }

  group('Tab switcher', () {
    testWidgets('confirms and returns selected tabs to close', (tester) async {
      final result = await pumpTabSwitcher(tester);

      await tester.tap(find.byTooltip('Select tabs'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tab-switcher-card-2')));
      await tester.tap(find.byKey(const ValueKey('tab-switcher-card-3')));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close selected tabs'));
      await tester.pumpAndSettle();

      expect(find.text('Close 2 Tabs?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();

      final closeResult = result.value;
      expect(closeResult, isA<TabSwitcherCloseSelected>());
      expect((closeResult as TabSwitcherCloseSelected).sessionIds, ['2', '3']);
    });

    testWidgets('reorder button starts reorder and confirms new order', (
      tester,
    ) async {
      final reordered = <List<String>>[];
      await pumpTabSwitcher(tester, onReorder: reordered.add);

      await tester.tap(find.byTooltip('Reorder tabs'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Done reordering'), findsOneWidget);

      final dragStart = tester.getCenter(
        find.byKey(const ValueKey('tab-switcher-card-1')),
      );
      final dragEnd = tester.getCenter(
        find.byKey(const ValueKey('tab-switcher-card-3')),
      );
      final gesture = await tester.startGesture(dragStart);
      await gesture.moveTo(dragEnd);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Done reordering'));
      await tester.pumpAndSettle();

      expect(reordered, [
        ['2', '3', '1'],
      ]);
    });

    testWidgets('long press opens rename input and updates title', (
      tester,
    ) async {
      final renamed = <String, String>{};
      await pumpTabSwitcher(
        tester,
        onRename: (sessionId, title) {
          renamed[sessionId] = title;
        },
      );

      await tester.longPress(find.byKey(const ValueKey('tab-switcher-card-2')));
      await tester.pumpAndSettle();

      expect(find.text('Rename Tab'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Build logs');
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(renamed, {'2': 'Build logs'});
      expect(find.text('Build logs'), findsOneWidget);
    });
  });
}
