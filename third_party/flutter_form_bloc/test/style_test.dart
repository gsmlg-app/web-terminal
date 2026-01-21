import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/utils/style.dart';
import 'package:flutter_form_bloc/src/theme/material_states.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Style', () {
    group('inputDecorationWithoutBorder', () {
      test('is const', () {
        // This should compile without error
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration, isA<InputDecoration>());
      });

      test('has no border', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.border, equals(InputBorder.none));
      });

      test('has no enabledBorder', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.enabledBorder, equals(InputBorder.none));
      });

      test('has no errorBorder', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.errorBorder, equals(InputBorder.none));
      });

      test('has no disabledBorder', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.disabledBorder, equals(InputBorder.none));
      });

      test('has no focusedBorder', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.focusedBorder, equals(InputBorder.none));
      });

      test('has no focusedErrorBorder', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.focusedErrorBorder, equals(InputBorder.none));
      });

      test('has zero contentPadding', () {
        const decoration = Style.inputDecorationWithoutBorder;
        expect(decoration.contentPadding, equals(EdgeInsets.zero));
      });
    });

    group('resolveTextStyle', () {
      test('applies normal color when enabled', () {
        const baseStyle = TextStyle(fontSize: 16);
        const colorProperty = SimpleMaterialStateProperty<Color?>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );

        final result = Style.resolveTextStyle(
          isEnabled: true,
          style: baseStyle,
          color: colorProperty,
        );

        expect(result.fontSize, equals(16));
        expect(result.color, equals(Colors.blue));
      });

      test('applies disabled color when not enabled', () {
        const baseStyle = TextStyle(fontSize: 16);
        const colorProperty = SimpleMaterialStateProperty<Color?>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );

        final result = Style.resolveTextStyle(
          isEnabled: false,
          style: baseStyle,
          color: colorProperty,
        );

        expect(result.fontSize, equals(16));
        expect(result.color, equals(Colors.grey));
      });

      test('preserves other style properties', () {
        const baseStyle = TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        );
        const colorProperty = SimpleMaterialStateProperty<Color?>(
          normal: Colors.black,
          disabled: Colors.grey,
        );

        final result = Style.resolveTextStyle(
          isEnabled: true,
          style: baseStyle,
          color: colorProperty,
        );

        expect(result.fontSize, equals(20));
        expect(result.fontWeight, equals(FontWeight.bold));
        expect(result.fontStyle, equals(FontStyle.italic));
        expect(result.color, equals(Colors.black));
      });

      test('handles null color in property', () {
        const baseStyle = TextStyle(fontSize: 16);
        const colorProperty = SimpleMaterialStateProperty<Color?>(
          normal: Colors.blue,
          disabled: null,
        );

        final result = Style.resolveTextStyle(
          isEnabled: false,
          style: baseStyle,
          color: colorProperty,
        );

        expect(result.color, isNull);
      });
    });

    group('getGroupFieldBlocContentPadding', () {
      test('adds top/bottom padding when visible', () {
        const decoration = InputDecoration(contentPadding: EdgeInsets.all(8));

        final result = Style.getGroupFieldBlocContentPadding(
          isVisible: true,
          decoration: decoration,
        );

        // Original 8 + additional 4 top/bottom
        expect(result, isA<EdgeInsetsGeometry>());
        // Can't directly compare EdgeInsetsGeometry, but we can resolve it
        final resolved = result.resolve(TextDirection.ltr);
        expect(resolved.top, equals(12.0)); // 8 + 4
        expect(resolved.bottom, equals(12.0)); // 8 + 4
        expect(resolved.left, equals(8.0)); // unchanged
        expect(resolved.right, equals(8.0)); // unchanged
      });

      test('adds left padding when not visible', () {
        const decoration = InputDecoration(contentPadding: EdgeInsets.all(8));

        final result = Style.getGroupFieldBlocContentPadding(
          isVisible: false,
          decoration: decoration,
        );

        final resolved = result.resolve(TextDirection.ltr);
        expect(resolved.left, equals(23.0)); // 8 + 15
        expect(resolved.right, equals(8.0)); // unchanged
        expect(resolved.top, equals(8.0)); // unchanged
        expect(resolved.bottom, equals(8.0)); // unchanged
      });

      test('handles null contentPadding as zero', () {
        const decoration = InputDecoration();

        final result = Style.getGroupFieldBlocContentPadding(
          isVisible: true,
          decoration: decoration,
        );

        final resolved = result.resolve(TextDirection.ltr);
        // EdgeInsets.zero + 4 top/bottom
        expect(resolved.top, equals(4.0));
        expect(resolved.bottom, equals(4.0));
        expect(resolved.left, equals(0.0));
        expect(resolved.right, equals(0.0));
      });

      test('handles null contentPadding when not visible', () {
        const decoration = InputDecoration();

        final result = Style.getGroupFieldBlocContentPadding(
          isVisible: false,
          decoration: decoration,
        );

        final resolved = result.resolve(TextDirection.ltr);
        // EdgeInsets.zero + 15 left
        expect(resolved.left, equals(15.0));
        expect(resolved.right, equals(0.0));
        expect(resolved.top, equals(0.0));
        expect(resolved.bottom, equals(0.0));
      });
    });

    group('getInputBorder', () {
      test('returns decoration border when set', () {
        const decoration = InputDecoration(border: OutlineInputBorder());
        const theme = InputDecorationTheme();

        final result = Style.getInputBorder(
          decoration: decoration,
          decorationTheme: theme,
        );

        expect(result, isA<OutlineInputBorder>());
      });

      test('returns theme border when decoration border is null', () {
        const decoration = InputDecoration();
        const theme = InputDecorationTheme(border: OutlineInputBorder());

        final result = Style.getInputBorder(
          decoration: decoration,
          decorationTheme: theme,
        );

        expect(result, isA<OutlineInputBorder>());
      });

      test('returns UnderlineInputBorder as default', () {
        const decoration = InputDecoration();
        const theme = InputDecorationTheme();

        final result = Style.getInputBorder(
          decoration: decoration,
          decorationTheme: theme,
        );

        expect(result, isA<UnderlineInputBorder>());
      });

      test('prefers decoration border over theme border', () {
        const decorationBorder = OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        );
        const themeBorder = OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        );
        const decoration = InputDecoration(border: decorationBorder);
        const theme = InputDecorationTheme(border: themeBorder);

        final result = Style.getInputBorder(
          decoration: decoration,
          decorationTheme: theme,
        );

        // Should use decoration border (radius 10)
        expect(result, equals(decorationBorder));
      });
    });
  });
}
