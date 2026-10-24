import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isIOS) return;

  late Directory fixture;
  late String home;
  late IosHost host;

  Future<Map<String, dynamic>> execute(String command) async {
    final result = await host
        .execute(command)
        .timeout(const Duration(seconds: 30));
    return {
      'exitCode': result.exitCode,
      'stdout': result.stdout,
      'stderr': result.stderr,
    };
  }

  Future<String> succeeds(String command) async {
    final result = await execute(command);
    expect(result['exitCode'], 0, reason: '$command: ${result['stderr']}');
    return result['stdout'] as String;
  }

  setUpAll(() async {
    host = await IosConnector().createHost();
    home = (await succeeds('printenv HOME')).trim();
  });

  setUp(() async {
    fixture = await Directory(home).createTemp('.shell_commands_');
    await succeeds("cd '${fixture.path}'");
    await File('${fixture.path}/sample.txt')
        .writeAsString('alpha\nbeta\nALPHA\n');
  });

  tearDown(() async {
    await succeeds("cd '$home'");
    await fixture.delete(recursive: true);
  });

  testWidgets(
    'the native catalog exposes executable utility and runtime commands',
    (tester) async {
      final session = await host.shell();
      final output = StringBuffer();
      final ready = Completer<void>();
      final completed = Completer<void>();
      final subscription = session.output.listen((data) {
        final text = utf8.decode(data);
        output.write(text);
        if (!text.endsWith(' \$ ')) return;
        if (!ready.isCompleted) {
          ready.complete();
        } else if (!completed.isCompleted) {
          completed.complete();
        }
      });
      addTearDown(() async {
        await session.close();
        await subscription.cancel();
      });
      await ready.future;
      await session.write(Uint8List.fromList(utf8.encode('help\r')));
      await completed.future;
      final commands = output.toString().split('\r\n')[1].split(RegExp(r'\s+'));
      expect(
        commands,
        containsAll([
          'base64',
          'cksum',
          'compress',
          'curl',
          'dig',
          'egrep',
          'fgrep',
          'host',
          'lg2',
          'lua',
          'md5',
          'nc',
          'nslookup',
          'ping',
          'python',
          'python3',
          'readlink',
          'sum',
          'uncompress',
          'unlink',
          'uptime',
          'whoami',
          'whois',
        ]),
      );
      expect(commands.toSet(), hasLength(commands.length));
      expect(commands, containsAll(['cd', 'clear', 'exit', 'help', 'logout']));
    },
  );

  testWidgets('text utilities read files and pipe their output', (
    tester,
  ) async {
    expect(await succeeds('cat sample.txt'), 'alpha\nbeta\nALPHA\n');
    expect((await succeeds("egrep -c 'alpha|beta' sample.txt")).trim(), '2');
    expect((await succeeds('fgrep -c ALPHA sample.txt')).trim(), '1');
    expect((await succeeds('cat sample.txt | wc -l')).trim(), '3');
    expect(await succeeds('cat sample.txt > redirected.txt'), isEmpty);
    expect(
      await File('${fixture.path}/redirected.txt').readAsString(),
      'alpha\nbeta\nALPHA\n',
    );
    final pipeline = await execute('cat missing.txt | wc -l');
    expect(pipeline['stderr'], contains('missing.txt'));
    expect((await succeeds('whoami')).trim(), isNotEmpty);
    expect(await succeeds('uptime'), isNotEmpty);
    expect(await succeeds('true'), isEmpty);
    expect(await succeeds('type cat'), contains('cat'));
  });

  testWidgets('ls -a lists each directory entry once on repeated calls', (
    tester,
  ) async {
    await File('${fixture.path}/.hidden').writeAsString('hidden');
    await Directory('${fixture.path}/folder').create();
    for (var index = 0; index < 3; index++) {
      final result = await execute('ls -a');
      expect(result['exitCode'], 0);
      expect(result['stderr'], isEmpty);
      final entries = (result['stdout'] as String)
          .replaceAll(RegExp(r'\x1b\[[0-9;]*m'), '')
          .trim()
          .split(RegExp(r'\s+'));
      expect(
        entries,
        unorderedEquals(['.', '..', '.hidden', 'folder', 'sample.txt']),
        reason: 'invocation $index: ${result['stdout']}',
      );
    }
  });

  testWidgets('overlapping Enter events display ls -a output once', (
    tester,
  ) async {
    await File('${fixture.path}/.hidden').writeAsString('hidden');
    final session = await host.shell();
    final output = StringBuffer();
    final ready = Completer<void>();
    final subscription = session.output.listen((data) {
      final text = utf8.decode(data);
      output.write(text);
      if (text.endsWith(' \$ ') && !ready.isCompleted) ready.complete();
    });
    addTearDown(() async {
      await session.close();
      await subscription.cancel();
    });
    await ready.future;
    output.clear();
    await session.write(Uint8List.fromList(utf8.encode('ls -a')));
    final first = session.write(Uint8List.fromList([13]));
    final second = session.write(Uint8List.fromList([13]));
    await Future.wait([first, second]);
    await Future<void>.delayed(Duration.zero);

    expect('sample.txt'.allMatches(output.toString()), hasLength(1));
    expect('.hidden'.allMatches(output.toString()), hasLength(1));
  });

  testWidgets(
    'encoding, checksums and file aliases perform real file operations',
    (tester) async {
      final encoded = await succeeds('base64 -e < sample.txt');
      expect(
        encoded.trim(),
        base64.encode(utf8.encode('alpha\nbeta\nALPHA\n')),
      );
      await File('${fixture.path}/encoded.txt').writeAsString(encoded);
      expect(await succeeds('base64 -d < encoded.txt'), 'alpha\nbeta\nALPHA\n');
      expect(
        (await succeeds('md5 -q sample.txt')).trim(),
        'f7c083191c4d07a569e2a594242e574e',
      );
      expect(
        (await succeeds('md5 -q < sample.txt')).trim(),
        'f7c083191c4d07a569e2a594242e574e',
      );
      expect(
        (await succeeds('md5 -q -s hello')).trim(),
        '5d41402abc4b2a76b9719d911017c592',
      );
      final missingDigest = await execute('md5 missing.txt');
      expect(missingDigest['exitCode'], 1);
      expect(missingDigest['stderr'], contains('missing.txt'));
      expect(await succeeds('cksum sample.txt'), contains('17 sample.txt'));
      expect(await succeeds('sum sample.txt'), contains('sample.txt'));

      await succeeds('link sample.txt linked.txt');
      expect(
        await File('${fixture.path}/linked.txt').readAsString(),
        'alpha\nbeta\nALPHA\n',
      );
      await succeeds('unlink linked.txt');
      expect(await File('${fixture.path}/linked.txt').exists(), isFalse);
      await Link('${fixture.path}/shortcut').create('sample.txt');
      expect((await succeeds('readlink shortcut')).trim(), 'sample.txt');

      await File('${fixture.path}/archive.txt')
          .writeAsString('compress me\n' * 100);
      await succeeds('compress archive.txt');
      expect(await File('${fixture.path}/archive.txt.Z').exists(), isTrue);
      await succeeds('uncompress archive.txt.Z');
      expect(
        await File('${fixture.path}/archive.txt').readAsString(),
        'compress me\n' * 100,
      );
    },
  );

  testWidgets('Lua evaluates code and scripts with arguments', (tester) async {
    expect((await succeeds("lua -e 'print(6 * 7)'")).trim(), '42');
    await File('${fixture.path}/script.lua').writeAsString('print(arg[1])\n');
    expect((await succeeds('lua script.lua hello')).trim(), 'hello');
  });

  testWidgets('Python runs code, modules, local imports and script arguments', (
    tester,
  ) async {
    expect(await succeeds('python3 --version'), startsWith('Python 3.14.'));
    expect((await succeeds("python -c 'print(6 * 7)'")).trim(), '42');
    await File('${fixture.path}/helper.py').writeAsString('answer = 42\n');
    await File(
      '${fixture.path}/script.py',
    ).writeAsString('import helper, sys\nprint(helper.answer, sys.argv[1])\n');
    expect((await succeeds('python3 script.py hello')).trim(), '42 hello');
    await File('${fixture.path}/data.json').writeAsString('{"value":42}');
    expect(
      await succeeds('python3 -m json.tool < data.json'),
      contains('"value": 42'),
    );
  });

  testWidgets('Python captures Unicode, binary output and stderr separately', (
    tester,
  ) async {
    final result = await execute(
      'python3 -c \'import sys; print("你好"); sys.stdout.buffer.write(b"bytes\\n"); print("error", file=sys.stderr)\'',
    );
    expect(result['exitCode'], 0);
    expect(result['stdout'], contains('你好\n'));
    expect(result['stdout'], contains('bytes\n'));
    expect(result['stderr'], 'error\n');
    expect(result['stdout'], isNot(contains('error')));
  });

  testWidgets('Python loads bundled native standard library extensions', (
    tester,
  ) async {
    await File('${fixture.path}/stdlib.py').writeAsString('''
import hashlib, lzma, socket, sqlite3, ssl, zlib
assert hashlib.sha256(b'hello').hexdigest() == '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824'
assert lzma.decompress(lzma.compress(b'hello')) == b'hello'
assert zlib.decompress(zlib.compress(b'hello')) == b'hello'
with sqlite3.connect(':memory:') as database:
    assert database.execute('select 6 * 7').fetchone()[0] == 42
context = ssl.create_default_context()
assert context.cert_store_stats()['x509_ca'] > 0
assert socket.inet_aton('127.0.0.1') == b'\\x7f\\x00\\x00\\x01'
print('native extensions ready')
''');
    expect(
      (await succeeds('python3 stdlib.py')).trim(),
      'native extensions ready',
    );
  });

  testWidgets('Python exceptions and SystemExit leave the host alive', (
    tester,
  ) async {
    for (final entry in <String, int>{
      'import sys; sys.exit()': 0,
      'import sys; sys.exit(7)': 7,
      'import sys; sys.exit("message")': 1,
      'raise RuntimeError("expected error")': 1,
      'if syntax error': 1,
    }.entries) {
      final result = await execute("python3 -c '${entry.key}'");
      expect(result['exitCode'], entry.value, reason: entry.key);
      expect((await succeeds("python3 -c 'print(42)'")).trim(), '42');
    }
    final bare = await execute('python3');
    expect(bare['exitCode'], isNot(0));
    final input = await execute("python3 -c 'input()'");
    expect(input['exitCode'], 1);
    expect(input['stderr'], contains('EOFError'));
  });

  testWidgets('repeated Python invocations reset command state and streams', (
    tester,
  ) async {
    await File('${fixture.path}/count_fds.py').writeAsString('''
import fcntl
count = 0
for descriptor in range(512):
    try:
        fcntl.fcntl(descriptor, fcntl.F_GETFD)
    except OSError:
        continue
    count += 1
print(count)
''');
    final descriptorsBefore = int.parse(
      (await succeeds('python3 count_fds.py')).trim(),
    );
    for (var index = 0; index < 100; index++) {
      final source = index.isEven
          ? 'import sys; print(sys.argv[0]); secret = 42'
          : 'assert "secret" not in globals(); raise ValueError("expected")';
      final result = await execute("python3 -c '$source' < sample.txt");
      expect(
        result['exitCode'],
        index.isEven ? 0 : 1,
        reason: 'iteration $index',
      );
      expect(
        result['stdout'],
        index.isEven ? '-c\n' : '',
        reason: 'iteration $index',
      );
      if (index.isEven) expect(result['stderr'], isEmpty);
    }
    final descriptorsAfter = int.parse(
      (await succeeds('python3 count_fds.py')).trim(),
    );
    expect(descriptorsAfter, descriptorsBefore);
    final results = await Future.wait([
      execute("python3 -c 'print(11)'"),
      execute("python3 -c 'print(22)'"),
    ]);
    expect(results.map((result) => result['stdout']), ['11\n', '22\n']);
  });

  testWidgets(
    'network tools report versions and perform bounded network calls',
    (tester) async {
      expect(await succeeds('curl --version'), startsWith('curl '));
      expect(
        await succeeds(
          'curl --fail --silent --show-error --max-time 15 https://example.com',
        ),
        contains('Example Domain'),
      );
      expect(
        await succeeds('dig +time=2 +tries=1 example.com'),
        contains('ANSWER SECTION'),
      );
      expect(await succeeds('host -W 3 example.com'), contains('has address'));
      expect(
        await succeeds('nslookup -timeout=3 -retry=1 example.com'),
        contains('Address'),
      );
      expect(
        await succeeds('ping -c 1 127.0.0.1'),
        contains('1 packets received'),
      );
      final nc = await execute('nc -h');
      expect('${nc['stdout']}${nc['stderr']}', contains('usage'));
    },
  );

  testWidgets('lg2 initializes and inspects a local Git repository', (
    tester,
  ) async {
    await succeeds('lg2 init .');
    expect(await Directory('${fixture.path}/.git').exists(), isTrue);
    expect(await succeeds('lg2 status'), contains('sample.txt'));
    await succeeds('lg2 add sample.txt');
    expect(await succeeds('lg2 status'), contains('sample.txt'));
  });

  testWidgets(
    'a blocking native command allows the Flutter thread to respond',
    (tester) async {
      final command = execute('sleep 2');
      final watch = Stopwatch()..start();
      await tester.pump();
      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
      expect((await command)['exitCode'], 0);
    },
  );

  tearDownAll(() async {
    await host.disconnect();
  });
}
