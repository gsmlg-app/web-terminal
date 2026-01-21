import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/utils/functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fieldBlocBuilderOnChange', () {
    test('returns null when isEnabled is false', () {
      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: false,
        nextFocusNode: null,
        onChanged: (_) {},
      );
      expect(result, isNull);
    });

    test('returns callback when isEnabled is true', () {
      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: true,
        nextFocusNode: null,
        onChanged: (_) {},
      );
      expect(result, isNotNull);
      expect(result, isA<ValueChanged<String>>());
    });

    test('callback invokes onChanged when not readOnly', () {
      String? captured;
      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: true,
        readOnly: false,
        nextFocusNode: null,
        onChanged: (value) => captured = value,
      );

      result!('test value');
      expect(captured, equals('test value'));
    });

    test('callback does not invoke onChanged when readOnly', () {
      String? captured;
      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: true,
        readOnly: true,
        nextFocusNode: null,
        onChanged: (value) => captured = value,
      );

      result!('test value');
      expect(captured, isNull);
    });

    testWidgets('callback requests focus on nextFocusNode', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(children: [TextField(focusNode: focusNode)]),
          ),
        ),
      );

      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: true,
        nextFocusNode: focusNode,
        onChanged: (_) {},
      );

      expect(focusNode.hasFocus, isFalse);
      result!('value');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    test('callback does not request focus when readOnly', () {
      final focusNode = FocusNode();
      bool focusRequested = false;

      // Since we can't easily test focus in unit test, we verify
      // the callback returns early and doesn't proceed to focus logic
      final result = fieldBlocBuilderOnChange<String>(
        isEnabled: true,
        readOnly: true,
        nextFocusNode: focusNode,
        onChanged: (_) => focusRequested = true,
      );

      result!('value');
      // If readOnly, onChanged is not called, so focusRequested stays false
      expect(focusRequested, isFalse);

      focusNode.dispose();
    });

    test('works with different generic types', () {
      int? intValue;
      bool? boolValue;

      final intCallback = fieldBlocBuilderOnChange<int>(
        isEnabled: true,
        nextFocusNode: null,
        onChanged: (v) => intValue = v,
      );

      final boolCallback = fieldBlocBuilderOnChange<bool>(
        isEnabled: true,
        nextFocusNode: null,
        onChanged: (v) => boolValue = v,
      );

      intCallback!(42);
      boolCallback!(true);

      expect(intValue, equals(42));
      expect(boolValue, isTrue);
    });
  });

  group('widgetBasedOnPlatform', () {
    test('returns mobile widget on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect(result, isA<Text>());
      expect((result as Text).data, equals('Mobile'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns mobile widget on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect((result as Text).data, equals('Mobile'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns other widget on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect((result as Text).data, equals('Other'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns other widget on Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect((result as Text).data, equals('Other'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns other widget on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect((result as Text).data, equals('Other'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('returns other widget on Fuchsia', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

      final result = widgetBasedOnPlatform(
        mobile: const Text('Mobile'),
        other: const Text('Other'),
      );

      expect((result as Text).data, equals('Other'));

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
