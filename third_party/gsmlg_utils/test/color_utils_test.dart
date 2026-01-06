import 'package:gsmlg_utils/gsmlg_utils.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('A group of ColorUtils tests', () {
    Color mainColor = Colors.red;
    setUp(() {
      mainColor = Colors.red;
    });

    test('test get material color', () {
      final MaterialColor materialColor =
          GColorUtils.getMaterialColor(mainColor);
      expect(materialColor.toARGB32(), equals(mainColor.toARGB32()));
    });

    test('test lighten color', () {
      final lightenMainColor = GColorUtils.lighten(mainColor);
      expect(lightenMainColor, equals(Color(0xfff77066)));
    });

    test('test darken color', () {
      final darkenMainColor = GColorUtils.darken(mainColor);
      expect(darkenMainColor, equals(Color(0xffea1c0d)));
    });
  });
}
