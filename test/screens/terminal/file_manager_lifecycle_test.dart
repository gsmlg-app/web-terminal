import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:terminal_core/terminal_core.dart';

class _Spec extends Fake implements HostSpec {}

class _FailureSpec extends Fake implements HostSpec {
  @override
  HostConnector createConnector() => _FailureConnector();
}

class _FailureConnector extends HostConnector<Host> {
  @override
  Future<Host> createHost() =>
      Future.error(StateError('fixture authentication failure'));
}

class _Sibling with Plugin {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _Host extends Fake implements Host {
  _Host(this.result);
  final Future<FileSystem> result;
  int disconnects = 0;
  @override
  Future<FileSystem> connectFileSystem() => result;
  @override
  Future<void> disconnect() async {
    disconnects++;
  }
}

class _Fs extends Fake implements FileSystem {
  int closes = 0;
  Object? closeError;
  final listings = <String, Stream<FileSystemEntity>>{};
  Future<Directory>? home;
  @override
  final p.Context path = p.Context(style: p.Style.posix);
  @override
  Directory directory(String path) => _Directory(this, path);
  @override
  Future<void> close() async {
    closes++;
    if (closeError != null) throw closeError!;
  }
}

class _Directory extends Fake implements Directory {
  _Directory(this.fileSystem, this.path);
  @override
  final _Fs fileSystem;
  @override
  final String path;
  @override
  String get basename => fileSystem.path.basename(path);
  @override
  FileStat? get cachedStat => null;
  @override
  Future<Directory> get absolute =>
      fileSystem.home ?? Future.value(_Directory(fileSystem, '/home'));
  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) => fileSystem.listings[path] ?? const Stream.empty();
}

class _File extends Fake implements File {
  _File(this.path);
  @override
  final String path;
  @override
  String get basename => p.basename(path);
  @override
  FileStat? get cachedStat => null;
}

Future<void> _show(WidgetTester tester, FileManagerPlugin plugin) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: Scaffold(body: Builder(builder: plugin.build)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('initial listing keeps its loading indicator until completion', (
    tester,
  ) async {
    final listing = StreamController<FileSystemEntity>();
    final fs = _Fs()..listings['/home'] = listing.stream;
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await _show(tester, plugin);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await listing.close();
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    manager.remove(plugin);
  });

  testWidgets('late filesystem cleanup errors are reported', (tester) async {
    final pending = Completer<FileSystem>();
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(pending.future));
    manager.remove(plugin);
    final fs = _Fs()..closeError = StateError('fixture close failure');
    pending.complete(fs);
    await tester.pump();
    expect(tester.takeException(), isA<StateError>());
    expect(fs.closes, 1);
  });

  testWidgets('late filesystem is closed after the tab is removed', (
    tester,
  ) async {
    final pending = Completer<FileSystem>();
    final plugin = FileManagerPlugin();
    final sibling = _Sibling();
    final manager = PluginManager(_Spec())
      ..add(sibling)
      ..add(plugin);
    final host = _Host(pending.future);
    manager.didConnected(host);
    manager.remove(plugin);
    final fs = _Fs();
    pending.complete(fs);
    await tester.pump();
    expect(fs.closes, 1);
    expect(plugin.currentPath.value, isNull);
    expect(host.disconnects, 0);
    expect(sibling.connected, isTrue);
    manager.remove(sibling);
  });

  testWidgets(
    'removing files closes its filesystem and keeps sibling connected',
    (tester) async {
      final fs = _Fs();
      final plugin = FileManagerPlugin();
      final sibling = _Sibling();
      final manager = PluginManager(_Spec())
        ..add(sibling)
        ..add(plugin);
      final host = _Host(Future.value(fs));
      manager.didConnected(host);
      await tester.pump();
      expect(plugin.currentPath.value, '/home');
      manager.remove(plugin);
      await tester.pump();
      expect(fs.closes, 1);
      expect(host.disconnects, 0);
      expect(sibling.connected, isTrue);
      manager.remove(sibling);
    },
  );

  testWidgets(
    'home initialization failure closes its filesystem and is visible',
    (tester) async {
      final home = Completer<Directory>();
      final fs = _Fs()..home = home.future;
      final plugin = FileManagerPlugin();
      final manager = PluginManager(_Spec())..add(plugin);
      manager.didConnected(_Host(Future.value(fs)));
      await _show(tester, plugin);
      home.completeError(StateError('fixture home failure'));
      await tester.pump();
      expect(fs.closes, 1);
      expect(find.textContaining('fixture home failure'), findsOneWidget);
      manager.remove(plugin);
      await tester.pump();
      expect(fs.closes, 1);
    },
  );

  testWidgets('disconnect closes filesystem and ignores late navigation', (
    tester,
  ) async {
    final fs = _Fs();
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await tester.pump();
    manager.didDisconnected();
    await plugin.goto('/late');
    await tester.pump();
    expect(plugin.currentPath.value, isNull);
    expect(fs.closes, 1);
    manager.remove(plugin);
    await tester.pump();
    expect(fs.closes, 1);
  });

  testWidgets('late directory results cannot replace a newer navigation', (
    tester,
  ) async {
    final fs = _Fs();
    final old = StreamController<FileSystemEntity>();
    fs.listings['/home'] = old.stream;
    fs.listings['/next'] = Stream.value(_File('/next/current.txt'));
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await tester.pump();
    await plugin.goto('/next');
    await tester.pump();
    old.add(_File('/home/stale.txt'));
    await old.close();
    await tester.pump();
    expect(plugin.files.value.map((file) => file.basename), ['current.txt']);
    manager.remove(plugin);
  });

  testWidgets('directory results after teardown do not mutate the plugin', (
    tester,
  ) async {
    final fs = _Fs();
    final listing = StreamController<FileSystemEntity>();
    fs.listings['/home'] = listing.stream;
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await tester.pump();
    manager.remove(plugin);
    listing.add(_File('/home/late.txt'));
    await listing.close();
    await tester.pump();
    expect(plugin.files.value, isEmpty);
    expect(plugin.currentPath.value, isNull);
    expect(fs.closes, 1);
  });

  testWidgets('connection errors are visible', (tester) async {
    final result = Completer<FileSystem>();
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(result.future));
    await _show(tester, plugin);
    result.completeError(StateError('fixture connection failure'));
    await tester.pump();
    expect(find.textContaining('fixture connection failure'), findsOneWidget);
    manager.remove(plugin);
  });

  testWidgets('listing errors are visible and refresh retries', (tester) async {
    final fs = _Fs();
    fs.listings['/home'] = Stream.error(StateError('fixture listing failure'));
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await _show(tester, plugin);
    expect(find.textContaining('fixture listing failure'), findsOneWidget);
    fs.listings['/home'] = Stream.value(_File('/home/retry.txt'));
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.textContaining('fixture listing failure'), findsNothing);
    expect(plugin.files.value.map((file) => file.basename), ['retry.txt']);
    manager.remove(plugin);
  });

  testWidgets('connector authentication failures reach the file manager UI', (
    tester,
  ) async {
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_FailureSpec())..add(plugin);
    await _show(tester, plugin);
    await manager.connect();
    await tester.pump();
    expect(
      find.textContaining('fixture authentication failure'),
      findsOneWidget,
    );
    manager.remove(plugin);
  });

  testWidgets('directory taps navigate and list remote children', (
    tester,
  ) async {
    final fs = _Fs();
    fs.listings['/home'] = Stream.value(_Directory(fs, '/home/sub'));
    fs.listings['/home/sub'] = Stream.value(_File('/home/sub/nested.txt'));
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await _show(tester, plugin);
    await tester.pumpAndSettle();
    await tester.tap(find.text('sub'));
    await tester.pumpAndSettle();
    expect(plugin.currentPath.value, '/home/sub');
    expect(plugin.files.value.map((file) => file.basename), ['nested.txt']);
    manager.remove(plugin);
  });

  testWidgets('regular files do not invoke an unavailable editor service', (
    tester,
  ) async {
    final fs = _Fs();
    fs.listings['/home'] = Stream.value(_File('/home/readme.txt'));
    final plugin = FileManagerPlugin();
    final manager = PluginManager(_Spec())..add(plugin);
    manager.didConnected(_Host(Future.value(fs)));
    await _show(tester, plugin);
    await tester.pumpAndSettle();
    await tester.tap(find.text('readme.txt'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    manager.remove(plugin);
  });
}
