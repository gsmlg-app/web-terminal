import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('ServerConfig', () {
    group('defaults', () {
      test('port defaults to 8080', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.port, 8080);
      });

      test('bindAddress defaults to null (all interfaces)', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.bindAddress, isNull);
      });

      test('allowedOrigins defaults to all (*)', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.allowedOrigins, ['*']);
      });

      test('sessionTimeout defaults to 24 hours', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.sessionTimeout, const Duration(hours: 24));
      });

      test('maxSessionsPerToken defaults to 5', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.maxSessionsPerToken, 5);
      });

      test('maxPtySessions defaults to 10', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.maxPtySessions, 10);
      });

      test('debugMode defaults to false', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.debugMode, false);
      });

      test('useSsl defaults to false', () {
        const config = ServerConfig(staticFilesPath: '/web');
        expect(config.useSsl, false);
      });
    });

    group('custom values', () {
      test('accepts custom port', () {
        const config = ServerConfig(port: 3000, staticFilesPath: '/web');
        expect(config.port, 3000);
      });

      test('accepts custom bind address', () {
        const config = ServerConfig(
          bindAddress: '127.0.0.1',
          staticFilesPath: '/web',
        );
        expect(config.bindAddress, '127.0.0.1');
      });

      test('accepts custom allowed origins', () {
        const config = ServerConfig(
          allowedOrigins: ['https://example.com', 'https://app.example.com'],
          staticFilesPath: '/web',
        );
        expect(config.allowedOrigins.length, 2);
        expect(config.allowedOrigins.first, 'https://example.com');
      });

      test('accepts custom session timeout', () {
        const config = ServerConfig(
          sessionTimeout: Duration(minutes: 30),
          staticFilesPath: '/web',
        );
        expect(config.sessionTimeout.inMinutes, 30);
      });

      test('accepts debug mode', () {
        const config = ServerConfig(debugMode: true, staticFilesPath: '/web');
        expect(config.debugMode, true);
      });

      test('accepts ssl mode', () {
        const config = ServerConfig(useSsl: true, staticFilesPath: '/web');
        expect(config.useSsl, true);
      });
    });

    group('copyWith', () {
      test('copies with new port', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(port: 9000);

        expect(copied.port, 9000);
        expect(copied.staticFilesPath, '/web');
      });

      test('copies with new bindAddress', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(bindAddress: '192.168.1.1');

        expect(copied.bindAddress, '192.168.1.1');
      });

      test('copies with new allowedOrigins', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(
          allowedOrigins: ['https://secure.com'],
        );

        expect(copied.allowedOrigins, ['https://secure.com']);
      });

      test('copies with new staticFilesPath', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(staticFilesPath: '/new/path');

        expect(copied.staticFilesPath, '/new/path');
      });

      test('copies with new sessionTimeout', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(
          sessionTimeout: const Duration(hours: 8),
        );

        expect(copied.sessionTimeout.inHours, 8);
      });

      test('copies with new maxSessionsPerToken', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(maxSessionsPerToken: 10);

        expect(copied.maxSessionsPerToken, 10);
      });

      test('copies with new maxPtySessions', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(maxPtySessions: 20);

        expect(copied.maxPtySessions, 20);
      });

      test('copies with new debugMode', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(debugMode: true);

        expect(copied.debugMode, true);
      });

      test('copies with new useSsl', () {
        const original = ServerConfig(staticFilesPath: '/web');
        final copied = original.copyWith(useSsl: true);

        expect(copied.useSsl, true);
      });

      test('preserves unchanged values', () {
        const original = ServerConfig(
          port: 443,
          bindAddress: '0.0.0.0',
          allowedOrigins: ['https://app.com'],
          staticFilesPath: '/static',
          sessionTimeout: Duration(hours: 1),
          maxSessionsPerToken: 3,
          maxPtySessions: 5,
          debugMode: true,
          useSsl: true,
        );
        final copied = original.copyWith(port: 8443);

        expect(copied.port, 8443);
        expect(copied.bindAddress, '0.0.0.0');
        expect(copied.allowedOrigins, ['https://app.com']);
        expect(copied.staticFilesPath, '/static');
        expect(copied.sessionTimeout.inHours, 1);
        expect(copied.maxSessionsPerToken, 3);
        expect(copied.maxPtySessions, 5);
        expect(copied.debugMode, true);
        expect(copied.useSsl, true);
      });
    });

    group('typical configurations', () {
      test('development configuration', () {
        const devConfig = ServerConfig(
          port: 8080,
          bindAddress: '127.0.0.1',
          allowedOrigins: ['*'],
          staticFilesPath: './build/web',
          debugMode: true,
        );

        expect(devConfig.debugMode, true);
        expect(devConfig.useSsl, false);
        expect(devConfig.bindAddress, '127.0.0.1');
      });

      test('production configuration', () {
        const prodConfig = ServerConfig(
          port: 443,
          bindAddress: '0.0.0.0',
          allowedOrigins: ['https://terminal.example.com'],
          staticFilesPath: '/var/www/terminal',
          sessionTimeout: Duration(hours: 8),
          maxSessionsPerToken: 3,
          maxPtySessions: 5,
          debugMode: false,
          useSsl: true,
        );

        expect(prodConfig.debugMode, false);
        expect(prodConfig.useSsl, true);
        expect(prodConfig.maxSessionsPerToken, 3);
      });
    });
  });
}
