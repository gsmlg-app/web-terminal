import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/app.dart';

void main() {
  group('App', () {
    test('can be const constructed', () {
      const app = App();
      expect(app, isA<App>());
    });

    test('can be const constructed with key', () {
      const app = App(key: Key('app'));
      expect(app.key, const Key('app'));
    });

    test('is a StatelessWidget', () {
      const app = App();
      expect(app, isA<StatelessWidget>());
    });

    test('App class exists', () {
      expect(App, isNotNull);
    });

    test('App type is correct', () {
      const app = App();
      expect(app.runtimeType.toString(), 'App');
    });
  });
}
