import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/src/terminal_extra_keys.dart';
import 'package:xterm/xterm.dart';

void main() {
  const labels = [
    'ESC',
    'TAB',
    'CTRL',
    'ALT',
    'HOME',
    'END',
    'PGUP',
    '←',
    '↓',
    '↑',
    '→',
    'PGDN',
  ];

  Future<void> pumpKeys(
    WidgetTester tester, {
    double width = 360,
    double textScale = 1,
    bool ctrlPressed = false,
    bool altPressed = false,
    VoidCallback? onToggleCtrl,
    VoidCallback? onToggleAlt,
    ValueChanged<TerminalKey>? onKey,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: TerminalExtraKeys(
                  ctrlPressed: ctrlPressed,
                  altPressed: altPressed,
                  onToggleCtrl: onToggleCtrl ?? () {},
                  onToggleAlt: onToggleAlt ?? () {},
                  onKey: onKey ?? (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('narrow screens show two ordered rows with 48px touch targets',
      (tester) async {
    await pumpKeys(tester);

    for (var index = 0; index < labels.length; index++) {
      final key = find.bySemanticsLabel(labels[index]);
      expect(find.byTooltip(labels[index]), findsOneWidget);
      final rect = tester.getRect(key);
      expect(rect.height, 48);
      expect(rect.width, 60);
      expect(rect.top, index < 6 ? 0 : 48);
      expect(rect.left, (index % 6) * 60);
    }
    expect(tester.getSize(find.byType(TerminalExtraKeys)).height, 96);
    expect(tester.takeException(), isNull);
  });

  for (final width in [576.0, 720.0]) {
    testWidgets('width $width shows all twelve keys in one row',
        (tester) async {
      await pumpKeys(tester, width: width);

      for (var index = 0; index < labels.length; index++) {
        final rect = tester.getRect(find.bySemanticsLabel(labels[index]));
        expect(rect.top, 0);
        expect(rect.left, closeTo(index * width / 12, 0.01));
        expect(rect.width, closeTo(width / 12, 0.01));
        expect(rect.height, 48);
      }
      expect(tester.getSize(find.byType(TerminalExtraKeys)).height, 48);
      expect(tester.takeException(), isNull);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('large text fits narrow keys in ${brightness.name} mode',
        (tester) async {
      await pumpKeys(
        tester,
        width: 320,
        textScale: 4,
        brightness: brightness,
      );

      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
        final rect = tester.getRect(find.bySemanticsLabel(label));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
        expect(rect.height, 48);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('non-modifier keys send the matching terminal key',
      (tester) async {
    final sent = <TerminalKey>[];
    await pumpKeys(tester, onKey: sent.add);

    for (final label
        in labels.where((label) => label != 'CTRL' && label != 'ALT')) {
      await tester.tap(find.text(label));
    }

    expect(sent, [
      TerminalKey.escape,
      TerminalKey.tab,
      TerminalKey.home,
      TerminalKey.end,
      TerminalKey.pageUp,
      TerminalKey.arrowLeft,
      TerminalKey.arrowDown,
      TerminalKey.arrowUp,
      TerminalKey.arrowRight,
      TerminalKey.pageDown,
    ]);
  });

  testWidgets('modifier callbacks leave state ownership with the parent',
      (tester) async {
    var ctrlTaps = 0;
    var altTaps = 0;
    final sent = <TerminalKey>[];
    await pumpKeys(
      tester,
      onToggleCtrl: () => ctrlTaps++,
      onToggleAlt: () => altTaps++,
      onKey: sent.add,
    );
    await tester.tap(find.text('CTRL'));
    await tester.tap(find.text('ALT'));
    await tester.pump();

    expect(ctrlTaps, 1);
    expect(altTaps, 1);
    expect(sent, isEmpty);
    for (final label in ['CTRL', 'ALT']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          label: label,
          textDirection: TextDirection.ltr,
          isButton: true,
          hasToggledState: true,
          hasTapAction: true,
        ),
      );
    }

    await pumpKeys(tester, ctrlPressed: true, altPressed: true);

    for (final label in ['CTRL', 'ALT']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        matchesSemantics(
          label: label,
          textDirection: TextDirection.ltr,
          isButton: true,
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
    }
  });

  testWidgets('tapping every key retains terminal focus and the soft keyboard',
      (tester) async {
    final terminalFocus = FocusNode();
    addTearDown(terminalFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: TerminalView(
                  Terminal(),
                  focusNode: terminalFocus,
                  autofocus: true,
                ),
              ),
              TerminalExtraKeys(
                ctrlPressed: false,
                altPressed: false,
                onToggleCtrl: () {},
                onToggleAlt: () {},
                onKey: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(terminalFocus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    for (final label in labels) {
      await tester.tap(find.text(label));
      await tester.pump();
      expect(terminalFocus.hasFocus, isTrue, reason: label);
      expect(tester.testTextInput.isVisible, isTrue, reason: label);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
