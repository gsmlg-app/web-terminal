import 'dart:io';

import 'package:android_shell/android_shell.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.gsmlg/android_shell');
  late Directory directory;

  setUp(() async {
    AndroidShellEnv.reset();
    directory = await Directory.systemTemp.createTemp('android_proot_launch_');
    final nativeDir = Directory('${directory.path}/native')..createSync();
    File('${nativeDir.path}/libproot.so').writeAsStringSync('fixture');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => <String, String>{
            'filesDir': directory.path,
            'rootfsPath': '${directory.path}/rootfs',
            'nativeLibDir': nativeDir.path,
            'prootPath': '${nativeDir.path}/libproot.so',
            'loaderPath': '${nativeDir.path}/libloader.so',
            'loader32Path': '${nativeDir.path}/libloader32.so',
            'tmpPath': '${directory.path}/tmp',
            'homePath': '${directory.path}/rootfs/root',
            'arch': 'arm64-v8a',
          },
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    AndroidShellEnv.reset();
    await directory.delete(recursive: true);
  });

  test('PRoot can resolve its packaged native dependencies', () async {
    final environment = AndroidShellEnv.instance;
    await environment.initialize();

    expect(environment.usesSystemShell, isFalse);
    expect(
      environment.getEnvironment()['LD_LIBRARY_PATH'],
      environment.nativeLibDir,
    );
    expect(
      environment.getEnvironment()['PROOT_LOADER'],
      environment.loaderPath,
    );
    final (command, arguments) = environment.getShellCommand();
    expect(command, '${directory.path}/native/libproot.so');
    expect(arguments, containsAllInOrder(['-r', environment.rootfsPath]));
    expect(arguments.sublist(arguments.length - 2), ['/bin/sh', '-l']);
  });

  test(
    'missing PRoot uses Android system paths in fallback environment',
    () async {
      File('${directory.path}/native/libproot.so').deleteSync();
      final environment = AndroidShellEnv.instance;
      await environment.initialize();

      expect(environment.usesSystemShell, isTrue);
      final (command, arguments) = environment.getShellCommand();
      expect(command, '/system/bin/sh');
      expect(arguments, ['-i']);
      expect(environment.getEnvironment()['PATH'], contains('/system/bin'));
      expect(environment.getEnvironment()['HOME'], environment.homePath);
      expect(environment.getEnvironment()['TMPDIR'], environment.tmpPath);
    },
  );
}
