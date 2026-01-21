import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('WebSessionStatus', () {
    test('has all expected values', () {
      expect(WebSessionStatus.values.length, 6);
      expect(WebSessionStatus.pending, isNotNull);
      expect(WebSessionStatus.approved, isNotNull);
      expect(WebSessionStatus.rejected, isNotNull);
      expect(WebSessionStatus.expired, isNotNull);
      expect(WebSessionStatus.connected, isNotNull);
      expect(WebSessionStatus.disconnected, isNotNull);
    });

    test('values have correct names', () {
      expect(WebSessionStatus.pending.name, 'pending');
      expect(WebSessionStatus.approved.name, 'approved');
      expect(WebSessionStatus.rejected.name, 'rejected');
      expect(WebSessionStatus.expired.name, 'expired');
      expect(WebSessionStatus.connected.name, 'connected');
      expect(WebSessionStatus.disconnected.name, 'disconnected');
    });
  });

  group('PtySize', () {
    test('creates with required cols and rows', () {
      const size = PtySize(cols: 80, rows: 24);
      expect(size.cols, 80);
      expect(size.rows, 24);
    });

    test('supports various dimensions', () {
      const small = PtySize(cols: 40, rows: 12);
      const large = PtySize(cols: 200, rows: 60);

      expect(small.cols, 40);
      expect(small.rows, 12);
      expect(large.cols, 200);
      expect(large.rows, 60);
    });

    test('supports zero dimensions', () {
      const zero = PtySize(cols: 0, rows: 0);
      expect(zero.cols, 0);
      expect(zero.rows, 0);
    });
  });

  group('WebSession', () {
    late WebSession session;

    setUp(() {
      session = WebSession(
        id: 'test-session-id',
        approvalCode: 'ABC123',
        clientAddress: '192.168.1.100',
      );
    });

    tearDown(() async {
      await session.close();
    });

    group('constructor', () {
      test('creates session with required fields', () {
        expect(session.id, 'test-session-id');
        expect(session.approvalCode, 'ABC123');
        expect(session.clientAddress, '192.168.1.100');
        expect(session.status, WebSessionStatus.pending);
        expect(session.userAgent, isNull);
      });

      test('creates session with optional userAgent', () {
        final sessionWithAgent = WebSession(
          id: 'session-2',
          approvalCode: 'XYZ789',
          clientAddress: '10.0.0.1',
          userAgent: 'Mozilla/5.0',
        );
        expect(sessionWithAgent.userAgent, 'Mozilla/5.0');
        sessionWithAgent.close();
      });

      test('creates session with custom status', () {
        final approvedSession = WebSession(
          id: 'session-3',
          approvalCode: 'DEF456',
          clientAddress: '172.16.0.1',
          status: WebSessionStatus.approved,
        );
        expect(approvedSession.status, WebSessionStatus.approved);
        approvedSession.close();
      });

      test('sets createdAt to current time', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final newSession = WebSession(
          id: 'new-session',
          approvalCode: 'NEW123',
          clientAddress: '127.0.0.1',
        );
        final after = DateTime.now().add(const Duration(seconds: 1));

        expect(newSession.createdAt.isAfter(before), isTrue);
        expect(newSession.createdAt.isBefore(after), isTrue);
        newSession.close();
      });
    });

    group('generateApprovalCode', () {
      test('generates 6-character code', () {
        final code = WebSession.generateApprovalCode();
        expect(code.length, 6);
      });

      test('generates uppercase alphanumeric code', () {
        final code = WebSession.generateApprovalCode();
        final pattern = RegExp(r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]+$');
        expect(pattern.hasMatch(code), isTrue);
      });

      test('excludes confusing characters (I, O, 0, 1)', () {
        // Generate many codes to verify exclusion
        final codes =
            List.generate(100, (_) => WebSession.generateApprovalCode());
        for (final code in codes) {
          expect(code.contains('I'), isFalse);
          expect(code.contains('O'), isFalse);
          expect(code.contains('0'), isFalse);
          expect(code.contains('1'), isFalse);
        }
      });

      test('generates unique codes', () {
        final codes = <String>{};
        for (var i = 0; i < 100; i++) {
          codes.add(WebSession.generateApprovalCode());
        }
        // Very high probability all are unique
        expect(codes.length, 100);
      });
    });

    group('status helpers', () {
      test('isPending returns true for pending status', () {
        expect(session.isPending, isTrue);
        expect(session.status, WebSessionStatus.pending);
      });

      test('isApproved returns false for pending status', () {
        expect(session.isApproved, isFalse);
      });

      test('isApproved returns true for approved status', () {
        session.status = WebSessionStatus.approved;
        expect(session.isApproved, isTrue);
      });

      test('isApproved returns true for connected status', () {
        session.status = WebSessionStatus.connected;
        expect(session.isApproved, isTrue);
      });

      test('isConnected returns false when no channel', () {
        session.status = WebSessionStatus.connected;
        expect(session.isConnected, isFalse);
      });
    });

    group('pty management', () {
      test('ptyCount starts at 0', () {
        expect(session.ptyCount, 0);
      });

      test('ptySessions map starts empty', () {
        expect(session.ptySessions, isEmpty);
      });

      test('ptySizes map starts empty', () {
        expect(session.ptySizes, isEmpty);
      });

      test('ptyBuffers map starts empty', () {
        expect(session.ptyBuffers, isEmpty);
      });

      test('updatePtySize does nothing for non-existent pty', () {
        session.updatePtySize('non-existent', 100, 50);
        expect(session.ptySizes['non-existent'], isNull);
      });

      test('appendPtyBuffer does nothing for non-existent pty', () {
        session.appendPtyBuffer('non-existent', 'data');
        expect(session.ptyBuffers['non-existent'], isNull);
      });

      test('getPtyBuffer returns empty string for non-existent pty', () {
        expect(session.getPtyBuffer('non-existent'), '');
      });

      test('closeAllPtys clears all pty maps', () {
        // Manually add entries to test clearing
        session.ptySizes['test-pty'] = const PtySize(cols: 80, rows: 24);
        session.ptyBuffers['test-pty'] = 'buffer content';

        session.closeAllPtys();

        expect(session.ptySessions, isEmpty);
        expect(session.ptySizes, isEmpty);
        expect(session.ptyBuffers, isEmpty);
      });
    });

    group('buffer management', () {
      setUp(() {
        // Set up a pty buffer for testing
        session.ptyBuffers['test-pty'] = '';
      });

      test('appendPtyBuffer adds content', () {
        session.appendPtyBuffer('test-pty', 'Hello');
        expect(session.getPtyBuffer('test-pty'), 'Hello');
      });

      test('appendPtyBuffer accumulates content', () {
        session.appendPtyBuffer('test-pty', 'Hello');
        session.appendPtyBuffer('test-pty', ' World');
        expect(session.getPtyBuffer('test-pty'), 'Hello World');
      });

      test('appendPtyBuffer truncates at max size', () {
        // Create a string larger than max buffer (100000 chars)
        final largeContent = 'A' * 120000;
        session.appendPtyBuffer('test-pty', largeContent);

        final buffer = session.getPtyBuffer('test-pty');
        expect(buffer.length, 100000);
        // Should keep the last 100000 characters
        expect(buffer, 'A' * 100000);
      });
    });

    group('byte tracking', () {
      test('starts with zero bytes', () {
        expect(session.bytesReceived, 0);
        expect(session.bytesSent, 0);
      });

      test('recordIncomingBytes adds to total', () {
        session.recordIncomingBytes(100);
        expect(session.bytesReceived, 100);

        session.recordIncomingBytes(50);
        expect(session.bytesReceived, 150);
      });

      test('recordOutgoingBytes adds to total', () {
        session.recordOutgoingBytes(200);
        expect(session.bytesSent, 200);

        session.recordOutgoingBytes(100);
        expect(session.bytesSent, 300);
      });

      test('starts with zero rates', () {
        expect(session.inboundRate, 0);
        expect(session.outboundRate, 0);
      });

      test('latencyMs starts as null', () {
        expect(session.latencyMs, isNull);
      });

      test('updateLatency sets latency', () {
        session.updateLatency(50);
        expect(session.latencyMs, 50);

        session.updateLatency(100);
        expect(session.latencyMs, 100);
      });
    });

    group('toJson', () {
      test('includes all fields', () {
        session.bytesReceived = 1024;
        session.bytesSent = 2048;
        session.updateLatency(25);

        final json = session.toJson();

        expect(json['id'], 'test-session-id');
        expect(json['approvalCode'], 'ABC123');
        expect(json['createdAt'], isA<String>());
        expect(json['clientAddress'], '192.168.1.100');
        expect(json['userAgent'], isNull);
        expect(json['status'], 'pending');
        expect(json['ptyCount'], 0);
        expect(json['bytesReceived'], 1024);
        expect(json['bytesSent'], 2048);
        expect(json['inboundRate'], 0);
        expect(json['outboundRate'], 0);
        expect(json['latencyMs'], 25);
      });

      test('createdAt is valid ISO8601 string', () {
        final json = session.toJson();
        final createdAt = json['createdAt'] as String;

        // Should parse without error
        expect(() => DateTime.parse(createdAt), returnsNormally);
      });

      test('status name is serialized correctly', () {
        session.status = WebSessionStatus.approved;
        expect(session.toJson()['status'], 'approved');

        session.status = WebSessionStatus.connected;
        expect(session.toJson()['status'], 'connected');
      });
    });

    group('detach', () {
      test('changes connected status to disconnected', () {
        session.status = WebSessionStatus.connected;
        session.detach();
        expect(session.status, WebSessionStatus.disconnected);
      });

      test('does not change non-connected status', () {
        session.status = WebSessionStatus.approved;
        session.detach();
        expect(session.status, WebSessionStatus.approved);
      });

      test('clears all ptys', () {
        session.ptySizes['pty-1'] = const PtySize(cols: 80, rows: 24);
        session.ptyBuffers['pty-1'] = 'data';

        session.detach();

        expect(session.ptySessions, isEmpty);
        expect(session.ptySizes, isEmpty);
        expect(session.ptyBuffers, isEmpty);
      });
    });
  });

  group('WsSessionInternalEvent', () {
    group('WsPtyCreatedEvent', () {
      test('stores ptyId', () {
        const event = WsPtyCreatedEvent('pty-123');
        expect(event.ptyId, 'pty-123');
      });

      test('is a WsSessionInternalEvent', () {
        const event = WsPtyCreatedEvent('pty-1');
        expect(event, isA<WsSessionInternalEvent>());
      });
    });

    group('WsPtyOutputEvent', () {
      test('stores ptyId and data', () {
        final data = Uint8List.fromList([72, 101, 108, 108, 111]);
        final event = WsPtyOutputEvent('pty-output', data);

        expect(event.ptyId, 'pty-output');
        expect(event.data, data);
      });

      test('is a WsSessionInternalEvent', () {
        final event = WsPtyOutputEvent('pty-1', Uint8List(0));
        expect(event, isA<WsSessionInternalEvent>());
      });
    });

    group('WsPtyClosedEvent', () {
      test('stores ptyId and exitCode', () {
        const event = WsPtyClosedEvent('pty-closed', 0);
        expect(event.ptyId, 'pty-closed');
        expect(event.exitCode, 0);
      });

      test('stores non-zero exit code', () {
        const event = WsPtyClosedEvent('pty-error', 1);
        expect(event.exitCode, 1);
      });

      test('is a WsSessionInternalEvent', () {
        const event = WsPtyClosedEvent('pty-1', 0);
        expect(event, isA<WsSessionInternalEvent>());
      });
    });

    group('WsPtyResizedEvent', () {
      test('stores ptyId, cols, and rows', () {
        const event = WsPtyResizedEvent('pty-resize', 120, 40);
        expect(event.ptyId, 'pty-resize');
        expect(event.cols, 120);
        expect(event.rows, 40);
      });

      test('is a WsSessionInternalEvent', () {
        const event = WsPtyResizedEvent('pty-1', 80, 24);
        expect(event, isA<WsSessionInternalEvent>());
      });
    });
  });
}
