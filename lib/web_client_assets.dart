import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

Future<Directory> materializeWebClientAssets(
  Directory supportDirectory, {
  AssetBundle? bundle,
}) async {
  const files = ['index.html', 'app.js', 'app.css', 'styles.css'];
  final assets = bundle ?? rootBundle;
  final contents = <String, ByteData>{};
  for (final file in files) {
    contents[file] = await assets.load('web/terminal-client/dist/$file');
  }

  final directory = Directory(
    path.join(supportDirectory.path, 'web-terminal-client'),
  );
  await directory.create(recursive: true);
  for (final entry in contents.entries) {
    final file = File(path.join(directory.path, entry.key));
    final temporary = File('${file.path}.tmp');
    final data = entry.value;
    await temporary.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    await temporary.rename(file.path);
  }
  return directory;
}
