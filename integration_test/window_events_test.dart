import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/screens/terminal/close_confirmation.dart';
import 'package:window_manager/window_manager.dart';

/// Close interception on a real macOS window.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final skip = Platform.isMacOS ? false : 'macOS window behavior';

  testWidgets('a guarded window stays open when closed', (tester) async {
    final window = WindowManager.instance.getCurrent()!;
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: AppExitGuard(
          navigatorKey: navigatorKey,
          interceptWindowClose: true,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    window.close();
    await tester.pump(const Duration(milliseconds: 500));

    expect(window.isVisible, isTrue);
  }, skip: skip != false);
}
