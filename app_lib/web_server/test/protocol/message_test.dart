import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('SessionStatus', () {
    test('creates with required fields', () {
      const msg = SessionStatus(status: 'pending');
      expect(msg.type, 'session_status');
      expect(msg.status, 'pending');
      expect(msg.message, isNull);
      expect(msg.approvalCode, isNull);
    });

    test('creates with all fields', () {
      const msg = SessionStatus(
        status: 'approved',
        message: 'Session approved',
        approvalCode: 'ABC123',
      );
      expect(msg.status, 'approved');
      expect(msg.message, 'Session approved');
      expect(msg.approvalCode, 'ABC123');
    });

    test('toJson includes non-null fields only', () {
      const msg = SessionStatus(status: 'pending');
      final json = msg.toJson();
      expect(json['type'], 'session_status');
      expect(json['status'], 'pending');
      expect(json.containsKey('message'), false);
      expect(json.containsKey('approvalCode'), false);
    });

    test('toJson includes all fields when present', () {
      const msg = SessionStatus(
        status: 'rejected',
        message: 'Access denied',
        approvalCode: 'XYZ',
      );
      final json = msg.toJson();
      expect(json['message'], 'Access denied');
      expect(json['approvalCode'], 'XYZ');
    });

    test('fromJson roundtrip', () {
      const original = SessionStatus(
        status: 'connected',
        message: 'Connected successfully',
      );
      final json = original.toJson();
      final decoded = SessionStatus.fromJson(json);

      expect(decoded.status, original.status);
      expect(decoded.message, original.message);
    });

    test('toJsonString produces valid JSON', () {
      const msg = SessionStatus(status: 'pending');
      final jsonStr = msg.toJsonString();
      final parsed = jsonDecode(jsonStr);
      expect(parsed['type'], 'session_status');
    });
  });

  group('CreatePtyRequest', () {
    test('creates with required fields', () {
      const msg = CreatePtyRequest(ptyId: 'pty-1', cols: 80, rows: 24);
      expect(msg.type, 'create_pty');
      expect(msg.ptyId, 'pty-1');
      expect(msg.cols, 80);
      expect(msg.rows, 24);
      expect(msg.env, isNull);
    });

    test('creates with environment', () {
      const msg = CreatePtyRequest(
        ptyId: 'pty-2',
        cols: 120,
        rows: 40,
        env: {'TERM': 'xterm-256color', 'HOME': '/home/user'},
      );
      expect(msg.env, {'TERM': 'xterm-256color', 'HOME': '/home/user'});
    });

    test('toJson includes env when present', () {
      const msg = CreatePtyRequest(
        ptyId: 'pty-1',
        cols: 80,
        rows: 24,
        env: {'LANG': 'en_US.UTF-8'},
      );
      final json = msg.toJson();
      expect(json['env'], {'LANG': 'en_US.UTF-8'});
    });

    test('fromJson with defaults for cols/rows', () {
      final json = {'ptyId': 'pty-1', 'type': 'create_pty'};
      final msg = CreatePtyRequest.fromJson(json);
      expect(msg.cols, 80); // default
      expect(msg.rows, 24); // default
    });

    test('fromJson roundtrip', () {
      const original = CreatePtyRequest(
        ptyId: 'test-pty',
        cols: 100,
        rows: 30,
        env: {'KEY': 'value'},
      );
      final decoded = CreatePtyRequest.fromJson(original.toJson());

      expect(decoded.ptyId, original.ptyId);
      expect(decoded.cols, original.cols);
      expect(decoded.rows, original.rows);
      expect(decoded.env, original.env);
    });
  });

  group('CreatePtyResponse', () {
    test('creates success response', () {
      const msg = CreatePtyResponse(ptyId: 'pty-1', success: true);
      expect(msg.type, 'create_pty_response');
      expect(msg.success, true);
      expect(msg.error, isNull);
    });

    test('creates failure response', () {
      const msg = CreatePtyResponse(
        ptyId: 'pty-1',
        success: false,
        error: 'Failed to spawn shell',
      );
      expect(msg.success, false);
      expect(msg.error, 'Failed to spawn shell');
    });

    test('fromJson roundtrip', () {
      const original = CreatePtyResponse(
        ptyId: 'pty-test',
        success: false,
        error: 'Max sessions exceeded',
      );
      final decoded = CreatePtyResponse.fromJson(original.toJson());

      expect(decoded.ptyId, original.ptyId);
      expect(decoded.success, original.success);
      expect(decoded.error, original.error);
    });
  });

  group('ClosePtyRequest', () {
    test('creates with ptyId', () {
      const msg = ClosePtyRequest(ptyId: 'pty-to-close');
      expect(msg.type, 'close_pty');
      expect(msg.ptyId, 'pty-to-close');
    });

    test('fromJson roundtrip', () {
      const original = ClosePtyRequest(ptyId: 'test-pty');
      final decoded = ClosePtyRequest.fromJson(original.toJson());
      expect(decoded.ptyId, original.ptyId);
    });
  });

  group('PtyExited', () {
    test('creates with exit code', () {
      const msg = PtyExited(ptyId: 'pty-1', exitCode: 0);
      expect(msg.type, 'pty_exited');
      expect(msg.ptyId, 'pty-1');
      expect(msg.exitCode, 0);
    });

    test('handles non-zero exit code', () {
      const msg = PtyExited(ptyId: 'pty-1', exitCode: 127);
      expect(msg.exitCode, 127);
    });

    test('fromJson roundtrip', () {
      const original = PtyExited(ptyId: 'test', exitCode: 1);
      final decoded = PtyExited.fromJson(original.toJson());

      expect(decoded.ptyId, original.ptyId);
      expect(decoded.exitCode, original.exitCode);
    });
  });

  group('ResizePtyRequest', () {
    test('creates with dimensions', () {
      const msg = ResizePtyRequest(ptyId: 'pty-1', cols: 132, rows: 43);
      expect(msg.type, 'resize_pty');
      expect(msg.cols, 132);
      expect(msg.rows, 43);
    });

    test('fromJson roundtrip', () {
      const original = ResizePtyRequest(ptyId: 'test', cols: 200, rows: 50);
      final decoded = ResizePtyRequest.fromJson(original.toJson());

      expect(decoded.ptyId, original.ptyId);
      expect(decoded.cols, original.cols);
      expect(decoded.rows, original.rows);
    });
  });

  group('Ping/Pong', () {
    test('Ping creates with timestamp', () {
      const msg = Ping(sentAt: 1234567890);
      expect(msg.type, 'ping');
      expect(msg.sentAt, 1234567890);
    });

    test('Pong creates with timestamp', () {
      const msg = Pong(sentAt: 1234567890);
      expect(msg.type, 'pong');
      expect(msg.sentAt, 1234567890);
    });

    test('Ping fromJson defaults to current time', () {
      final msg = Ping.fromJson({'type': 'ping'});
      expect(msg.sentAt, greaterThan(0));
    });

    test('Pong fromJson defaults to current time', () {
      final msg = Pong.fromJson({'type': 'pong'});
      expect(msg.sentAt, greaterThan(0));
    });

    test('Ping/Pong roundtrip', () {
      const ping = Ping(sentAt: 999999);
      final pong = Pong.fromJson(Ping.fromJson(ping.toJson()).toJson()
        ..['type'] = 'pong');
      expect(pong.sentAt, ping.sentAt);
    });
  });

  group('ErrorMessage', () {
    test('creates with code and message', () {
      const msg = ErrorMessage(code: 'AUTH_FAILED', message: 'Invalid token');
      expect(msg.type, 'error');
      expect(msg.code, 'AUTH_FAILED');
      expect(msg.message, 'Invalid token');
    });

    test('fromJson roundtrip', () {
      const original = ErrorMessage(
        code: 'RATE_LIMITED',
        message: 'Too many requests',
      );
      final decoded = ErrorMessage.fromJson(original.toJson());

      expect(decoded.code, original.code);
      expect(decoded.message, original.message);
    });
  });

  group('parseMessage', () {
    test('parses session_status', () {
      final msg = parseMessage('{"type":"session_status","status":"pending"}');
      expect(msg, isA<SessionStatus>());
      expect((msg as SessionStatus).status, 'pending');
    });

    test('parses create_pty', () {
      final msg = parseMessage(
        '{"type":"create_pty","ptyId":"p1","cols":80,"rows":24}',
      );
      expect(msg, isA<CreatePtyRequest>());
    });

    test('parses ping', () {
      final msg = parseMessage('{"type":"ping","sentAt":123}');
      expect(msg, isA<Ping>());
    });

    test('parses pong', () {
      final msg = parseMessage('{"type":"pong","sentAt":456}');
      expect(msg, isA<Pong>());
    });

    test('parses error', () {
      final msg = parseMessage('{"type":"error","code":"E1","message":"fail"}');
      expect(msg, isA<ErrorMessage>());
    });

    test('returns null for unknown type', () {
      final msg = parseMessage('{"type":"unknown_type"}');
      expect(msg, isNull);
    });

    test('returns null for invalid JSON', () {
      final msg = parseMessage('not json');
      expect(msg, isNull);
    });

    test('returns null for missing type', () {
      final msg = parseMessage('{"data":"test"}');
      expect(msg, isNull);
    });
  });

  group('parseMessageFromJson', () {
    test('parses all message types', () {
      final types = [
        {'type': 'session_status', 'status': 'pending'},
        {'type': 'create_pty', 'ptyId': 'p', 'cols': 80, 'rows': 24},
        {'type': 'create_pty_response', 'ptyId': 'p', 'success': true},
        {'type': 'close_pty', 'ptyId': 'p'},
        {'type': 'pty_exited', 'ptyId': 'p', 'exitCode': 0},
        {'type': 'resize_pty', 'ptyId': 'p', 'cols': 80, 'rows': 24},
        {'type': 'ping', 'sentAt': 123},
        {'type': 'pong', 'sentAt': 456},
        {'type': 'error', 'code': 'E', 'message': 'M'},
      ];

      for (final json in types) {
        final msg = parseMessageFromJson(json);
        expect(msg, isNotNull, reason: 'Failed to parse ${json['type']}');
      }
    });

    test('returns null for null type', () {
      final msg = parseMessageFromJson({'data': 'test'});
      expect(msg, isNull);
    });
  });

  group('Binary Protocol', () {
    group('encodeBinaryFrame', () {
      test('encodes simple frame', () {
        final frame = encodeBinaryFrame('pty-1', Uint8List.fromList([1, 2, 3]));

        expect(frame[0], 5); // 'pty-1' length
        expect(frame.sublist(1, 6), 'pty-1'.codeUnits);
        expect(frame.sublist(6), [1, 2, 3]);
      });

      test('encodes empty data', () {
        final frame = encodeBinaryFrame('p', Uint8List(0));
        expect(frame.length, 2); // 1 length byte + 1 ptyId byte
      });

      test('encodes long ptyId', () {
        final ptyId = 'a' * 50;
        final frame = encodeBinaryFrame(ptyId, Uint8List.fromList([99]));

        expect(frame[0], 50);
        expect(frame.length, 1 + 50 + 1);
      });
    });

    group('decodeBinaryFrame', () {
      test('decodes simple frame', () {
        final frame = encodeBinaryFrame('test', Uint8List.fromList([10, 20]));
        final result = decodeBinaryFrame(frame);

        expect(result, isNotNull);
        expect(result!.ptyId, 'test');
        expect(result.data, [10, 20]);
      });

      test('returns null for empty frame', () {
        final result = decodeBinaryFrame(Uint8List(0));
        expect(result, isNull);
      });

      test('returns null for truncated frame', () {
        // Frame says ptyId is 10 bytes but only 5 bytes provided
        final malformed = Uint8List.fromList([10, 1, 2, 3, 4, 5]);
        final result = decodeBinaryFrame(malformed);
        expect(result, isNull);
      });

      test('roundtrip', () {
        final ptyId = 'my-terminal-session';
        final data = Uint8List.fromList('Hello, World!'.codeUnits);

        final frame = encodeBinaryFrame(ptyId, data);
        final result = decodeBinaryFrame(frame);

        expect(result!.ptyId, ptyId);
        expect(result.data, data);
      });
    });
  });
}
