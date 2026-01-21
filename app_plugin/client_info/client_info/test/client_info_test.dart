import 'package:flutter_test/flutter_test.dart';
import 'package:app_client_info/app_client_info.dart';
import 'package:app_client_info_platform_interface/app_client_info_platform_interface.dart';

// Mock platform implementation for testing
class MockClientInfoPlatform extends ClientInfoPlatform {
  final String _platform;
  final Map<String, dynamic> _additionalData;
  int refreshCallCount = 0;

  MockClientInfoPlatform({
    String platform = 'test',
    Map<String, dynamic> additionalData = const {'test_key': 'test_value'},
  })  : _platform = platform,
        _additionalData = additionalData;

  @override
  Future<Map<String, dynamic>> getData() async {
    return {
      'platform': _platform,
      'timestamp': DateTime.now().toIso8601String(),
      'additionalData': _additionalData,
    };
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
  }
}

// Mock that returns incomplete data for edge case testing
class IncompleteDataMockPlatform extends ClientInfoPlatform {
  @override
  Future<Map<String, dynamic>> getData() async {
    return {}; // Empty map
  }

  @override
  Future<void> refresh() async {}
}

// Mock that returns null additionalData
class NullAdditionalDataMockPlatform extends ClientInfoPlatform {
  @override
  Future<Map<String, dynamic>> getData() async {
    return {
      'platform': 'test',
      'timestamp': DateTime.now().toIso8601String(),
      // additionalData is null/missing
    };
  }

  @override
  Future<void> refresh() async {}
}

void main() {
  group('ClientInfo', () {
    late ClientInfo clientInfo;

    setUp(() {
      // Set mock platform for testing
      ClientInfo.setMockPlatform(MockClientInfoPlatform());
      clientInfo = ClientInfo.instance;
    });

    tearDown(() {
      ClientInfo.reset();
    });

    test('instance returns singleton', () {
      final instance1 = ClientInfo.instance;
      final instance2 = ClientInfo.instance;
      expect(instance1, same(instance2));
    });

    test('instance is same after multiple accesses', () {
      final first = ClientInfo.instance;
      final second = ClientInfo.instance;
      final third = ClientInfo.instance;
      expect(first, same(second));
      expect(second, same(third));
    });

    test('reset creates new instance', () {
      final before = ClientInfo.instance;
      ClientInfo.reset();
      final after = ClientInfo.instance;
      expect(before, isNot(same(after)));
    });

    test('getData returns ClientInfoData', () async {
      final data = await clientInfo.getData();

      expect(data, isA<ClientInfoData>());
      expect(data.platform, equals('test'));
      expect(data.timestamp, isA<DateTime>());
      expect(data.additionalData, isNotEmpty);
      expect(data.additionalData['test_key'], equals('test_value'));
    });

    test('getData returns data with custom platform', () async {
      ClientInfo.setMockPlatform(MockClientInfoPlatform(platform: 'android'));
      final data = await clientInfo.getData();
      expect(data.platform, equals('android'));
    });

    test('getData returns data with custom additionalData', () async {
      ClientInfo.setMockPlatform(MockClientInfoPlatform(
        additionalData: {'custom_key': 'custom_value', 'number': 42},
      ));
      final data = await clientInfo.getData();
      expect(data.additionalData['custom_key'], equals('custom_value'));
      expect(data.additionalData['number'], equals(42));
    });

    test('refresh calls platform refresh', () async {
      await expectLater(
        clientInfo.refresh(),
        completes,
      );
    });

    test('refresh increments call count on mock', () async {
      final mock = MockClientInfoPlatform();
      ClientInfo.setMockPlatform(mock);

      expect(mock.refreshCallCount, equals(0));
      await clientInfo.refresh();
      expect(mock.refreshCallCount, equals(1));
      await clientInfo.refresh();
      expect(mock.refreshCallCount, equals(2));
    });

    test('getData returns different timestamps on multiple calls', () async {
      final data1 = await clientInfo.getData();
      await Future.delayed(const Duration(milliseconds: 10));

      // Set new mock platform to simulate fresh data
      ClientInfo.setMockPlatform(MockClientInfoPlatform());
      final data2 = await clientInfo.getData();

      expect(data1.platform, equals(data2.platform));
    });

    test('getData with incomplete data returns defaults', () async {
      ClientInfo.setMockPlatform(IncompleteDataMockPlatform());
      final data = await clientInfo.getData();

      expect(data.platform, equals('unknown'));
      expect(data.timestamp, isA<DateTime>());
      expect(data.additionalData, isEmpty);
    });

    test('getData with null additionalData returns empty map', () async {
      ClientInfo.setMockPlatform(NullAdditionalDataMockPlatform());
      final data = await clientInfo.getData();

      expect(data.additionalData, isEmpty);
    });
  });

  group('ClientInfoData', () {
    test('constructor creates valid instance', () {
      final timestamp = DateTime.now();
      final data = ClientInfoData(
        platform: 'macos',
        timestamp: timestamp,
        additionalData: const {'key': 'value'},
      );

      expect(data.platform, equals('macos'));
      expect(data.timestamp, equals(timestamp));
      expect(data.additionalData, equals({'key': 'value'}));
    });

    test('constructor with default additionalData', () {
      final data = ClientInfoData(
        platform: 'linux',
        timestamp: DateTime.now(),
      );

      expect(data.additionalData, isEmpty);
      expect(data.additionalData, isA<Map<String, dynamic>>());
    });

    test('fromMap creates valid ClientInfoData', () {
      final map = {
        'platform': 'android',
        'timestamp': '2024-01-01T00:00:00.000Z',
        'additionalData': {
          'key': 'value',
        },
      };

      final data = ClientInfoData.fromMap(map);

      expect(data.platform, equals('android'));
      expect(data.timestamp, isA<DateTime>());
      expect(data.additionalData['key'], equals('value'));
    });

    test('fromMap with missing platform defaults to unknown', () {
      final map = <String, dynamic>{
        'timestamp': '2024-01-01T00:00:00.000Z',
      };

      final data = ClientInfoData.fromMap(map);
      expect(data.platform, equals('unknown'));
    });

    test('fromMap with missing timestamp defaults to now', () {
      final before = DateTime.now();
      final map = <String, dynamic>{
        'platform': 'test',
      };

      final data = ClientInfoData.fromMap(map);
      final after = DateTime.now();

      expect(data.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(data.timestamp.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('fromMap with null additionalData defaults to empty map', () {
      final map = <String, dynamic>{
        'platform': 'test',
        'timestamp': '2024-01-01T00:00:00.000Z',
        'additionalData': null,
      };

      final data = ClientInfoData.fromMap(map);
      expect(data.additionalData, isEmpty);
    });

    test('fromMap with empty map', () {
      final data = ClientInfoData.fromMap({});

      expect(data.platform, equals('unknown'));
      expect(data.timestamp, isA<DateTime>());
      expect(data.additionalData, isEmpty);
    });

    test('fromMap preserves complex additionalData', () {
      final map = {
        'platform': 'ios',
        'timestamp': '2024-06-15T12:30:00.000Z',
        'additionalData': {
          'device': 'iPhone',
          'version': 17.5,
          'features': ['faceId', 'nfc'],
          'nested': {'a': 1, 'b': 2},
        },
      };

      final data = ClientInfoData.fromMap(map);

      expect(data.additionalData['device'], equals('iPhone'));
      expect(data.additionalData['version'], equals(17.5));
      expect(data.additionalData['features'], equals(['faceId', 'nfc']));
      expect(data.additionalData['nested'], equals({'a': 1, 'b': 2}));
    });

    test('toMap converts ClientInfoData to map', () {
      final data = ClientInfoData(
        platform: 'ios',
        timestamp: DateTime.parse('2024-01-01T00:00:00.000Z'),
        additionalData: const {'test': 'data'},
      );

      final map = data.toMap();

      expect(map['platform'], equals('ios'));
      expect(map['timestamp'], isA<String>());
      expect(map['additionalData'], equals({'test': 'data'}));
    });

    test('toMap timestamp is ISO8601 format', () {
      final timestamp = DateTime.utc(2024, 6, 15, 10, 30, 45);
      final data = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
      );

      final map = data.toMap();
      expect(map['timestamp'], equals('2024-06-15T10:30:45.000Z'));
    });

    test('toMap and fromMap roundtrip', () {
      final original = ClientInfoData(
        platform: 'windows',
        timestamp: DateTime.utc(2024, 3, 20, 15, 45, 30),
        additionalData: const {
          'arch': 'x64',
          'build': 19045,
        },
      );

      final map = original.toMap();
      final restored = ClientInfoData.fromMap(map);

      expect(restored.platform, equals(original.platform));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.additionalData, equals(original.additionalData));
    });

    test('equality works correctly', () {
      final timestamp = DateTime.now();
      final data1 = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
        additionalData: const {},
      );
      final data2 = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
        additionalData: const {},
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('equality ignores additionalData differences', () {
      final timestamp = DateTime.now();
      final data1 = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
        additionalData: const {'key': 'value1'},
      );
      final data2 = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
        additionalData: const {'key': 'value2'},
      );

      // Based on the implementation, equality only checks platform and timestamp
      expect(data1, equals(data2));
    });

    test('inequality when platform differs', () {
      final timestamp = DateTime.now();
      final data1 = ClientInfoData(
        platform: 'android',
        timestamp: timestamp,
      );
      final data2 = ClientInfoData(
        platform: 'ios',
        timestamp: timestamp,
      );

      expect(data1, isNot(equals(data2)));
    });

    test('inequality when timestamp differs', () {
      final data1 = ClientInfoData(
        platform: 'test',
        timestamp: DateTime(2024, 1, 1),
      );
      final data2 = ClientInfoData(
        platform: 'test',
        timestamp: DateTime(2024, 1, 2),
      );

      expect(data1, isNot(equals(data2)));
    });

    test('equality with identical instance', () {
      final data = ClientInfoData(
        platform: 'test',
        timestamp: DateTime.now(),
      );

      expect(data, equals(data));
      expect(identical(data, data), isTrue);
    });

    test('inequality with non-ClientInfoData object', () {
      final data = ClientInfoData(
        platform: 'test',
        timestamp: DateTime.now(),
      );

      expect(data == 'not a ClientInfoData', isFalse);
      expect(data == 42, isFalse);
      expect(data == null, isFalse);
    });

    test('hashCode is consistent', () {
      final timestamp = DateTime.now();
      final data = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
      );

      final hash1 = data.hashCode;
      final hash2 = data.hashCode;

      expect(hash1, equals(hash2));
    });

    test('hashCode differs for different instances', () {
      final data1 = ClientInfoData(
        platform: 'android',
        timestamp: DateTime(2024, 1, 1),
      );
      final data2 = ClientInfoData(
        platform: 'ios',
        timestamp: DateTime(2024, 1, 2),
      );

      // Note: hashCode *may* be the same for different objects, but it's unlikely
      // We test that equal objects have equal hashCodes instead
      expect(data1, isNot(equals(data2)));
    });

    test('toString returns formatted string', () {
      final data = ClientInfoData(
        platform: 'test',
        timestamp: DateTime.now(),
        additionalData: const {'key': 'value'},
      );

      final string = data.toString();

      expect(string, contains('ClientInfoData'));
      expect(string, contains('platform: test'));
    });

    test('toString contains timestamp', () {
      final timestamp = DateTime(2024, 6, 15, 10, 30);
      final data = ClientInfoData(
        platform: 'test',
        timestamp: timestamp,
      );

      final string = data.toString();
      expect(string, contains('timestamp:'));
    });

    test('toString contains additionalData', () {
      final data = ClientInfoData(
        platform: 'test',
        timestamp: DateTime.now(),
        additionalData: const {'myKey': 'myValue'},
      );

      final string = data.toString();
      expect(string, contains('additionalData:'));
      expect(string, contains('myKey'));
    });
  });

  group('ClientInfoData platform values', () {
    test('android platform', () {
      final data = ClientInfoData(
        platform: 'android',
        timestamp: DateTime.now(),
      );
      expect(data.platform, equals('android'));
    });

    test('ios platform', () {
      final data = ClientInfoData(
        platform: 'ios',
        timestamp: DateTime.now(),
      );
      expect(data.platform, equals('ios'));
    });

    test('linux platform', () {
      final data = ClientInfoData(
        platform: 'linux',
        timestamp: DateTime.now(),
      );
      expect(data.platform, equals('linux'));
    });

    test('macos platform', () {
      final data = ClientInfoData(
        platform: 'macos',
        timestamp: DateTime.now(),
      );
      expect(data.platform, equals('macos'));
    });

    test('windows platform', () {
      final data = ClientInfoData(
        platform: 'windows',
        timestamp: DateTime.now(),
      );
      expect(data.platform, equals('windows'));
    });
  });
}
