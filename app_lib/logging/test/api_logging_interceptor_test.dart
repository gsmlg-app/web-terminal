import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('ApiLoggingInterceptor', () {
    late ApiLoggingInterceptor interceptor;

    setUp(() {
      interceptor = ApiLoggingInterceptor();
    });

    group('logRequest', () {
      test('logs basic request with method and url', () {
        // Should not throw
        expect(
          () => interceptor.logRequest(
            method: 'GET',
            url: 'https://api.example.com/users',
          ),
          returnsNormally,
        );
      });

      test('logs request with headers', () {
        expect(
          () => interceptor.logRequest(
            method: 'POST',
            url: 'https://api.example.com/users',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer token',
            },
          ),
          returnsNormally,
        );
      });

      test('logs request with body', () {
        expect(
          () => interceptor.logRequest(
            method: 'POST',
            url: 'https://api.example.com/users',
            body: {
              'name': 'John Doe',
              'email': 'john@example.com',
            },
          ),
          returnsNormally,
        );
      });

      test('logs request with tag', () {
        expect(
          () => interceptor.logRequest(
            method: 'GET',
            url: 'https://api.example.com/users',
            tag: 'UserAPI',
          ),
          returnsNormally,
        );
      });

      test('logs request with all parameters', () {
        expect(
          () => interceptor.logRequest(
            method: 'PUT',
            url: 'https://api.example.com/users/123',
            headers: {'Content-Type': 'application/json'},
            body: {'name': 'Jane Doe'},
            tag: 'UpdateUser',
          ),
          returnsNormally,
        );
      });

      test('handles empty headers', () {
        expect(
          () => interceptor.logRequest(
            method: 'GET',
            url: 'https://api.example.com/data',
            headers: {},
          ),
          returnsNormally,
        );
      });

      test('handles different HTTP methods', () {
        final methods = [
          'GET',
          'POST',
          'PUT',
          'PATCH',
          'DELETE',
          'HEAD',
          'OPTIONS'
        ];
        for (final method in methods) {
          expect(
            () => interceptor.logRequest(
              method: method,
              url: 'https://api.example.com/resource',
            ),
            returnsNormally,
            reason: 'Should handle $method method',
          );
        }
      });
    });

    group('logResponse', () {
      test('logs basic response with status code', () {
        expect(
          () => interceptor.logResponse(
            method: 'GET',
            url: 'https://api.example.com/users',
            statusCode: 200,
          ),
          returnsNormally,
        );
      });

      test('logs response with headers', () {
        expect(
          () => interceptor.logResponse(
            method: 'GET',
            url: 'https://api.example.com/users',
            statusCode: 200,
            headers: {'Content-Type': 'application/json'},
          ),
          returnsNormally,
        );
      });

      test('logs response with body', () {
        expect(
          () => interceptor.logResponse(
            method: 'GET',
            url: 'https://api.example.com/users',
            statusCode: 200,
            body: {'users': []},
          ),
          returnsNormally,
        );
      });

      test('logs response with response time', () {
        expect(
          () => interceptor.logResponse(
            method: 'GET',
            url: 'https://api.example.com/users',
            statusCode: 200,
            responseTimeMs: 150,
          ),
          returnsNormally,
        );
      });

      test('logs response with tag', () {
        expect(
          () => interceptor.logResponse(
            method: 'GET',
            url: 'https://api.example.com/users',
            statusCode: 200,
            tag: 'UserAPI',
          ),
          returnsNormally,
        );
      });

      test('handles 2xx success status codes', () {
        for (final statusCode in [200, 201, 202, 204]) {
          expect(
            () => interceptor.logResponse(
              method: 'GET',
              url: 'https://api.example.com/resource',
              statusCode: statusCode,
            ),
            returnsNormally,
            reason: 'Should handle status code $statusCode',
          );
        }
      });

      test('handles 3xx redirect status codes', () {
        for (final statusCode in [301, 302, 304]) {
          expect(
            () => interceptor.logResponse(
              method: 'GET',
              url: 'https://api.example.com/resource',
              statusCode: statusCode,
            ),
            returnsNormally,
            reason: 'Should handle status code $statusCode',
          );
        }
      });

      test('handles 4xx client error status codes', () {
        for (final statusCode in [400, 401, 403, 404, 422, 429]) {
          expect(
            () => interceptor.logResponse(
              method: 'GET',
              url: 'https://api.example.com/resource',
              statusCode: statusCode,
            ),
            returnsNormally,
            reason: 'Should handle status code $statusCode',
          );
        }
      });

      test('handles 5xx server error status codes', () {
        for (final statusCode in [500, 502, 503, 504]) {
          expect(
            () => interceptor.logResponse(
              method: 'GET',
              url: 'https://api.example.com/resource',
              statusCode: statusCode,
            ),
            returnsNormally,
            reason: 'Should handle status code $statusCode',
          );
        }
      });
    });

    group('logError', () {
      test('logs error with string error', () {
        expect(
          () => interceptor.logError(
            method: 'GET',
            url: 'https://api.example.com/users',
            error: 'Connection timeout',
          ),
          returnsNormally,
        );
      });

      test('logs error with Exception', () {
        expect(
          () => interceptor.logError(
            method: 'POST',
            url: 'https://api.example.com/users',
            error: Exception('Network error'),
          ),
          returnsNormally,
        );
      });

      test('logs error with stack trace', () {
        expect(
          () => interceptor.logError(
            method: 'GET',
            url: 'https://api.example.com/users',
            error: 'Error occurred',
            stackTrace: StackTrace.current,
          ),
          returnsNormally,
        );
      });

      test('logs error with request body', () {
        expect(
          () => interceptor.logError(
            method: 'POST',
            url: 'https://api.example.com/users',
            error: 'Server error',
            requestBody: {'name': 'Test'},
          ),
          returnsNormally,
        );
      });

      test('logs error with tag', () {
        expect(
          () => interceptor.logError(
            method: 'GET',
            url: 'https://api.example.com/users',
            error: 'Error',
            tag: 'UserAPI',
          ),
          returnsNormally,
        );
      });

      test('logs error with all parameters', () {
        expect(
          () => interceptor.logError(
            method: 'PUT',
            url: 'https://api.example.com/users/123',
            error: Exception('Update failed'),
            stackTrace: StackTrace.current,
            requestBody: {'name': 'Updated'},
            tag: 'UpdateUser',
          ),
          returnsNormally,
        );
      });
    });

    group('logPerformance', () {
      test('logs normal performance (under 1s)', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/users',
            durationMs: 150,
          ),
          returnsNormally,
        );
      });

      test('logs slow performance (1-5s)', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/users',
            durationMs: 2000,
          ),
          returnsNormally,
        );
      });

      test('logs very slow performance (over 5s)', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/users',
            durationMs: 7000,
          ),
          returnsNormally,
        );
      });

      test('handles zero duration', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/fast',
            durationMs: 0,
          ),
          returnsNormally,
        );
      });

      test('handles edge case at 1000ms', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/resource',
            durationMs: 1000,
          ),
          returnsNormally,
        );
      });

      test('handles edge case at 5000ms', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/resource',
            durationMs: 5000,
          ),
          returnsNormally,
        );
      });

      test('handles edge case just over 1000ms', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/resource',
            durationMs: 1001,
          ),
          returnsNormally,
        );
      });

      test('handles edge case just over 5000ms', () {
        expect(
          () => interceptor.logPerformance(
            method: 'GET',
            url: 'https://api.example.com/resource',
            durationMs: 5001,
          ),
          returnsNormally,
        );
      });
    });

    group('logConnectivity', () {
      test('logs connected state', () {
        expect(
          () => interceptor.logConnectivity(isConnected: true),
          returnsNormally,
        );
      });

      test('logs disconnected state', () {
        expect(
          () => interceptor.logConnectivity(isConnected: false),
          returnsNormally,
        );
      });

      test('logs connected with network type', () {
        expect(
          () => interceptor.logConnectivity(
            isConnected: true,
            networkType: 'wifi',
          ),
          returnsNormally,
        );
      });

      test('logs connected with cellular network type', () {
        expect(
          () => interceptor.logConnectivity(
            isConnected: true,
            networkType: '4G',
          ),
          returnsNormally,
        );
      });

      test('logs disconnected ignores network type', () {
        expect(
          () => interceptor.logConnectivity(
            isConnected: false,
            networkType: 'wifi', // Should be ignored
          ),
          returnsNormally,
        );
      });
    });

    group('logRateLimit', () {
      test('logs rate limit with retry after', () {
        expect(
          () => interceptor.logRateLimit(
            method: 'POST',
            url: 'https://api.example.com/users',
            retryAfter: 60,
          ),
          returnsNormally,
        );
      });

      test('handles different retry durations', () {
        for (final duration in [1, 30, 60, 300, 3600]) {
          expect(
            () => interceptor.logRateLimit(
              method: 'GET',
              url: 'https://api.example.com/resource',
              retryAfter: duration,
            ),
            returnsNormally,
            reason: 'Should handle retry after $duration seconds',
          );
        }
      });

      test('handles zero retry after', () {
        expect(
          () => interceptor.logRateLimit(
            method: 'GET',
            url: 'https://api.example.com/resource',
            retryAfter: 0,
          ),
          returnsNormally,
        );
      });
    });

    group('logAuth', () {
      test('logs successful authentication', () {
        expect(
          () => interceptor.logAuth(
            action: 'login',
            success: true,
          ),
          returnsNormally,
        );
      });

      test('logs failed authentication', () {
        expect(
          () => interceptor.logAuth(
            action: 'login',
            success: false,
          ),
          returnsNormally,
        );
      });

      test('logs successful auth with userId', () {
        expect(
          () => interceptor.logAuth(
            action: 'login',
            success: true,
            userId: 'user123',
          ),
          returnsNormally,
        );
      });

      test('logs failed auth with error', () {
        expect(
          () => interceptor.logAuth(
            action: 'login',
            success: false,
            error: 'Invalid credentials',
          ),
          returnsNormally,
        );
      });

      test('handles different auth actions', () {
        final actions = ['login', 'logout', 'refresh', 'register', 'verify'];
        for (final action in actions) {
          expect(
            () => interceptor.logAuth(
              action: action,
              success: true,
            ),
            returnsNormally,
            reason: 'Should handle auth action: $action',
          );
        }
      });
    });

    group('logValidation', () {
      test('logs validation errors', () {
        expect(
          () => interceptor.logValidation(
            endpoint: '/users',
            data: {'name': ''},
            errors: ['Name is required'],
          ),
          returnsNormally,
        );
      });

      test('logs multiple validation errors', () {
        expect(
          () => interceptor.logValidation(
            endpoint: '/users',
            data: {
              'name': '',
              'email': 'invalid',
              'age': -1,
            },
            errors: [
              'Name is required',
              'Invalid email format',
              'Age must be positive',
            ],
          ),
          returnsNormally,
        );
      });

      test('handles empty errors list', () {
        expect(
          () => interceptor.logValidation(
            endpoint: '/users',
            data: {'name': 'John'},
            errors: [],
          ),
          returnsNormally,
        );
      });

      test('handles complex data structures', () {
        expect(
          () => interceptor.logValidation(
            endpoint: '/orders',
            data: {
              'items': [
                {'id': 1, 'quantity': 0},
                {'id': 2, 'quantity': -1},
              ],
              'shipping': {
                'address': null,
              },
            },
            errors: [
              'Item 1 quantity must be positive',
              'Item 2 quantity must be positive',
              'Shipping address is required',
            ],
          ),
          returnsNormally,
        );
      });
    });

    group('body truncation', () {
      test('handles body under max length', () {
        expect(
          () => interceptor.logRequest(
            method: 'POST',
            url: 'https://api.example.com/data',
            body: {'short': 'data'},
          ),
          returnsNormally,
        );
      });

      test('handles very long body', () {
        final longBody = <String, dynamic>{};
        for (int i = 0; i < 100; i++) {
          longBody['field_$i'] = 'value_$i' * 100;
        }

        expect(
          () => interceptor.logRequest(
            method: 'POST',
            url: 'https://api.example.com/data',
            body: longBody,
          ),
          returnsNormally,
        );
      });
    });

    group('map formatting', () {
      test('handles single entry map', () {
        expect(
          () => interceptor.logRequest(
            method: 'GET',
            url: 'https://api.example.com/data',
            headers: {'Authorization': 'Bearer token'},
          ),
          returnsNormally,
        );
      });

      test('handles multi-entry map', () {
        expect(
          () => interceptor.logRequest(
            method: 'GET',
            url: 'https://api.example.com/data',
            headers: {
              'Authorization': 'Bearer token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Custom-Header': 'custom-value',
            },
          ),
          returnsNormally,
        );
      });
    });
  });
}
