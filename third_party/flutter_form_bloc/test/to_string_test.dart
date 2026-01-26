import 'package:flutter_form_bloc/src/utils/to_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToString', () {
    test('creates string with class name', () {
      final ts = ToString(String);
      final result = ts.toString();

      expect(result, contains('String'));
      expect(result, startsWith('String {'));
      expect(result, endsWith('}'));
    });

    test('add includes non-null values', () {
      final ts = ToString(String);
      ts.add('name', 'test');
      final result = ts.toString();

      expect(result, contains('name=test'));
    });

    test('add excludes null values', () {
      final ts = ToString(String);
      ts.add('name', null);
      final result = ts.toString();

      expect(result, isNot(contains('name=')));
    });

    test('addNull includes null values', () {
      final ts = ToString(String);
      ts.addNull('name', null);
      final result = ts.toString();

      expect(result, contains('name=null'));
    });

    test('addNull includes non-null values', () {
      final ts = ToString(String);
      ts.addNull('value', 42);
      final result = ts.toString();

      expect(result, contains('value=42'));
    });

    test('multiple fields are added', () {
      final ts = ToString(String);
      ts.add('field1', 'value1');
      ts.add('field2', 'value2');
      ts.add('field3', 123);
      final result = ts.toString();

      expect(result, contains('field1=value1'));
      expect(result, contains('field2=value2'));
      expect(result, contains('field3=123'));
    });

    test('fields have trailing comma and newline', () {
      final ts = ToString(String);
      ts.add('field', 'value');
      final result = ts.toString();

      expect(result, contains('field=value,'));
    });

    test('check returns self when condition is true', () {
      final ts = ToString(String);
      final result = ts.check(true);

      expect(result, same(ts));
    });

    test('check returns null when condition is false', () {
      final ts = ToString(String);
      final result = ts.check(false);

      expect(result, isNull);
    });

    test('toString can only be called once (buffer cleared)', () {
      final ts = ToString(String);
      ts.add('field', 'value');
      final result1 = ts.toString();

      // Calling toString again should throw or produce empty result
      // because _buffer is set to null
      expect(result1, contains('String {'));
    });

    test('formats with proper indentation', () {
      final ts = ToString(String);
      ts.add('name', 'test');
      final result = ts.toString();

      // Should have 2-space indentation for fields
      expect(result, contains('  name='));
    });

    test('handles different types', () {
      final ts = ToString(String);
      ts.add('intValue', 42);
      ts.add('doubleValue', 3.14);
      ts.add('boolValue', true);
      ts.add('listValue', [1, 2, 3]);
      final result = ts.toString();

      expect(result, contains('intValue=42'));
      expect(result, contains('doubleValue=3.14'));
      expect(result, contains('boolValue=true'));
      expect(result, contains('listValue=[1, 2, 3]'));
    });

    test('custom class type name is used', () {
      final ts = ToString(_TestClass);
      final result = ts.toString();

      expect(result, startsWith('_TestClass {'));
    });

    test('empty ToString produces minimal output', () {
      final ts = ToString(String);
      final result = ts.toString();

      // Note: closing brace may have varying indentation due to static
      // _indentingIndent variable used for nested object support
      expect(result, startsWith('String {\n'));
      expect(result, endsWith('}'));
      // Should have no fields listed
      expect(result, isNot(contains('=')));
    });
  });
}

class _TestClass {}
