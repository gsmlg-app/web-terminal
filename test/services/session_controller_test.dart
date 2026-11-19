import 'dart:io' as io;

import 'package:hive_ce/hive_ce.dart';
import 'package:app_database/app_database.dart';

import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:web_terminal/services/session_store.dart';
import 'package:web_terminal/services/session_controller.dart';

class _Plugin with Plugin {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late io.Directory directory;
  late TerminalTabBloc tabs;
  late SessionController sessions;
  late PluginTab first;
  late _FaultingBox storage;
  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await sessions.store.flush();
  }

  setUp(() async {
    directory = await io.Directory.systemTemp.createTemp('session-controller-');
    tabs = TerminalTabBloc();
    tabs.add(TerminalTabStart());
    await tabs.stream.firstWhere((s) => s is TerminalTabLoaded);
    first = PluginTab(
      _Plugin(),
      PluginManager(LocalHostSpec(workingDirectory: '/tmp')),
      shellProfileId: 7,
    );
    tabs.add(TerminalTabOpenTab(first));
    await tabs.stream.firstWhere(
      (s) => s is TerminalTabLoaded && s.tabCount == 1,
    );
    storage = _FaultingBox(
      await Hive.openBox<dynamic>('sessions', path: directory.path),
    );
    sessions = SessionController(
      store: await SessionStore.open(directory, storage: storage),
      tabs: tabs,
    )..markReady();
  });
  tearDown(() async {
    sessions.dispose();
    for (final tab in (tabs.state as TerminalTabLoaded).allTabs.toList()) {
      tab.dispose();
    }
    await tabs.close();
    await sessions.store.close();
    await directory.delete(recursive: true);
  });
  test('baseline remains unused; rename, grouping and close-all write while route is absent', () async {
    expect(sessions.store.current, isNull);
    tabs.add(TerminalTabRenameSession(first.hashCode.toString(), 'API'));
    tabs.add(TerminalTabCreateGroup(first.hashCode.toString(), 'services'));
    await settle();
    final layout = sessions.store.current!.layout;
    expect((layout['tabs'] as List).single['customTitle'], 'API');
    expect((layout['groups'] as List).single['name'], 'services');
    tabs.add(TerminalTabCloseSession(first.hashCode.toString()));
    await settle();
    expect(sessions.store.current!.layout['tabs'], isEmpty);
    await sessions.prepareExit();
    await sessions.finishExit();
    expect(sessions.store.history.single.layout['tabs'], isEmpty);
  });
  test(
    'group reorder is saved with membership and active tab intact',
    () async {
      final second = PluginTab(
        _Plugin(),
        PluginManager(LocalHostSpec(workingDirectory: '/tmp')),
      );
      tabs.add(TerminalTabOpenTab(second));
      tabs.add(TerminalTabCreateGroup(first.hashCode.toString(), 'one'));
      tabs.add(TerminalTabCreateGroup(second.hashCode.toString(), 'two'));
      await settle();
      final state = tabs.state as TerminalTabLoaded;
      final groups = state.grouping.groups;
      final previous = sessions.store.current!.layout;

      tabs.add(TerminalTabMoveGroupBefore(groups[1].id, groups[0].id));
      await settle();

      final layout = sessions.store.current!.layout;
      expect((layout['groups'] as List).map((group) => group['name']), [
        'two',
        'one',
      ]);
      expect(layout['tabs'], previous['tabs']);
      expect(layout['activeIndex'], previous['activeIndex']);
      await sessions.prepareExit();
      await sessions.finishExit();
      expect(sessions.store.history.single.layout['groups'], layout['groups']);
    },
  );

  test(
    'SFTP records the full path including a change with the same basename',
    () async {
      final plugin = FileManagerPlugin();
      final tab = PluginTab(plugin, PluginManager(SSHHostSpec(SshHost(id: 5))));
      tabs.add(TerminalTabOpenTab(tab));
      await settle();
      plugin.currentPath.value = '/srv/a/app';
      await settle();
      plugin.currentPath.value = '/srv/b/app';
      await settle();
      expect(
        (sessions.store.current!.layout['tabs'] as List)
            .last['workingDirectory'],
        '/srv/b/app',
      );
    },
  );
  test('write error is visible, prevents exit, and can be retried', () async {
    storage.fail = true;
    await sessions.capture(force: true);
    expect(sessions.persistenceError, isNotNull);
    await expectLater(
      sessions.prepareExit(),
      throwsA(isA<io.FileSystemException>()),
    );
    storage.fail = false;
    sessions.resumeAfterCanceledExit();
    await sessions.capture(force: true);
    expect(sessions.persistenceError, isNull);
    await sessions.prepareExit();
    await sessions.finishExit();
    expect(sessions.store.history, hasLength(1));
  });
}

class _FaultingBox extends Fake implements Box<dynamic> {
  _FaultingBox(this.delegate);
  final Box<dynamic> delegate;
  bool fail = false;
  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      delegate.get(key, defaultValue: defaultValue);
  @override
  Iterable<dynamic> get keys => delegate.keys;
  @override
  Future<void> putAll(Map<dynamic, dynamic> values) async {
    if (fail) throw const io.FileSystemException('Disk unavailable');
    await delegate.putAll(values);
  }

  @override
  Future<void> put(dynamic key, dynamic value) => delegate.put(key, value);
  @override
  Future<void> deleteAll(Iterable<dynamic> keys) => delegate.deleteAll(keys);
  @override
  Future<void> delete(dynamic key) => delegate.delete(key);
  @override
  Future<void> flush() => delegate.flush();
  @override
  Future<void> close() => delegate.close();
}
