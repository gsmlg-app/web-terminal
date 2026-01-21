import 'dart:io' show Platform;

import 'package:app_artwork/app_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app_artwork exports', () {
    test('exports LogoGSMLGDEV', () {
      expect(LogoGSMLGDEV, isNotNull);
    });

    test('exports LaddingPageLottie', () {
      expect(LaddingPageLottie, isNotNull);
    });
  });

  group('LogoGSMLGDEV', () {
    testWidgets('renders CustomPaint widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoGSMLGDEV(),
          ),
        ),
      );

      // LogoGSMLGDEV contains a CustomPaint (Scaffold may have its own)
      expect(find.descendant(
        of: find.byType(LogoGSMLGDEV),
        matching: find.byType(CustomPaint),
      ), findsOneWidget);
    });

    testWidgets('wraps in AspectRatio with 10:2 ratio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoGSMLGDEV(),
          ),
        ),
      );

      final aspectRatio = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(LogoGSMLGDEV),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(aspectRatio.aspectRatio, 10 / 2);
    });

    testWidgets('renders child widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoGSMLGDEV(
              child: Text('Child'),
            ),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('renders without child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoGSMLGDEV(),
          ),
        ),
      );

      expect(find.byType(LogoGSMLGDEV), findsOneWidget);
    });

    testWidgets('CustomPaint has size 1000x200', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoGSMLGDEV(),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(LogoGSMLGDEV),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(customPaint.size, const Size(1000, 200));
    });

    test('can be const constructed', () {
      const widget = LogoGSMLGDEV();
      expect(widget, isA<LogoGSMLGDEV>());
    });

    test('can be const constructed with key', () {
      const widget = LogoGSMLGDEV(key: Key('logo'));
      expect(widget.key, const Key('logo'));
    });

    testWidgets('golden test (Windows only)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LogoGSMLGDEV()));

      await expectLater(
        find.byType(LogoGSMLGDEV),
        matchesGoldenFile('goldens/gsmlg_dev.png'),
        skip: !Platform.isWindows,
      );
    });
  });

  group('LaddingPageLottie', () {
    test('can be const constructed', () {
      const widget = LaddingPageLottie();
      expect(widget, isA<LaddingPageLottie>());
    });

    test('can be const constructed with key', () {
      const widget = LaddingPageLottie(key: Key('lottie'));
      expect(widget.key, const Key('lottie'));
    });

    test('width parameter is accessible', () {
      const widget = LaddingPageLottie(width: 100);
      expect(widget.width, 100);
    });

    test('height parameter is accessible', () {
      const widget = LaddingPageLottie(height: 200);
      expect(widget.height, 200);
    });

    test('fit parameter is accessible', () {
      const widget = LaddingPageLottie(fit: BoxFit.cover);
      expect(widget.fit, BoxFit.cover);
    });

    test('alignment parameter is accessible', () {
      const widget = LaddingPageLottie(alignment: Alignment.topLeft);
      expect(widget.alignment, Alignment.topLeft);
    });

    test('animate parameter is accessible', () {
      const widget = LaddingPageLottie(animate: false);
      expect(widget.animate, false);
    });

    test('repeat parameter is accessible', () {
      const widget = LaddingPageLottie(repeat: true);
      expect(widget.repeat, true);
    });

    test('reverse parameter is accessible', () {
      const widget = LaddingPageLottie(reverse: true);
      expect(widget.reverse, true);
    });

    test('default values are null', () {
      const widget = LaddingPageLottie();
      expect(widget.width, isNull);
      expect(widget.height, isNull);
      expect(widget.fit, isNull);
      expect(widget.alignment, isNull);
      expect(widget.animate, isNull);
      expect(widget.repeat, isNull);
      expect(widget.reverse, isNull);
      expect(widget.controller, isNull);
      expect(widget.frameRate, isNull);
      expect(widget.delegates, isNull);
      expect(widget.options, isNull);
      expect(widget.onLoaded, isNull);
      expect(widget.bundle, isNull);
      expect(widget.frameBuilder, isNull);
      expect(widget.errorBuilder, isNull);
      expect(widget.package, isNull);
      expect(widget.addRepaintBoundary, isNull);
      expect(widget.filterQuality, isNull);
      expect(widget.onWarning, isNull);
      expect(widget.decoder, isNull);
      expect(widget.renderCache, isNull);
      expect(widget.backgroundLoading, isNull);
    });

    test('package parameter is accessible', () {
      const widget = LaddingPageLottie(package: 'custom_package');
      expect(widget.package, 'custom_package');
    });

    test('addRepaintBoundary parameter is accessible', () {
      const widget = LaddingPageLottie(addRepaintBoundary: false);
      expect(widget.addRepaintBoundary, false);
    });

    test('filterQuality parameter is accessible', () {
      const widget = LaddingPageLottie(filterQuality: FilterQuality.high);
      expect(widget.filterQuality, FilterQuality.high);
    });

    test('backgroundLoading parameter is accessible', () {
      const widget = LaddingPageLottie(backgroundLoading: true);
      expect(widget.backgroundLoading, true);
    });

    testWidgets('golden test (Windows only)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LaddingPageLottie()));

      await expectLater(
        find.byType(LaddingPageLottie),
        matchesGoldenFile('goldens/landing_page.png'),
        skip: !Platform.isWindows,
      );
    });
  });
}
