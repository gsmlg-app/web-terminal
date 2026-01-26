import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('ServerConfig', () {
    test('creates with required parameters', () {
      final config = ServerConfig(staticFilesPath: '/tmp/static');

      expect(config.staticFilesPath, '/tmp/static');
      expect(config.port, 8080);
      expect(config.bindAddress, isNull);
      expect(config.allowedOrigins, ['*']);
      expect(config.sessionTimeout, const Duration(hours: 24));
      expect(config.maxSessionsPerToken, 5);
      expect(config.maxPtySessions, 10);
      expect(config.debugMode, false);
      expect(config.useSsl, false);
    });

    test('creates with all parameters', () {
      final config = ServerConfig(
        port: 9000,
        bindAddress: '127.0.0.1',
        allowedOrigins: ['http://localhost:3000'],
        staticFilesPath: '/var/www',
        sessionTimeout: const Duration(hours: 1),
        maxSessionsPerToken: 10,
        maxPtySessions: 20,
        debugMode: true,
        useSsl: true,
      );

      expect(config.port, 9000);
      expect(config.bindAddress, '127.0.0.1');
      expect(config.allowedOrigins, ['http://localhost:3000']);
      expect(config.staticFilesPath, '/var/www');
      expect(config.sessionTimeout, const Duration(hours: 1));
      expect(config.maxSessionsPerToken, 10);
      expect(config.maxPtySessions, 20);
      expect(config.debugMode, true);
      expect(config.useSsl, true);
    });

    test('copyWith creates copy with updated values', () {
      final original = ServerConfig(staticFilesPath: '/tmp/static');
      final copy = original.copyWith(
        port: 9000,
        debugMode: true,
      );

      expect(copy.port, 9000);
      expect(copy.debugMode, true);
      // Unchanged values
      expect(copy.staticFilesPath, '/tmp/static');
      expect(copy.bindAddress, isNull);
      expect(copy.maxPtySessions, 10);
    });

    test('copyWith with no parameters returns equivalent config', () {
      final original = ServerConfig(
        port: 8000,
        bindAddress: '0.0.0.0',
        staticFilesPath: '/app/static',
      );
      final copy = original.copyWith();

      expect(copy.port, original.port);
      expect(copy.bindAddress, original.bindAddress);
      expect(copy.staticFilesPath, original.staticFilesPath);
      expect(copy.debugMode, original.debugMode);
    });
  });
}
