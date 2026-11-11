import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';

class _Vault extends Fake implements VaultRepository {
  final values = <String, String>{};
  String? delayedKey;
  Completer<void>? readGate;
  @override
  Future<String?> read({required String key}) async {
    if (key == delayedKey) await readGate?.future;
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

class _Settings extends TerminalSettingsBloc {
  _Settings(VaultRepository vault, {int limit = 10, bool restore = false})
    : super(vault: vault) {
    emit(
      TerminalSettingsLoaded(
        maxOpenShells: limit,
        restoreTerminalTabs: restore,
      ),
    );
  }
}

class _Profiles extends ShellProfileBloc {
  _Profiles(super.database) {
    emit(const ShellProfileLoaded([]));
  }
}

class _Hosts extends SshHostBloc {
  _Hosts(
    super.database,
    List<SshHost> hosts,
    SshCredentialRepository credentials,
  ) : super(credentials: credentials) {
    emit(SshHostLoaded(hosts));
  }
}

class _Tabs extends TerminalTabBloc {
  final opened = <PluginTab>[];
  @override
  void add(TerminalTabEvent event) {
    if (event is TerminalTabOpenTab && event.tabItem is PluginTab) {
      final tab = event.tabItem as PluginTab;
      tab.content.value = const SizedBox();
      opened.add(tab);
    }
    super.add(event);
  }
}

class _IdlePlugin with Plugin {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _ConnectedHost extends Fake implements Host {
  @override
  Future<FileSystem> connectFileSystem() async => LocalFileSystem();
  @override
  Future<void> disconnect() async {}
}

class _Fixture {
  final database = AppDatabase.forTesting();
  final vault = _Vault();
  final tabs = _Tabs();
  late final credentials = SshCredentialRepository(database, vault: vault);
  late final keys = SshHostKeyStore(vault: _Vault());
  late final SharedPreferences prefs;
  late final _Settings settings;
  late final _Profiles profiles;
  late final _Hosts hosts;
  late final SshHost host;

  Future<void> init({
    int limit = 10,
    bool restore = false,
    bool key = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    int? keyId;
    if (key) {
      keyId = await credentials.addKey(
        const SshKey(
          id: 0,
          name: 'fixture-key',
          content: 'fixture-private-key',
          password: 'fixture-passphrase',
        ).toCompanion(true),
      );
    }
    await credentials.addHost(
      SshHost(
        id: 0,
        host: 'fixture-host',
        hostname: 'fixture.invalid',
        port: 22,
        username: 'fixture-user',
        password: 'fixture-password',
        identityType: key
            ? SshIdentityType.key.value
            : SshIdentityType.password.value,
        identityKeyId: keyId,
      ).toCompanion(true),
    );
    host = await database.select(database.sshHosts).getSingle();
    settings = _Settings(vault, limit: limit, restore: restore);
    profiles = _Profiles(database);
    hosts = _Hosts(database, [host], credentials);
    tabs.add(TerminalTabStart());
    await Future<void>.delayed(Duration.zero);
    if (!restore) {
      tabs.add(TerminalTabOpenTab(TabItem(content: const SizedBox())));
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppDatabase>.value(value: database),
          RepositoryProvider<SharedPreferences>.value(value: prefs),
          RepositoryProvider<SshCredentialRepository>.value(value: credentials),
          RepositoryProvider<SshHostKeyStore>.value(value: keys),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TerminalTabBloc>.value(value: tabs),
            BlocProvider<TerminalSettingsBloc>.value(value: settings),
            BlocProvider<ShellProfileBloc>.value(value: profiles),
            BlocProvider<SshHostBloc>.value(value: hosts),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            home: const TerminalScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> select(WidgetTester tester) async {
    tester
        .widget<TerminalAppBar>(find.byType(TerminalAppBar))
        .onNewSftpSession();
    await tester.pumpAndSettle();
    expect(find.text('fixture-host'), findsOneWidget);
    await tester.tap(find.text('fixture-host'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    for (final tab in (tabs.state as TerminalTabLoaded).allTabs.toList()) {
      tab.dispose();
    }
    for (final tab in tabs.opened) {
      if (tab.plugin is TerminalPlugin) {
        (tab.plugin as TerminalPlugin).terminal.dispose();
      }
    }
    await tabs.close();
    await settings.close();
    await profiles.close();
    await hosts.close();
    await tester.runAsync(database.close);
  }
}

Future<_Fixture> _fixture(
  WidgetTester tester, {
  int limit = 10,
  bool restore = false,
  bool key = false,
}) async {
  final result = _Fixture();
  await tester.runAsync(
    () => result.init(limit: limit, restore: restore, key: key),
  );
  addTearDown(() => result.close(tester));
  return result;
}

void main() {
  testWidgets('opens configured SFTP host with shared credential provider', (
    tester,
  ) async {
    final f = await _fixture(tester);
    await f.show(tester);
    await f.select(tester);
    expect(f.tabs.opened, hasLength(1));
    final tab = f.tabs.opened.single;
    expect(tab.plugin, isA<FileManagerPlugin>());
    final spec = tab.manager.hostSpec as SSHHostSpec;
    expect(spec.record, f.host);
    expect(
      await tester.runAsync(() async => await spec.passwordProvider!()),
      'fixture-password',
    );
    expect(spec.record.password, isNot('fixture-password'));
  });

  testWidgets('host selection can be cancelled', (tester) async {
    final f = await _fixture(tester);
    await f.show(tester);
    tester
        .widget<TerminalAppBar>(find.byType(TerminalAppBar))
        .onNewSftpSession();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(f.tabs.opened, isEmpty);
  });

  testWidgets('session limit is rechecked after asynchronous host selection', (
    tester,
  ) async {
    final f = await _fixture(tester, limit: 2);
    await f.show(tester);
    tester
        .widget<TerminalAppBar>(find.byType(TerminalAppBar))
        .onNewSftpSession();
    await tester.pumpAndSettle();
    f.tabs.add(TerminalTabOpenTab(TabItem(content: const SizedBox())));
    await tester.pump();
    await tester.tap(find.text('fixture-host'));
    await tester.pumpAndSettle();
    expect(f.tabs.opened, isEmpty);
    expect(find.textContaining('Maximum of 2'), findsOneWidget);
  });

  testWidgets('session limit prevents opening the selector', (tester) async {
    final f = await _fixture(tester, limit: 1);
    await f.show(tester);
    tester
        .widget<TerminalAppBar>(find.byType(TerminalAppBar))
        .onNewSftpSession();
    await tester.pumpAndSettle();
    expect(find.text('Select SSH Host'), findsNothing);
    expect(find.textContaining('Maximum of 1'), findsOneWidget);
    expect(f.tabs.opened, isEmpty);
  });

  testWidgets('session limit is rechecked after private key retrieval', (
    tester,
  ) async {
    final f = await _fixture(tester, limit: 2, key: true);
    final key = await tester.runAsync(
      () => f.database.select(f.database.sshKeys).getSingle(),
    );
    f.vault.delayedKey = key!.content;
    f.vault.readGate = Completer<void>();
    await f.show(tester);
    await f.select(tester);
    expect(f.tabs.opened, isEmpty);
    f.tabs.add(TerminalTabOpenTab(TabItem(content: const SizedBox())));
    await tester.pump();
    f.vault.readGate!.complete();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pumpAndSettle();
    expect(f.tabs.opened, isEmpty);
    expect(find.textContaining('Maximum of 2'), findsOneWidget);
  });

  testWidgets('missing private key displays an error and opens no tab', (
    tester,
  ) async {
    final f = await _fixture(tester, key: true);
    final key = await tester.runAsync(
      () => f.database.select(f.database.sshKeys).getSingle(),
    );
    f.vault.values.remove(key!.content);
    await f.show(tester);
    await f.select(tester);
    expect(f.tabs.opened, isEmpty);
    expect(
      find.textContaining('SSH credential is missing from vault'),
      findsOneWidget,
    );
  });

  for (final sameRecord in [true, false]) {
    testWidgets(
      'connected manager reuse requires full record equality: $sameRecord',
      (tester) async {
        final f = await _fixture(tester);
        final record = sameRecord
            ? f.host
            : SshHost.fromJson({...f.host.toJson(), 'username': 'other-user'});
        final manager = PluginManager(SSHHostSpec(record));
        final sibling = PluginTab(_IdlePlugin(), manager);
        f.tabs.add(TerminalTabOpenTab(sibling));
        manager.didConnected(_ConnectedHost());
        await tester.pump();
        await f.show(tester);
        await f.select(tester);
        final files = f.tabs.opened.last;
        expect(files.plugin, isA<FileManagerPlugin>());
        expect(identical(files.manager, manager), sameRecord);
        expect(sibling.plugin.connected, isTrue);
      },
    );
  }

  testWidgets('key credentials are loaded from the shared repository', (
    tester,
  ) async {
    final f = await _fixture(tester, key: true);
    await f.show(tester);
    await f.select(tester);
    expect(f.tabs.opened, hasLength(1));
    final spec = f.tabs.opened.single.manager.hostSpec as SSHHostSpec;
    expect(spec.keyData!.content, 'fixture-private-key');
    expect(spec.keyData!.passphrase, 'fixture-passphrase');
  });

  testWidgets('first-use rejection and changed key are enforced for SFTP', (
    tester,
  ) async {
    final f = await _fixture(tester);
    await f.show(tester);
    await f.select(tester);
    expect(f.tabs.opened, hasLength(1));
    final spec = f.tabs.opened.single.manager.hostSpec as SSHHostSpec;
    final fingerprint = Uint8List(32);
    final rejected = spec.verifyHostKey!('ssh-ed25519', fingerprint);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await rejected, isFalse);
    await f.keys.verify(
      'fixture.invalid',
      22,
      'ssh-ed25519',
      fingerprint,
      onFirstUse: (_) async => true,
    );
    await expectLater(
      spec.verifyHostKey!(
        'ssh-ed25519',
        Uint8List.fromList(List.filled(32, 1)),
      ),
      throwsA(isA<SshHostKeyMismatchException>()),
    );
  });

  testWidgets('SFTP and SSH descriptors retain their distinct plugin types', (
    tester,
  ) async {
    final f = await _fixture(tester, restore: true);
    await f.prefs.setString(
      'terminal.open_tabs.v1',
      jsonEncode({
        'version': 1,
        'activeIndex': 0,
        'tabs': [
          {'type': 'sftp', 'hostId': f.host.id},
          {'type': 'ssh', 'hostId': f.host.id},
        ],
      }),
    );
    await f.show(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
    expect(f.tabs.opened, hasLength(2));
    expect(f.tabs.opened[0].plugin, isA<FileManagerPlugin>());
    expect(f.tabs.opened[1].plugin, isA<TerminalPlugin>());
    await tester.pump(const Duration(milliseconds: 350));
    final saved =
        jsonDecode(f.prefs.getString('terminal.open_tabs.v1')!) as Map;
    expect(saved['tabs'], [
      {'type': 'sftp', 'hostId': f.host.id},
      {'type': 'ssh', 'hostId': f.host.id},
    ]);
    expect(jsonEncode(saved), isNot(contains('fixture-password')));
    expect(jsonEncode(saved), isNot(contains('vault:ssh:')));
  });

  testWidgets('restored SSH tab starts in its saved remote directory', (
    tester,
  ) async {
    final f = await _fixture(tester, restore: true);
    await tester.runAsync(
      () => f.prefs.setString(
        'terminal.open_tabs.v1',
        jsonEncode({
          'activeIndex': 0,
          'tabs': [
            {
              'type': 'ssh',
              'hostId': f.host.id,
              'workingDirectory': '/srv/app',
            },
          ],
        }),
      ),
    );

    await f.show(tester);
    for (var i = 0; i < 5 && f.tabs.opened.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    final tab = f.tabs.opened.single;
    expect(tab.manager.hostSpec, isA<SSHHostSpec>());
    expect((tab.plugin as TerminalPlugin).startDirectory, '/srv/app');
  });
}
