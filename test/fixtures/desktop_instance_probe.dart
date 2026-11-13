import 'dart:convert';
import 'dart:io';

import '../../lib/services/desktop_instance.dart';

Future<void> main(List<String> args) async {
  final instance = await DesktopInstance.acquire(
    Directory(args.single),
    onActivate: () async {
      stdout.writeln('activated');
    },
  );
  if (instance == null) {
    stdout.writeln('secondary');
    return;
  }
  stdout.writeln('owner');
  await stdin.transform(utf8.decoder).transform(const LineSplitter()).first;
  await instance.close();
}
