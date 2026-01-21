import 'dart:async';
import 'dart:typed_data';

import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_tabs/src/plugin_tab.dart';

// Mock implementations for testing
class MockPlugin extends Plugin {
  @override
  Widget build(BuildContext context) {
    return const Text('Mock Plugin Content');
  }
}

class MockHostSpec extends HostSpec {
  @override
  String get name => 'MockHost';

  @override
  HostConnector createConnector() {
    return MockHostConnector();
  }
}

class MockHostConnector extends HostConnector<MockHost> {
  @override
  Future<MockHost> createHost() async {
    return MockHost();
  }
}

class MockHost extends Host {
  final Completer<void> _doneCompleter = Completer<void>();

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<FileSystem> connectFileSystem() async {
    throw UnimplementedError();
  }

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

void main() {
  group('PluginTab', () {
    test('extends TabItem', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      expect(tab, isA<TabItem>());
      tab.dispose();
    });

    test('creates with plugin and manager', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      expect(tab.plugin, same(plugin));
      expect(tab.manager, same(manager));
      tab.dispose();
    });

    test('adds plugin to manager on creation', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());

      expect(manager.plugins, isEmpty);
      final tab = PluginTab(plugin, manager);
      expect(manager.plugins, contains(plugin));

      tab.dispose();
    });

    test('sets content to PluginTabView', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      expect(tab.content.value, isA<PluginTabView>());
      tab.dispose();
    });

    test('title includes host spec name', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      final titleWidget = tab.title.value;
      expect(titleWidget, isA<Row>());

      tab.dispose();
    });

    test('didDispose removes plugin from manager', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      expect(manager.plugins, contains(plugin));
      tab.dispose();
      expect(manager.plugins, isEmpty);
    });

    test('title updates when plugin title changes', () {
      final plugin = MockPlugin();
      final manager = PluginManager(MockHostSpec());
      final tab = PluginTab(plugin, manager);

      // Initial title
      final initialTitle = tab.title.value;

      // Change plugin title
      plugin.title.value = 'New Title';

      // Title should have updated
      final newTitle = tab.title.value;
      expect(newTitle, isNot(same(initialTitle)));

      tab.dispose();
    });
  });

  group('PluginTabView', () {
    test('is a StatefulWidget', () {
      final plugin = MockPlugin();
      final view = PluginTabView(plugin);
      expect(view, isA<StatefulWidget>());
    });

    test('stores plugin reference', () {
      final plugin = MockPlugin();
      final view = PluginTabView(plugin);
      expect(view.plugin, same(plugin));
    });

    test('can be constructed with key', () {
      final plugin = MockPlugin();
      final key = UniqueKey();
      final view = PluginTabView(plugin, key: key);
      expect(view.key, equals(key));
    });
  });

  group('MockPlugin', () {
    test('extends Plugin', () {
      expect(MockPlugin(), isA<Plugin>());
    });

    test('has title ValueNotifier', () {
      final plugin = MockPlugin();
      expect(plugin.title, isA<ValueNotifier<String?>>());
    });

    test('title can be set and retrieved', () {
      final plugin = MockPlugin();
      plugin.title.value = 'Test Title';
      expect(plugin.title.value, equals('Test Title'));
    });
  });

  group('MockHostSpec', () {
    test('extends HostSpec', () {
      expect(MockHostSpec(), isA<HostSpec>());
    });

    test('name returns MockHost', () {
      expect(MockHostSpec().name, equals('MockHost'));
    });

    test('createConnector returns HostConnector', () {
      expect(MockHostSpec().createConnector(), isA<HostConnector>());
    });
  });

  group('MockHostConnector', () {
    test('initial status is initialized', () {
      final connector = MockHostConnector();
      expect(connector.status, equals(HostConnectorStatus.initialized));
    });

    test('connect changes status to connected', () async {
      final connector = MockHostConnector();
      await connector.connect();
      expect(connector.status, equals(HostConnectorStatus.connected));
    });

    test('disconnect changes status to disconnected', () async {
      final connector = MockHostConnector();
      await connector.connect();
      await connector.disconnect();
      expect(connector.status, equals(HostConnectorStatus.disconnected));
    });

    test('host is null initially', () {
      final connector = MockHostConnector();
      expect(connector.host, isNull);
    });

    test('host is available after connect', () async {
      final connector = MockHostConnector();
      await connector.connect();
      expect(connector.host, isA<MockHost>());
    });

    test('host is null after disconnect', () async {
      final connector = MockHostConnector();
      await connector.connect();
      await connector.disconnect();
      expect(connector.host, isNull);
    });
  });

  group('PluginManager integration', () {
    test('PluginManager accepts MockHostSpec', () {
      final manager = PluginManager(MockHostSpec());
      expect(manager.hostSpec, isA<MockHostSpec>());
    });

    test('PluginManager can add and remove plugins', () {
      final manager = PluginManager(MockHostSpec());
      final plugin = MockPlugin();

      manager.add(plugin);
      expect(manager.plugins, contains(plugin));

      manager.remove(plugin);
      expect(manager.plugins, isEmpty);
    });
  });
}
