import 'dart:convert';
import 'dart:io';

import '../../lib/services/session_store.dart';

Future<void> main(List<String> args) async {
  final store = await SessionStore.open(Directory(args.first));
  if (args.last == 'write') {
    await store.record({
      'tabs': [
        {'type': 'local', 'workingDirectory': '/crash-recovered'},
      ],
    });
    stdout.writeln('flushed');
    await stdin.first;
  } else {
    stdout.writeln(jsonEncode(store.recovery?.layout));
    await store.close();
  }
}
