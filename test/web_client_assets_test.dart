import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_terminal/web_client_assets.dart';

class _Bundle extends CachingAssetBundle {
  final assets = <String, Uint8List>{
    for (final file in ['index.html', 'app.js', 'app.css', 'styles.css'])
      'web/terminal-client/dist/$file': Uint8List.fromList(
        'new $file'.codeUnits,
      ),
  };

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw StateError('Missing $key');
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory supportDirectory;

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp('web-assets-test');
  });

  tearDown(() async {
    await supportDirectory.delete(recursive: true);
  });

  test('materializes the complete client on a fresh install', () async {
    final directory = await materializeWebClientAssets(
      supportDirectory,
      bundle: _Bundle(),
    );

    for (final file in ['index.html', 'app.js', 'app.css', 'styles.css']) {
      expect(await File('${directory.path}/$file').readAsString(), 'new $file');
    }
  });

  test('refreshes existing assets after an application upgrade', () async {
    final directory = Directory('${supportDirectory.path}/web-terminal-client');
    await directory.create();
    await File('${directory.path}/app.js').writeAsString('old client');

    await materializeWebClientAssets(supportDirectory, bundle: _Bundle());

    expect(await File('${directory.path}/app.js').readAsString(), 'new app.js');
  });

  test(
    'missing bundled asset fails before altering the installed client',
    () async {
      final directory = Directory(
        '${supportDirectory.path}/web-terminal-client',
      );
      await directory.create();
      await File('${directory.path}/index.html')
          .writeAsString('existing client');
      final bundle = _Bundle()
        ..assets.remove('web/terminal-client/dist/app.js');

      await expectLater(
        materializeWebClientAssets(supportDirectory, bundle: bundle),
        throwsStateError,
      );
      expect(
        await File('${directory.path}/index.html').readAsString(),
        'existing client',
      );
    },
  );

  test(
    'Flutter bundle contains all assets needed by the Release server',
    () async {
      for (final file in ['index.html', 'app.js', 'app.css', 'styles.css']) {
        expect(
          (await rootBundle.load('web/terminal-client/dist/$file'))
              .lengthInBytes,
          greaterThan(0),
        );
      }
    },
  );
}
