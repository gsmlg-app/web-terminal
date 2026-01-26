import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/devtools_tab.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('DevToolsTab', () {
    test('extends TabItem', () {
      final tab = DevToolsTab();
      expect(tab, isA<TabItem>());
    });

    test('has Terminal instance', () {
      final tab = DevToolsTab();
      expect(tab.terminal, isA<Terminal>());
    });

    test('title is set to DevTools text', () {
      final tab = DevToolsTab();
      final titleWidget = tab.title.value;
      expect(titleWidget, isA<Text>());
      expect((titleWidget as Text).data, equals('DevTools'));
    });

    test('content is set to DevToolsTabView', () {
      final tab = DevToolsTab();
      expect(tab.content.value, isA<DevToolsTabView>());
    });

    test('content DevToolsTabView references the tab', () {
      final tab = DevToolsTab();
      final content = tab.content.value as DevToolsTabView;
      expect(content.tab, same(tab));
    });

    test('creates unique terminal for each instance', () {
      final tab1 = DevToolsTab();
      final tab2 = DevToolsTab();
      expect(tab1.terminal, isNot(same(tab2.terminal)));
    });
  });

  group('DevToolsTabView', () {
    test('is a StatefulWidget', () {
      final tab = DevToolsTab();
      final view = DevToolsTabView(tab);
      expect(view, isA<StatefulWidget>());
    });

    test('stores tab reference', () {
      final tab = DevToolsTab();
      final view = DevToolsTabView(tab);
      expect(view.tab, same(tab));
    });

    test('can be constructed with key', () {
      final tab = DevToolsTab();
      final key = UniqueKey();
      final view = DevToolsTabView(tab, key: key);
      expect(view.key, equals(key));
    });
  });

  group('PlayGround', () {
    test('is a StatelessWidget', () {
      const playground = PlayGround();
      expect(playground, isA<StatelessWidget>());
    });

    test('can be const constructed', () {
      const PlayGround playground = PlayGround();
      expect(playground, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final playground = PlayGround(key: key);
      expect(playground.key, equals(key));
    });
  });

  group('Terminal integration', () {
    test('terminal can write output', () {
      final tab = DevToolsTab();
      expect(() => tab.terminal.write('test output'), returnsNormally);
    });

    test('terminal accepts carriage return newline', () {
      final tab = DevToolsTab();
      expect(() => tab.terminal.write('line1\r\nline2\r\n'), returnsNormally);
    });
  });
}
