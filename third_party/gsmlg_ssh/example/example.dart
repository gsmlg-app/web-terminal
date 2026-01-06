import 'dart:convert';
import 'dart:io';

import 'package:gsmlg_ssh/gsmlg_ssh.dart';

void main(List<String> args) async {
  final socket = await SSHSocket.connect('localhost', 22);

  final client = SSHClient(
    socket,
    username: 'root',
    onPasswordRequest: () {
      stdout.write('Password: ');
      stdin.echoMode = false;
      return stdin.readLineSync() ?? exit(1);
    },
  );

  final uptime = await client.run('uptime');
  print(utf8.decode(uptime));

  client.close();
  await client.done;
}
