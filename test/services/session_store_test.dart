import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:web_terminal/services/session_store.dart';

Map<String, dynamic> layout(String directory) => {
  'activeIndex': 0,
  'tabs': [
    <String, dynamic>{
      'type': 'local',
      'profileId': 1,
      'workingDirectory': directory,
    },
  ],
};

void main() {
  late Directory directory;
  var tick = 0;
  SessionStore? active;

  Future<SessionStore> open() async {
    await active?.close();
    return active = await SessionStore.open(
      directory,
      now: () => DateTime.utc(2026, 11, 13).add(Duration(seconds: tick++)),
    );
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('terminal-sessions-');
    tick = 0;
    active = null;
  });

  tearDown(() async {
    await active?.close();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('a new process can recover changes without a normal exit', () async {
    final first = await open();
    await first.record(layout('/one'));
    await first.record(layout('/two'));

    final restarted = await open();
    expect(restarted.recovery!.layout, layout('/two'));
    expect(restarted.history, isEmpty);
    expect(restarted.latest!.kind, SessionSnapshotKind.recovery);
  });

  test('retains five exits and never rotates manually saved records', () async {
    var store = await open();
    await store.record(layout('/saved'));
    final manual = await store.save('My workspace', layout('/saved'));
    final group = await store.save('My group', layout('/group'), group: true);
    await store.finishExit();
    for (var index = 0; index < 7; index++) {
      store = await open();
      await store.record(layout('/run/$index'));
      await store.finishExit();
    }
    store = await open();
    expect(store.history, hasLength(5));
    expect(store.history.first.layout, layout('/run/6'));
    expect(store.history.last.layout, layout('/run/2'));
    expect(store.saved.map((s) => s.id), containsAll([manual.id, group.id]));
    await store.deleteSaved(manual.id);
    expect((await open()).saved.map((s) => s.id), [group.id]);
  });

  test('unused launches preserve recovery and exit history', () async {
    final first = await open();
    await first.record(layout('/last-exit'));
    await first.finishExit();
    final second = await open();
    await second.record(layout('/crashed'));
    final third = await open();
    await third.finishExit();
    final fourth = await open();
    expect(fourth.recovery!.layout, layout('/crashed'));
    expect(fourth.history.single.layout, layout('/last-exit'));
  });

  test('writes capture immutable values in submission order', () async {
    final store = await open();
    final state = layout('/first');
    final first = store.record(state);
    (state['tabs'] as List).clear();
    final second = store.record(layout('/second'));
    await Future.wait([first, second]);
    await store.finishExit();
    expect((await open()).history.single.layout, layout('/second'));
  });

  test('closing all tabs deliberately records an empty workspace', () async {
    final store = await open();
    await store.record(layout('/open'));
    await store.record({'tabs': [], 'activeIndex': 0});
    await store.finishExit();
    expect((await open()).history.single.layout['tabs'], isEmpty);
  });

  test(
    'a corrupt current record falls back to the previous valid write',
    () async {
      final store = await open();
      await store.record(layout('/good'));
      await store.record(layout('/latest'));
      await Hive.box<dynamic>('sessions').put('current', {'invalid': true});
      await Hive.box<dynamic>('sessions').flush();
      expect((await open()).recovery!.layout, layout('/good'));
    },
  );

  test(
    'legacy data is imported once and is not removed from its source',
    () async {
      final legacy = jsonEncode(layout('/legacy'));
      final first = active = await SessionStore.open(directory, legacy: legacy);
      expect(first.recovery!.layout, layout('/legacy'));
      await first.record(layout('/new'));
      await first.finishExit();
      await first.close();
      final next = active = await SessionStore.open(directory, legacy: legacy);
      expect(next.latest!.layout, layout('/new'));
      expect(next.history, hasLength(1));
    },
  );

  test(
    'only descriptor fields are saved, never environment or credentials',
    () async {
      final store = await open();
      final state = layout('/project');
      final tab = (state['tabs'] as List).single as Map<String, dynamic>;
      tab.addAll({
        'password': 'secret',
        'environment': {'TOKEN': 'secret'},
      });
      await store.record(state);
      final serialized = jsonEncode(
        Hive.box<dynamic>('sessions').get('current'),
      );
      expect(serialized, isNot(contains('secret')));
      expect(serialized, isNot(contains('password')));
    },
  );

  test('an unreadable future schema is preserved and rejected', () async {
    final box = await Hive.openBox<dynamic>('sessions', path: directory.path);
    final data = {'schemaVersion': 999, 'tabs': []};
    await box.put('current', data);
    await box.close();
    await expectLater(open(), throwsFormatException);
    final preserved = await Hive.openBox<dynamic>(
      'sessions',
      path: directory.path,
    );
    expect(preserved.get('current'), data);
    await preserved.close();
  });
}
