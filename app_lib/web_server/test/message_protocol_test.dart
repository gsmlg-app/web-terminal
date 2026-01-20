import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('SessionStatus', () {
    test('creates with required parameters', () {
      const status = SessionStatus(status: 'approved');

      expect(status.type, 'session_status');
      expect(status.status, 'approved');
      expect(status.message, isNull);
      expect(status.approvalCode, isNull);
    });

    test('creates with all parameters', () {
      const status = SessionStatus(
        status: 'pending',
        message: 'Waiting for approval',
        approvalCode: 'ABC123',
      );

      expect(status.status, 'pending');
      expect(status.message, 'Waiting for approval');
      expect(status.approvalCode, 'ABC123');
    });

    test('toJson includes only non-null fields', () {
      const status = SessionStatus(status: 'connected');
      final json = status.toJson();

      expect(json['type'], 'session_status');
      expect(json['status'], 'connected');
      expect(json.containsKey('message'), false);
      expect(json.containsKey('approvalCode'), false);
    });

    test('toJson includes all fields when set', () {
      const status = SessionStatus(
        status: 'pending',
        message: 'Test message',
        approvalCode: 'CODE',
      );
      final json = status.toJson();

      expect(json['message'], 'Test message');
      expect(json['approvalCode'], 'CODE');
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'session_status',
        'status': 'rejected',
        'message': 'Invalid token',
      };
      final status = SessionStatus.fromJson(json);

      expect(status.status, 'rejected');
      expect(status.message, 'Invalid token');
      expect(status.approvalCode, isNull);
    });

    test('toJsonString produces valid JSON', () {
      const status = SessionStatus(status: 'approved');
      final jsonString = status.toJsonString();
      final decoded = jsonDecode(jsonString);

      expect(decoded['type'], 'session_status');
      expect(decoded['status'], 'approved');
    });
  });

  group('CreatePtyRequest', () {
    test('creates with required parameters', () {
      const request = CreatePtyRequest(
        ptyId: 'pty-123',
        cols: 80,
        rows: 24,
      );

      expect(request.type, 'create_pty');
      expect(request.ptyId, 'pty-123');
      expect(request.cols, 80);
      expect(request.rows, 24);
      expect(request.env, isNull);
    });

    test('creates with environment variables', () {
      const request = CreatePtyRequest(
        ptyId: 'pty-1',
        cols: 120,
        rows: 40,
        env: {'TERM': 'xterm-256color', 'HOME': '/home/user'},
      );

      expect(request.env, {'TERM': 'xterm-256color', 'HOME': '/home/user'});
    });

    test('toJson excludes null env', () {
      const request = CreatePtyRequest(ptyId: 'x', cols: 80, rows: 24);
      final json = request.toJson();

      expect(json.containsKey('env'), false);
    });

    test('toJson includes env when set', () {
      const request = CreatePtyRequest(
        ptyId: 'x',
        cols: 80,
        rows: 24,
        env: {'KEY': 'value'},
      );
      final json = request.toJson();

      expect(json['env'], {'KEY': 'value'});
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'create_pty',
        'ptyId': 'pty-abc',
        'cols': 100,
        'rows': 30,
        'env': {'SHELL': '/bin/bash'},
      };
      final request = CreatePtyRequest.fromJson(json);

      expect(request.ptyId, 'pty-abc');
      expect(request.cols, 100);
      expect(request.rows, 30);
      expect(request.env, {'SHELL': '/bin/bash'});
    });

    test('fromJson uses defaults for missing cols/rows', () {
      final json = {
        'type': 'create_pty',
        'ptyId': 'pty-1',
      };
      final request = CreatePtyRequest.fromJson(json);

      expect(request.cols, 80);
      expect(request.rows, 24);
    });
  });

  group('CreatePtyResponse', () {
    test('creates success response', () {
      const response = CreatePtyResponse(
        ptyId: 'pty-123',
        success: true,
      );

      expect(response.type, 'create_pty_response');
      expect(response.ptyId, 'pty-123');
      expect(response.success, true);
      expect(response.error, isNull);
    });

    test('creates error response', () {
      const response = CreatePtyResponse(
        ptyId: 'pty-123',
        success: false,
        error: 'Maximum sessions reached',
      );

      expect(response.success, false);
      expect(response.error, 'Maximum sessions reached');
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'create_pty_response',
        'ptyId': 'pty-1',
        'success': false,
        'error': 'Failed to spawn process',
      };
      final response = CreatePtyResponse.fromJson(json);

      expect(response.ptyId, 'pty-1');
      expect(response.success, false);
      expect(response.error, 'Failed to spawn process');
    });
  });

  group('ClosePtyRequest', () {
    test('creates with ptyId', () {
      const request = ClosePtyRequest(ptyId: 'pty-to-close');

      expect(request.type, 'close_pty');
      expect(request.ptyId, 'pty-to-close');
    });

    test('toJson contains type and ptyId', () {
      const request = ClosePtyRequest(ptyId: 'x');
      final json = request.toJson();

      expect(json, {'type': 'close_pty', 'ptyId': 'x'});
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'close_pty', 'ptyId': 'pty-abc'};
      final request = ClosePtyRequest.fromJson(json);

      expect(request.ptyId, 'pty-abc');
    });
  });

  group('PtyExited', () {
    test('creates with ptyId and exitCode', () {
      const msg = PtyExited(ptyId: 'pty-1', exitCode: 0);

      expect(msg.type, 'pty_exited');
      expect(msg.ptyId, 'pty-1');
      expect(msg.exitCode, 0);
    });

    test('handles non-zero exit code', () {
      const msg = PtyExited(ptyId: 'pty-2', exitCode: 127);

      expect(msg.exitCode, 127);
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'pty_exited', 'ptyId': 'x', 'exitCode': 1};
      final msg = PtyExited.fromJson(json);

      expect(msg.ptyId, 'x');
      expect(msg.exitCode, 1);
    });
  });

  group('ResizePtyRequest', () {
    test('creates with dimensions', () {
      const request = ResizePtyRequest(ptyId: 'pty-1', cols: 120, rows: 40);

      expect(request.type, 'resize_pty');
      expect(request.ptyId, 'pty-1');
      expect(request.cols, 120);
      expect(request.rows, 40);
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'resize_pty',
        'ptyId': 'pty-abc',
        'cols': 200,
        'rows': 50,
      };
      final request = ResizePtyRequest.fromJson(json);

      expect(request.ptyId, 'pty-abc');
      expect(request.cols, 200);
      expect(request.rows, 50);
    });
  });

  group('Ping', () {
    test('creates with sentAt', () {
      const ping = Ping(sentAt: 1234567890);

      expect(ping.type, 'ping');
      expect(ping.sentAt, 1234567890);
    });

    test('toJson contains type and sentAt', () {
      const ping = Ping(sentAt: 1000);
      final json = ping.toJson();

      expect(json, {'type': 'ping', 'sentAt': 1000});
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'ping', 'sentAt': 9999};
      final ping = Ping.fromJson(json);

      expect(ping.sentAt, 9999);
    });

    test('fromJson uses current time when sentAt missing', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final json = {'type': 'ping'};
      final ping = Ping.fromJson(json);
      final after = DateTime.now().millisecondsSinceEpoch;

      expect(ping.sentAt, greaterThanOrEqualTo(before));
      expect(ping.sentAt, lessThanOrEqualTo(after));
    });
  });

  group('Pong', () {
    test('creates with sentAt', () {
      const pong = Pong(sentAt: 1234567890);

      expect(pong.type, 'pong');
      expect(pong.sentAt, 1234567890);
    });

    test('toJson contains type and sentAt', () {
      const pong = Pong(sentAt: 2000);
      final json = pong.toJson();

      expect(json, {'type': 'pong', 'sentAt': 2000});
    });

    test('fromJson parses correctly', () {
      final json = {'type': 'pong', 'sentAt': 8888};
      final pong = Pong.fromJson(json);

      expect(pong.sentAt, 8888);
    });

    test('fromJson uses current time when sentAt missing', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final json = {'type': 'pong'};
      final pong = Pong.fromJson(json);
      final after = DateTime.now().millisecondsSinceEpoch;

      expect(pong.sentAt, greaterThanOrEqualTo(before));
      expect(pong.sentAt, lessThanOrEqualTo(after));
    });
  });

  group('ErrorMessage', () {
    test('creates with code and message', () {
      const error = ErrorMessage(
        code: 'INVALID_TOKEN',
        message: 'Token has expired',
      );

      expect(error.type, 'error');
      expect(error.code, 'INVALID_TOKEN');
      expect(error.message, 'Token has expired');
    });

    test('toJson contains all fields', () {
      const error = ErrorMessage(code: 'E001', message: 'Test error');
      final json = error.toJson();

      expect(json, {'type': 'error', 'code': 'E001', 'message': 'Test error'});
    });

    test('fromJson parses correctly', () {
      final json = {
        'type': 'error',
        'code': 'AUTH_FAILED',
        'message': 'Authentication failed',
      };
      final error = ErrorMessage.fromJson(json);

      expect(error.code, 'AUTH_FAILED');
      expect(error.message, 'Authentication failed');
    });
  });

  group('parseMessage', () {
    test('parses SessionStatus', () {
      final msg = parseMessage('{"type":"session_status","status":"approved"}');

      expect(msg, isA<SessionStatus>());
      expect((msg as SessionStatus).status, 'approved');
    });

    test('parses CreatePtyRequest', () {
      final msg = parseMessage(
          '{"type":"create_pty","ptyId":"x","cols":80,"rows":24}');

      expect(msg, isA<CreatePtyRequest>());
      expect((msg as CreatePtyRequest).ptyId, 'x');
    });

    test('parses CreatePtyResponse', () {
      final msg = parseMessage(
          '{"type":"create_pty_response","ptyId":"x","success":true}');

      expect(msg, isA<CreatePtyResponse>());
      expect((msg as CreatePtyResponse).success, true);
    });

    test('parses ClosePtyRequest', () {
      final msg = parseMessage('{"type":"close_pty","ptyId":"abc"}');

      expect(msg, isA<ClosePtyRequest>());
      expect((msg as ClosePtyRequest).ptyId, 'abc');
    });

    test('parses PtyExited', () {
      final msg = parseMessage('{"type":"pty_exited","ptyId":"x","exitCode":0}');

      expect(msg, isA<PtyExited>());
      expect((msg as PtyExited).exitCode, 0);
    });

    test('parses ResizePtyRequest', () {
      final msg = parseMessage(
          '{"type":"resize_pty","ptyId":"x","cols":100,"rows":30}');

      expect(msg, isA<ResizePtyRequest>());
      expect((msg as ResizePtyRequest).cols, 100);
    });

    test('parses Ping', () {
      final msg = parseMessage('{"type":"ping","sentAt":1234}');

      expect(msg, isA<Ping>());
      expect((msg as Ping).sentAt, 1234);
    });

    test('parses Pong', () {
      final msg = parseMessage('{"type":"pong","sentAt":5678}');

      expect(msg, isA<Pong>());
      expect((msg as Pong).sentAt, 5678);
    });

    test('parses ErrorMessage', () {
      final msg = parseMessage('{"type":"error","code":"E1","message":"Err"}');

      expect(msg, isA<ErrorMessage>());
      expect((msg as ErrorMessage).code, 'E1');
    });

    test('returns null for invalid JSON', () {
      final msg = parseMessage('not valid json');

      expect(msg, isNull);
    });

    test('returns null for unknown message type', () {
      final msg = parseMessage('{"type":"unknown_type"}');

      expect(msg, isNull);
    });

    test('returns null for missing type', () {
      final msg = parseMessage('{"status":"approved"}');

      expect(msg, isNull);
    });
  });

  group('parseMessageFromJson', () {
    test('parses valid message', () {
      final json = {'type': 'ping', 'sentAt': 1000};
      final msg = parseMessageFromJson(json);

      expect(msg, isA<Ping>());
    });

    test('returns null for null type', () {
      final json = {'status': 'approved'};
      final msg = parseMessageFromJson(json);

      expect(msg, isNull);
    });

    test('returns null for unknown type', () {
      final json = {'type': 'nonexistent'};
      final msg = parseMessageFromJson(json);

      expect(msg, isNull);
    });
  });

  group('encodeBinaryFrame', () {
    test('encodes ptyId and data', () {
      final data = Uint8List.fromList([65, 66, 67]); // ABC
      final frame = encodeBinaryFrame('pty-1', data);

      // First byte is ptyId length (5 for 'pty-1')
      expect(frame[0], 5);
      // Next 5 bytes are 'pty-1'
      expect(utf8.decode(frame.sublist(1, 6)), 'pty-1');
      // Remaining bytes are the data
      expect(frame.sublist(6), [65, 66, 67]);
    });

    test('handles empty data', () {
      final data = Uint8List(0);
      final frame = encodeBinaryFrame('x', data);

      expect(frame.length, 2); // 1 byte length + 1 byte ptyId
      expect(frame[0], 1);
      expect(frame[1], 'x'.codeUnitAt(0));
    });

    test('handles long ptyId', () {
      final longId = 'a' * 100;
      final data = Uint8List.fromList([1, 2, 3]);
      final frame = encodeBinaryFrame(longId, data);

      expect(frame[0], 100);
      expect(frame.length, 1 + 100 + 3);
    });
  });

  group('decodeBinaryFrame', () {
    test('decodes valid frame', () {
      final frame = Uint8List.fromList([
        5, // ptyId length
        112, 116, 121, 45, 49, // 'pty-1'
        65, 66, 67, // 'ABC'
      ]);
      final result = decodeBinaryFrame(frame);

      expect(result, isNotNull);
      expect(result!.ptyId, 'pty-1');
      expect(result.data, [65, 66, 67]);
    });

    test('returns null for empty frame', () {
      final frame = Uint8List(0);
      final result = decodeBinaryFrame(frame);

      expect(result, isNull);
    });

    test('returns null for truncated frame', () {
      final frame = Uint8List.fromList([5, 65, 66]); // says 5 bytes but only 2
      final result = decodeBinaryFrame(frame);

      expect(result, isNull);
    });

    test('handles frame with no data', () {
      final frame = Uint8List.fromList([1, 120]); // ptyId 'x', no data
      final result = decodeBinaryFrame(frame);

      expect(result, isNotNull);
      expect(result!.ptyId, 'x');
      expect(result.data.isEmpty, true);
    });

    test('roundtrip encode/decode preserves data', () {
      final originalPtyId = 'my-terminal-session';
      final originalData = Uint8List.fromList([1, 2, 3, 4, 5, 255, 0, 128]);

      final encoded = encodeBinaryFrame(originalPtyId, originalData);
      final decoded = decodeBinaryFrame(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.ptyId, originalPtyId);
      expect(decoded.data, originalData);
    });
  });

  group('WsMessage roundtrip', () {
    test('SessionStatus survives JSON roundtrip', () {
      const original = SessionStatus(
        status: 'pending',
        message: 'Test',
        approvalCode: 'ABC',
      );
      final jsonString = original.toJsonString();
      final parsed = parseMessage(jsonString) as SessionStatus;

      expect(parsed.status, original.status);
      expect(parsed.message, original.message);
      expect(parsed.approvalCode, original.approvalCode);
    });

    test('CreatePtyRequest survives JSON roundtrip', () {
      const original = CreatePtyRequest(
        ptyId: 'test-pty',
        cols: 120,
        rows: 40,
        env: {'TERM': 'xterm'},
      );
      final jsonString = original.toJsonString();
      final parsed = parseMessage(jsonString) as CreatePtyRequest;

      expect(parsed.ptyId, original.ptyId);
      expect(parsed.cols, original.cols);
      expect(parsed.rows, original.rows);
      expect(parsed.env, original.env);
    });

    test('ErrorMessage survives JSON roundtrip', () {
      const original = ErrorMessage(code: 'TEST', message: 'Test error');
      final jsonString = original.toJsonString();
      final parsed = parseMessage(jsonString) as ErrorMessage;

      expect(parsed.code, original.code);
      expect(parsed.message, original.message);
    });
  });
}
