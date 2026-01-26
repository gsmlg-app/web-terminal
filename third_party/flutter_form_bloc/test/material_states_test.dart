import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/theme/material_states.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleMaterialStateProperty', () {
    test('can be const constructed', () {
      const property = SimpleMaterialStateProperty<Color>(
        normal: Colors.blue,
        disabled: Colors.grey,
      );
      expect(property, isA<SimpleMaterialStateProperty<Color>>());
    });

    test('implements WidgetStateProperty', () {
      const property = SimpleMaterialStateProperty<Color>(
        normal: Colors.blue,
        disabled: Colors.grey,
      );
      expect(property, isA<WidgetStateProperty<Color>>());
    });

    test('stores normal value', () {
      const property = SimpleMaterialStateProperty<Color>(
        normal: Colors.blue,
        disabled: Colors.grey,
      );
      expect(property.normal, equals(Colors.blue));
    });

    test('stores disabled value', () {
      const property = SimpleMaterialStateProperty<Color>(
        normal: Colors.blue,
        disabled: Colors.grey,
      );
      expect(property.disabled, equals(Colors.grey));
    });

    group('resolve', () {
      test('returns normal for empty state set', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({});
        expect(result, equals(Colors.blue));
      });

      test('returns disabled when WidgetState.disabled is present', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({WidgetState.disabled});
        expect(result, equals(Colors.grey));
      });

      test('returns disabled when multiple states including disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({
          WidgetState.hovered,
          WidgetState.disabled,
          WidgetState.focused,
        });
        expect(result, equals(Colors.grey));
      });

      test('returns normal for hovered state without disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({WidgetState.hovered});
        expect(result, equals(Colors.blue));
      });

      test('returns normal for focused state without disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({WidgetState.focused});
        expect(result, equals(Colors.blue));
      });

      test('returns normal for pressed state without disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({WidgetState.pressed});
        expect(result, equals(Colors.blue));
      });

      test('returns normal for selected state without disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final result = property.resolve({WidgetState.selected});
        expect(result, equals(Colors.blue));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const property1 = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        const property2 = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        expect(property1, equals(property2));
      });

      test('different normal values are not equal', () {
        const property1 = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        const property2 = SimpleMaterialStateProperty<Color>(
          normal: Colors.red,
          disabled: Colors.grey,
        );
        expect(property1, isNot(equals(property2)));
      });

      test('different disabled values are not equal', () {
        const property1 = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        const property2 = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.black,
        );
        expect(property1, isNot(equals(property2)));
      });
    });

    group('props', () {
      test('contains normal and disabled', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        expect(property.props, containsAll([Colors.blue, Colors.grey]));
      });

      test('has length 2', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        expect(property.props.length, equals(2));
      });
    });

    group('toString', () {
      test('contains class name', () {
        const property = SimpleMaterialStateProperty<Color>(
          normal: Colors.blue,
          disabled: Colors.grey,
        );
        final str = property.toString();
        expect(str, contains('SimpleMaterialStateProperty'));
      });

      test('contains normal value', () {
        const property = SimpleMaterialStateProperty<int>(
          normal: 100,
          disabled: 50,
        );
        final str = property.toString();
        expect(str, contains('normal=100'));
      });

      test('contains disabled value', () {
        const property = SimpleMaterialStateProperty<int>(
          normal: 100,
          disabled: 50,
        );
        final str = property.toString();
        expect(str, contains('disabled=50'));
      });
    });

    group('generic types', () {
      test('works with double', () {
        const property = SimpleMaterialStateProperty<double>(
          normal: 1.0,
          disabled: 0.5,
        );
        expect(property.resolve({}), equals(1.0));
        expect(property.resolve({WidgetState.disabled}), equals(0.5));
      });

      test('works with int', () {
        const property = SimpleMaterialStateProperty<int>(
          normal: 100,
          disabled: 50,
        );
        expect(property.resolve({}), equals(100));
        expect(property.resolve({WidgetState.disabled}), equals(50));
      });

      test('works with String', () {
        const property = SimpleMaterialStateProperty<String>(
          normal: 'enabled',
          disabled: 'disabled',
        );
        expect(property.resolve({}), equals('enabled'));
        expect(property.resolve({WidgetState.disabled}), equals('disabled'));
      });

      test('works with nullable types', () {
        const property = SimpleMaterialStateProperty<Color?>(
          normal: Colors.blue,
          disabled: null,
        );
        expect(property.resolve({}), equals(Colors.blue));
        expect(property.resolve({WidgetState.disabled}), isNull);
      });
    });
  });
}
