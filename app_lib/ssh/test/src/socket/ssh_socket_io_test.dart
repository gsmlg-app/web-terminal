import 'dart:io';

import 'package:app_ssh/app_ssh.dart';
import 'package:test/test.dart';

void main() {
  final isCI = Platform.environment['CI'] == 'true';

  group('SSHSocket', () {
    test(
      'can establish tcp connections',
      () async {
        final socket = await SSHSocket.connect('time.nist.gov', 13);
        final firstPacket = await socket.stream.first;
        expect(firstPacket, isNotEmpty);
        await socket.close();
      },
      skip: isCI
          ? 'Skipped in CI - external network connection unreliable'
          : null,
    );
  });
}
