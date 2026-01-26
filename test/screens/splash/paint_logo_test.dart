import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/screens/splash/paint_logo.dart';

void main() {
  group('LogoPainter', () {
    test('is a CustomPainter', () {
      final painter = LogoPainter();
      expect(painter, isA<CustomPainter>());
    });

    test('can be instantiated', () {
      final painter = LogoPainter();
      expect(painter, isNotNull);
    });

    test('shouldRepaint returns true', () {
      final painter = LogoPainter();
      final oldPainter = LogoPainter();
      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('paint method can be called without errors', () {
      final painter = LogoPainter();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(200, 200);

      // Should not throw
      expect(() => painter.paint(canvas, size), returnsNormally);
    });

    test('paint method works with different sizes', () {
      final painter = LogoPainter();

      final sizes = [
        const Size(100, 100),
        const Size(200, 200),
        const Size(300, 150),
        const Size(50, 50),
        const Size(500, 500),
      ];

      for (final size in sizes) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        expect(() => painter.paint(canvas, size), returnsNormally,
            reason: 'Should paint at size $size');
      }
    });

    test('paint method works with zero size', () {
      final painter = LogoPainter();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size.zero;

      expect(() => painter.paint(canvas, size), returnsNormally);
    });

    test('paint method works with very small size', () {
      final painter = LogoPainter();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1, 1);

      expect(() => painter.paint(canvas, size), returnsNormally);
    });

    test('can be used with CustomPaint widget', () {
      final painter = LogoPainter();
      final widget = CustomPaint(painter: painter);

      expect(widget.painter, painter);
    });
  });
}
