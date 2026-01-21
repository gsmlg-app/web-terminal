import 'package:flutter_form_bloc/src/utils/field_bloc_builder_control_affinity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldBlocBuilderControlAffinity', () {
    test('has exactly 2 values', () {
      expect(FieldBlocBuilderControlAffinity.values, hasLength(2));
    });

    test('leading value exists', () {
      expect(FieldBlocBuilderControlAffinity.leading, isNotNull);
      expect(
        FieldBlocBuilderControlAffinity.leading.name,
        equals('leading'),
      );
    });

    test('trailing value exists', () {
      expect(FieldBlocBuilderControlAffinity.trailing, isNotNull);
      expect(
        FieldBlocBuilderControlAffinity.trailing.name,
        equals('trailing'),
      );
    });

    test('leading index is 0', () {
      expect(FieldBlocBuilderControlAffinity.leading.index, equals(0));
    });

    test('trailing index is 1', () {
      expect(FieldBlocBuilderControlAffinity.trailing.index, equals(1));
    });

    test('values are unique', () {
      final names = FieldBlocBuilderControlAffinity.values.map((e) => e.name);
      expect(names.toSet().length, equals(2));
    });
  });
}
