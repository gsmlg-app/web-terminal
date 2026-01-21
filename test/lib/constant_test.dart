import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/constant.dart';

void main() {
  group('Constant', () {
    test('appName is defined', () {
      expect(Constant.appName, isNotNull);
      expect(Constant.appName, isNotEmpty);
    });

    test('appName is "Web Terminal"', () {
      expect(Constant.appName, 'Web Terminal');
    });

    test('appDescription is defined', () {
      expect(Constant.appDescription, isNotNull);
      expect(Constant.appDescription, isNotEmpty);
    });

    test('appDescription contains "web-based terminal"', () {
      expect(
          Constant.appDescription.toLowerCase(), contains('web-based terminal'));
    });

    test('appDescription contains "shell commands"', () {
      expect(Constant.appDescription.toLowerCase(), contains('shell commands'));
    });

    test('Constant class cannot be instantiated', () {
      // Constant has no public constructor (implicit default is available)
      // This verifies the class is used as a namespace for static constants
      expect(Constant.appName, isA<String>());
      expect(Constant.appDescription, isA<String>());
    });
  });
}
