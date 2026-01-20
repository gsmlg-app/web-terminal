import 'package:app_feedback/app_feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('showSuccessToast', () {
    testWidgets('displays success toast with title and message',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-success');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                showSuccessToast(
                    context: context, title: 'success', message: 'message');
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 100.0,
                width: 100.0,
                key: tapTarget,
              ),
            );
          }),
        ),
      ));

      await tester.ensureVisible(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('success'), findsNothing);
      await tester.tap(find.byKey(tapTarget));
      expect(find.text('success'), findsNothing);
      await tester.pump(); // schedule animation
      expect(find.text('success'), findsOneWidget);
      expect(find.text('message'), findsOneWidget);
    });

    testWidgets('displays check icon', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-success-icon');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                showSuccessToast(
                    context: context, title: 'Success', message: 'Done!');
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 100.0,
                width: 100.0,
                key: tapTarget,
              ),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows action button when provided',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-success-action');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showSuccessToast(
                  context: context,
                  title: 'Success',
                  message: 'Done!',
                  actionLabel: 'UNDO',
                  onActionPressed: () {},
                );
              },
              child: const Text('Show'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      // Verify the action button is displayed
      expect(find.text('UNDO'), findsOneWidget);
    });
  });

  group('showErrorToast', () {
    testWidgets('displays error toast with title and message',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-error');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                showErrorToast(
                    context: context, title: 'error', message: 'message');
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 100.0,
                width: 100.0,
                key: tapTarget,
              ),
            );
          }),
        ),
      ));

      await tester.ensureVisible(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('error'), findsNothing);
      await tester.tap(find.byKey(tapTarget));
      expect(find.text('error'), findsNothing);
      await tester.pump(); // schedule animation
      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('displays error icon', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-error-icon');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                showErrorToast(
                    context: context, title: 'Error', message: 'Failed!');
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 100.0,
                width: 100.0,
                key: tapTarget,
              ),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows action button when provided',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-error-action');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showErrorToast(
                  context: context,
                  title: 'Error',
                  message: 'Failed!',
                  actionLabel: 'RETRY',
                  onActionPressed: () {},
                );
              },
              child: const Text('Show'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      // Verify the action button is displayed
      expect(find.text('RETRY'), findsOneWidget);
    });
  });

  group('showSnackbar', () {
    testWidgets('displays snackbar with message', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-snackbar');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showSnackbar(
                  context: context,
                  message: const Text('Snackbar message'),
                );
              },
              child: const Text('Show'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      expect(find.text('Snackbar message'), findsOneWidget);
    });

    testWidgets('shows action button when provided',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-snackbar-action');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showSnackbar(
                  context: context,
                  message: const Text('Message'),
                  actionLabel: 'ACTION',
                  onActionPressed: () {},
                );
              },
              child: const Text('Show'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pump();
      // Verify the action button is displayed
      expect(find.text('ACTION'), findsOneWidget);
    });
  });

  group('AppDialogAction', () {
    testWidgets('renders TextButton on Android', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {},
            child: const Text('Action'),
          ),
        ),
      ));

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('renders TextButton on Linux', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.linux),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {},
            child: const Text('Action'),
          ),
        ),
      ));

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders TextButton on Windows', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.windows),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {},
            child: const Text('Action'),
          ),
        ),
      ));

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders CupertinoDialogAction on iOS',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {},
            child: const Text('Action'),
          ),
        ),
      ));

      expect(find.byType(CupertinoDialogAction), findsOneWidget);
    });

    testWidgets('renders CupertinoDialogAction on macOS',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.macOS),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {},
            child: const Text('Action'),
          ),
        ),
      ));

      expect(find.byType(CupertinoDialogAction), findsOneWidget);
    });

    testWidgets('calls onPressed callback when tapped',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Scaffold(
          body: AppDialogAction(
            onPressed: (context) {
              pressed = true;
            },
            child: const Text('Tap Me'),
          ),
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(pressed, isTrue);
    });

    testWidgets('handles null onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const Scaffold(
          body: AppDialogAction(
            onPressed: null,
            child: Text('Disabled'),
          ),
        ),
      ));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });

  group('showAppDialog', () {
    testWidgets('displays adaptive dialog with title and content',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-dialog');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showAppDialog(
                  context: context,
                  title: const Text('Dialog Title'),
                  content: const Text('Dialog Content'),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('displays dialog with actions', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-dialog-actions');
      bool actionPressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showAppDialog(
                  context: context,
                  title: const Text('Title'),
                  content: const Text('Content'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        actionPressed = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(actionPressed, isTrue);
    });
  });

  group('showFullScreenDialog', () {
    testWidgets('displays fullscreen dialog with title',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-fullscreen');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showFullScreenDialog(
                  context: context,
                  title: const Text('Full Screen Title'),
                  builder: (context) => const Center(
                    child: Text('Full Screen Content'),
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('Full Screen Title'), findsOneWidget);
      expect(find.text('Full Screen Content'), findsOneWidget);
    });

    testWidgets('shows close button in AppBar', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-fullscreen-close');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showFullScreenDialog(
                  context: context,
                  title: const Text('Dialog'),
                  builder: (context) => const Text('Content'),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close button pops the dialog', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-fullscreen-pop');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showFullScreenDialog(
                  context: context,
                  title: const Text('Dialog'),
                  builder: (context) => const Text('Content'),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsOneWidget);

      // Find and tap the close IconButton
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsNothing);
    });
  });

  group('BottomSheetAction', () {
    test('creates action with required parameters', () {
      final action = BottomSheetAction(
        title: const Text('Action'),
        onTap: () {},
      );

      expect(action.title, isA<Text>());
      expect(action.onTap, isNotNull);
      expect(action.style, isNull);
    });

    test('creates action with custom style', () {
      final customStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      );
      final action = BottomSheetAction(
        title: const Text('Action'),
        onTap: () {},
        style: customStyle,
      );

      expect(action.style, customStyle);
    });
  });

  group('showBottomSheetActionList', () {
    testWidgets('displays action buttons', (WidgetTester tester) async {
      const Key tapTarget = Key('tap-bottomsheet');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showBottomSheetActionList(
                  context: context,
                  showBackdrop: false, // Disable backdrop to avoid hit test issues
                  actions: [
                    BottomSheetAction(
                      title: const Text('Action 1'),
                      onTap: () {},
                    ),
                    BottomSheetAction(
                      title: const Text('Action 2'),
                      onTap: () {},
                    ),
                  ],
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });

    testWidgets('action tap calls onTap and closes sheet',
        (WidgetTester tester) async {
      const Key tapTarget = Key('tap-bottomsheet-action');
      bool actionTapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return ElevatedButton(
              key: tapTarget,
              onPressed: () {
                showBottomSheetActionList(
                  context: context,
                  showBackdrop: false,
                  actions: [
                    BottomSheetAction(
                      title: const Text('Tap Me'),
                      onTap: () {
                        actionTapped = true;
                      },
                    ),
                  ],
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      ));

      await tester.tap(find.byKey(tapTarget));
      await tester.pumpAndSettle();
      expect(find.text('Tap Me'), findsOneWidget);

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(actionTapped, isTrue);
    });
  });

  group('getWidgetSize', () {
    testWidgets('returns size for rendered widget', (WidgetTester tester) async {
      final GlobalKey testKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            key: testKey,
            width: 150.0,
            height: 75.0,
          ),
        ),
      ));

      final size = getWidgetSize(testKey);
      expect(size, isNotNull);
      expect(size!.width, 150.0);
      expect(size.height, 75.0);
    });

    testWidgets('returns null for key without context',
        (WidgetTester tester) async {
      final GlobalKey unusedKey = GlobalKey();
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 100, height: 100),
        ),
      ));

      final size = getWidgetSize(unusedKey);
      expect(size, isNull);
    });
  });
}
