import 'package:app_client_info_platform_interface/app_client_info_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock implementation for testing
class MockClientInfoPlatform extends ClientInfoPlatform
    with MockPlatformInterfaceMixin {
  Map<String, dynamic>? mockData;
  bool refreshCalled = false;

  @override
  Future<Map<String, dynamic>> getData() async {
    if (mockData == null) {
      throw UnimplementedError('Mock data not set');
    }
    return mockData!;
  }

  @override
  Future<void> refresh() async {
    refreshCalled = true;
  }
}

// Test implementation that doesn't use token verification
class TestClientInfoPlatform extends ClientInfoPlatform {
  TestClientInfoPlatform() : super();

  @override
  Future<Map<String, dynamic>> getData() async {
    return {'test': 'data'};
  }

  @override
  Future<void> refresh() async {
    // No-op
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClientInfoPlatform', () {
    test('default instance is MethodChannelClientInfo', () {
      expect(ClientInfoPlatform.instance, isA<MethodChannelClientInfo>());
    });

    test('can set instance with mock', () {
      final mock = MockClientInfoPlatform();
      ClientInfoPlatform.instance = mock;
      expect(ClientInfoPlatform.instance, same(mock));

      // Reset to default
      ClientInfoPlatform.instance = MethodChannelClientInfo();
    });

    test('getData throws UnimplementedError on base class', () {
      // Create a minimal implementation that doesn't override getData
      final platform = _BaseClientInfoPlatform();
      expect(
        () => platform.getData(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('refresh throws UnimplementedError on base class', () {
      final platform = _BaseClientInfoPlatform();
      expect(
        () => platform.refresh(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('MockClientInfoPlatform', () {
    test('getData returns mock data when set', () async {
      final mock = MockClientInfoPlatform();
      mock.mockData = {'key': 'value', 'count': 42};

      final result = await mock.getData();

      expect(result, equals({'key': 'value', 'count': 42}));
    });

    test('getData throws when mock data not set', () {
      final mock = MockClientInfoPlatform();

      expect(
        () => mock.getData(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('refresh sets flag', () async {
      final mock = MockClientInfoPlatform();
      expect(mock.refreshCalled, isFalse);

      await mock.refresh();

      expect(mock.refreshCalled, isTrue);
    });

    test('can be set as platform instance', () {
      final mock = MockClientInfoPlatform();
      ClientInfoPlatform.instance = mock;

      expect(ClientInfoPlatform.instance, isA<MockClientInfoPlatform>());

      // Reset
      ClientInfoPlatform.instance = MethodChannelClientInfo();
    });
  });

  group('MethodChannelClientInfo', () {
    test('is a ClientInfoPlatform', () {
      final channel = MethodChannelClientInfo();
      expect(channel, isA<ClientInfoPlatform>());
    });

    test('has methodChannel property', () {
      final channel = MethodChannelClientInfo();
      expect(channel.methodChannel.name, equals('app_client_info'));
    });

    test('can be instantiated multiple times', () {
      final channel1 = MethodChannelClientInfo();
      final channel2 = MethodChannelClientInfo();

      expect(channel1, isNot(same(channel2)));
      expect(channel1.methodChannel.name, equals(channel2.methodChannel.name));
    });
  });

  group('Platform interface token verification', () {
    test('mock with MockPlatformInterfaceMixin can be set as instance', () {
      final mock = MockClientInfoPlatform();

      // This should not throw because MockPlatformInterfaceMixin bypasses verification
      expect(() => ClientInfoPlatform.instance = mock, returnsNormally);

      // Reset
      ClientInfoPlatform.instance = MethodChannelClientInfo();
    });
  });

  group('ClientInfoPlatform inheritance', () {
    test('extends PlatformInterface', () {
      expect(ClientInfoPlatform.instance, isA<PlatformInterface>());
    });

    test('MethodChannelClientInfo extends ClientInfoPlatform', () {
      expect(MethodChannelClientInfo(), isA<ClientInfoPlatform>());
    });
  });
}

// Helper class for testing base implementation
class _BaseClientInfoPlatform extends ClientInfoPlatform
    with MockPlatformInterfaceMixin {
  // Don't override getData or refresh to test base class behavior
}
