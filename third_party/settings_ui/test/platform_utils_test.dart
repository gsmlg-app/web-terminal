import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DevicePlatform', () {
    test('has all expected values', () {
      expect(DevicePlatform.values, hasLength(8));
    });

    test('android value exists', () {
      expect(DevicePlatform.android, isNotNull);
      expect(DevicePlatform.android.name, equals('android'));
    });

    test('fuchsia value exists', () {
      expect(DevicePlatform.fuchsia, isNotNull);
      expect(DevicePlatform.fuchsia.name, equals('fuchsia'));
    });

    test('iOS value exists', () {
      expect(DevicePlatform.iOS, isNotNull);
      expect(DevicePlatform.iOS.name, equals('iOS'));
    });

    test('linux value exists', () {
      expect(DevicePlatform.linux, isNotNull);
      expect(DevicePlatform.linux.name, equals('linux'));
    });

    test('macOS value exists', () {
      expect(DevicePlatform.macOS, isNotNull);
      expect(DevicePlatform.macOS.name, equals('macOS'));
    });

    test('windows value exists', () {
      expect(DevicePlatform.windows, isNotNull);
      expect(DevicePlatform.windows.name, equals('windows'));
    });

    test('web value exists', () {
      expect(DevicePlatform.web, isNotNull);
      expect(DevicePlatform.web.name, equals('web'));
    });

    test('custom value exists', () {
      expect(DevicePlatform.custom, isNotNull);
      expect(DevicePlatform.custom.name, equals('custom'));
    });

    test('detect returns a valid platform', () {
      final detected = DevicePlatform.detect();
      expect(DevicePlatform.values.contains(detected), isTrue);
    });

    test('all values are unique', () {
      final names = DevicePlatform.values.map((p) => p.name).toSet();
      expect(names.length, equals(DevicePlatform.values.length));
    });
  });
}
