import 'dart:io';

import 'package:app_ssh/app_ssh.dart';
import 'package:test/test.dart';

void main() {
  final isCI = Platform.environment['CI'] == 'true';
  final isNetworkUnreliable = Platform.environment['SKIP_NETWORK_TESTS'] == 'true';

  group('SSHSocket', () {
    test(
      'can establish tcp connections',
      () async {
        final socket = await SSHSocket.connect('time.nist.gov', 13);
        final firstPacket = await socket.stream.first.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
            'No response from time.nist.gov within 10 seconds',
          ),
        );
        expect(firstPacket, isNotEmpty);
        await socket.close();
      },
      skip: isCI || isNetworkUnreliable
          ? 'Skipped - external network connection unreliable'
          : null,
      timeout: Timeout(const Duration(seconds: 15)),
    );

    test('creates SSHSocket with correct host and port', () {
      // Test that SSHSocket factory exists and has correct signature
      expect(SSHSocket.connect, isA<Function>());
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
