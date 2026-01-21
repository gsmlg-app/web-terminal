import 'package:flutter/widgets.dart';
import 'package:flutter_form_bloc/src/theme/form_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrollableFormTheme', () {
    test('has default values', () {
      const theme = ScrollableFormTheme();

      expect(theme.duration, equals(const Duration(milliseconds: 500)));
      expect(theme.alignment, equals(0.05));
      expect(theme.curve, equals(Curves.ease));
      expect(
        theme.alignmentPolicy,
        equals(ScrollPositionAlignmentPolicy.explicit),
      );
    });

    test('can be constructed with custom values', () {
      const theme = ScrollableFormTheme(
        duration: Duration(seconds: 1),
        alignment: 0.5,
        curve: Curves.linear,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );

      expect(theme.duration, equals(const Duration(seconds: 1)));
      expect(theme.alignment, equals(0.5));
      expect(theme.curve, equals(Curves.linear));
      expect(
        theme.alignmentPolicy,
        equals(ScrollPositionAlignmentPolicy.keepVisibleAtEnd),
      );
    });

    test('can be const constructed', () {
      const theme = ScrollableFormTheme();
      expect(theme, isA<ScrollableFormTheme>());
    });

    group('copyWith', () {
      test('returns new instance with no changes when called without args', () {
        const original = ScrollableFormTheme(
          duration: Duration(seconds: 2),
          alignment: 0.1,
        );
        final copied = original.copyWith();

        expect(copied.duration, equals(const Duration(seconds: 2)));
        expect(copied.alignment, equals(0.1));
        expect(copied.curve, equals(Curves.ease));
        expect(
          copied.alignmentPolicy,
          equals(ScrollPositionAlignmentPolicy.explicit),
        );
      });

      test('updates duration only', () {
        const original = ScrollableFormTheme();
        final copied = original.copyWith(duration: const Duration(seconds: 3));

        expect(copied.duration, equals(const Duration(seconds: 3)));
        expect(copied.alignment, equals(0.05));
      });

      test('updates alignment only', () {
        const original = ScrollableFormTheme();
        final copied = original.copyWith(alignment: 0.8);

        expect(copied.alignment, equals(0.8));
        expect(copied.duration, equals(const Duration(milliseconds: 500)));
      });

      test('updates curve only', () {
        const original = ScrollableFormTheme();
        final copied = original.copyWith(curve: Curves.bounceIn);

        expect(copied.curve, equals(Curves.bounceIn));
      });

      test('updates alignmentPolicy only', () {
        const original = ScrollableFormTheme();
        final copied = original.copyWith(
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );

        expect(
          copied.alignmentPolicy,
          equals(ScrollPositionAlignmentPolicy.keepVisibleAtStart),
        );
      });

      test('updates all fields', () {
        const original = ScrollableFormTheme();
        final copied = original.copyWith(
          duration: const Duration(seconds: 5),
          alignment: 0.9,
          curve: Curves.easeInOut,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );

        expect(copied.duration, equals(const Duration(seconds: 5)));
        expect(copied.alignment, equals(0.9));
        expect(copied.curve, equals(Curves.easeInOut));
        expect(
          copied.alignmentPolicy,
          equals(ScrollPositionAlignmentPolicy.keepVisibleAtEnd),
        );
      });
    });

    group('equality', () {
      test('equal instances have same props', () {
        const theme1 = ScrollableFormTheme(
          duration: Duration(seconds: 1),
          alignment: 0.5,
        );
        const theme2 = ScrollableFormTheme(
          duration: Duration(seconds: 1),
          alignment: 0.5,
        );

        expect(theme1, equals(theme2));
        expect(theme1.hashCode, equals(theme2.hashCode));
      });

      test('different instances are not equal', () {
        const theme1 = ScrollableFormTheme(alignment: 0.1);
        const theme2 = ScrollableFormTheme(alignment: 0.2);

        expect(theme1, isNot(equals(theme2)));
      });
    });

    group('props', () {
      test('contains all fields', () {
        const theme = ScrollableFormTheme(
          duration: Duration(seconds: 1),
          alignment: 0.5,
          curve: Curves.linear,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );

        expect(theme.props, hasLength(4));
        expect(theme.props, contains(const Duration(seconds: 1)));
        expect(theme.props, contains(0.5));
        expect(theme.props, contains(Curves.linear));
        expect(
          theme.props,
          contains(ScrollPositionAlignmentPolicy.keepVisibleAtEnd),
        );
      });
    });

    group('toString', () {
      test('includes class name and properties', () {
        const theme = ScrollableFormTheme();
        final str = theme.toString();

        expect(str, contains('ScrollableFormTheme'));
        expect(str, contains('duration'));
        expect(str, contains('alignment'));
        expect(str, contains('curve'));
        expect(str, contains('alignmentPolicy'));
      });
    });
  });
}
