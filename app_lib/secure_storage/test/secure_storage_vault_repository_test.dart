import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of FlutterSecureStorage for testing.
class MockFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }

  // For test inspection
  Map<String, String> get rawStorage => _storage;

  // Not implemented methods (not used by SecureStorageVaultRepository)
  @override
  IOSOptions get iOptions => throw UnimplementedError();

  @override
  AndroidOptions get aOptions => throw UnimplementedError();

  @override
  LinuxOptions get lOptions => throw UnimplementedError();

  @override
  WebOptions get webOptions => throw UnimplementedError();

  @override
  MacOsOptions get mOptions => throw UnimplementedError();

  @override
  WindowsOptions get wOptions => throw UnimplementedError();

  @override
  Future<bool> isCupertinoProtectedDataAvailable() {
    throw UnimplementedError();
  }

  @override
  Stream<bool> get onCupertinoProtectedDataAvailabilityChanged {
    throw UnimplementedError();
  }

  @override
  void registerListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // Not implemented for testing
  }

  @override
  void unregisterListener({
    required String key,
    required void Function(String?) listener,
  }) {
    // Not implemented for testing
  }

  @override
  void unregisterAllListenersForKey({required String key}) {
    // Not implemented for testing
  }

  @override
  void unregisterAllListeners() {
    // Not implemented for testing
  }
}

void main() {
  group('SecureStorageVaultRepository', () {
    group('without namespace', () {
      late MockFlutterSecureStorage mockStorage;
      late SecureStorageVaultRepository repository;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        repository = SecureStorageVaultRepository(storage: mockStorage);
      });

      test('write stores value with exact key', () async {
        await repository.write(key: 'api_token', value: 'secret123');

        expect(mockStorage.rawStorage['api_token'], 'secret123');
      });

      test('read retrieves value with exact key', () async {
        mockStorage.rawStorage['password'] = 'hunter2';

        final result = await repository.read(key: 'password');

        expect(result, 'hunter2');
      });

      test('read returns null for non-existent key', () async {
        final result = await repository.read(key: 'missing');

        expect(result, isNull);
      });

      test('write overwrites existing value', () async {
        await repository.write(key: 'token', value: 'first');
        await repository.write(key: 'token', value: 'second');

        expect(mockStorage.rawStorage['token'], 'second');
      });

      test('delete removes value with exact key', () async {
        mockStorage.rawStorage['to_delete'] = 'value';

        await repository.delete(key: 'to_delete');

        expect(mockStorage.rawStorage.containsKey('to_delete'), isFalse);
      });

      test('delete does nothing for non-existent key', () async {
        await repository.delete(key: 'non_existent');

        // Should complete without error
        expect(true, isTrue);
      });

      test('containsKey returns true for existing key', () async {
        mockStorage.rawStorage['exists'] = 'value';

        final result = await repository.containsKey(key: 'exists');

        expect(result, isTrue);
      });

      test('containsKey returns false for non-existent key', () async {
        final result = await repository.containsKey(key: 'missing');

        expect(result, isFalse);
      });

      test('deleteAll clears all values', () async {
        mockStorage.rawStorage['key1'] = 'value1';
        mockStorage.rawStorage['key2'] = 'value2';

        await repository.deleteAll();

        expect(mockStorage.rawStorage, isEmpty);
      });

      test('readAll returns all stored values', () async {
        mockStorage.rawStorage['a'] = '1';
        mockStorage.rawStorage['b'] = '2';

        final result = await repository.readAll();

        expect(result, {'a': '1', 'b': '2'});
      });

      test('readAll returns empty map when storage is empty', () async {
        final result = await repository.readAll();

        expect(result, isEmpty);
      });
    });

    group('with namespace', () {
      late MockFlutterSecureStorage mockStorage;
      late SecureStorageVaultRepository repository;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        repository = SecureStorageVaultRepository(
          storage: mockStorage,
          namespace: 'myapp',
        );
      });

      test('write prefixes key with namespace', () async {
        await repository.write(key: 'token', value: 'secret');

        expect(mockStorage.rawStorage.containsKey('myapp_token'), isTrue);
        expect(mockStorage.rawStorage['myapp_token'], 'secret');
      });

      test('read uses prefixed key', () async {
        mockStorage.rawStorage['myapp_password'] = 'hunter2';

        final result = await repository.read(key: 'password');

        expect(result, 'hunter2');
      });

      test('read returns null if non-prefixed key exists', () async {
        mockStorage.rawStorage['password'] = 'direct_value';

        final result = await repository.read(key: 'password');

        expect(result, isNull);
      });

      test('delete uses prefixed key', () async {
        mockStorage.rawStorage['myapp_to_delete'] = 'value';

        await repository.delete(key: 'to_delete');

        expect(mockStorage.rawStorage.containsKey('myapp_to_delete'), isFalse);
      });

      test('delete does not remove non-prefixed key', () async {
        mockStorage.rawStorage['to_delete'] = 'value';

        await repository.delete(key: 'to_delete');

        // Non-prefixed key should still exist
        expect(mockStorage.rawStorage.containsKey('to_delete'), isTrue);
      });

      test('containsKey uses prefixed key', () async {
        mockStorage.rawStorage['myapp_exists'] = 'value';

        final result = await repository.containsKey(key: 'exists');

        expect(result, isTrue);
      });

      test(
        'containsKey returns false if only non-prefixed key exists',
        () async {
          mockStorage.rawStorage['exists'] = 'value';

          final result = await repository.containsKey(key: 'exists');

          expect(result, isFalse);
        },
      );

      test('deleteAll only removes keys with namespace prefix', () async {
        mockStorage.rawStorage['myapp_key1'] = 'value1';
        mockStorage.rawStorage['myapp_key2'] = 'value2';
        mockStorage.rawStorage['other_key'] = 'other_value';
        mockStorage.rawStorage['unprefixed'] = 'direct';

        await repository.deleteAll();

        expect(mockStorage.rawStorage.containsKey('myapp_key1'), isFalse);
        expect(mockStorage.rawStorage.containsKey('myapp_key2'), isFalse);
        expect(mockStorage.rawStorage['other_key'], 'other_value');
        expect(mockStorage.rawStorage['unprefixed'], 'direct');
      });

      test('readAll only returns keys with namespace prefix', () async {
        mockStorage.rawStorage['myapp_a'] = '1';
        mockStorage.rawStorage['myapp_b'] = '2';
        mockStorage.rawStorage['other_c'] = '3';
        mockStorage.rawStorage['d'] = '4';

        final result = await repository.readAll();

        expect(result, {'a': '1', 'b': '2'});
      });

      test('readAll strips namespace prefix from returned keys', () async {
        mockStorage.rawStorage['myapp_user_token'] = 'token_value';

        final result = await repository.readAll();

        expect(result.containsKey('user_token'), isTrue);
        expect(result.containsKey('myapp_user_token'), isFalse);
      });

      test('readAll returns empty map when no namespaced keys exist', () async {
        mockStorage.rawStorage['other_key'] = 'value';

        final result = await repository.readAll();

        expect(result, isEmpty);
      });
    });

    group('with empty namespace', () {
      late MockFlutterSecureStorage mockStorage;
      late SecureStorageVaultRepository repository;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        repository = SecureStorageVaultRepository(
          storage: mockStorage,
          namespace: '', // Empty string namespace
        );
      });

      test('empty namespace acts like no namespace', () async {
        await repository.write(key: 'token', value: 'secret');

        // Should use exact key, not prefix with empty string
        expect(mockStorage.rawStorage.containsKey('token'), isTrue);
        expect(mockStorage.rawStorage.containsKey('_token'), isFalse);
      });

      test('deleteAll clears all values with empty namespace', () async {
        mockStorage.rawStorage['key1'] = 'value1';
        mockStorage.rawStorage['key2'] = 'value2';

        await repository.deleteAll();

        expect(mockStorage.rawStorage, isEmpty);
      });
    });

    group('constructor', () {
      test('creates with default storage when not provided', () {
        final repository = SecureStorageVaultRepository();

        // Should not throw
        expect(repository, isNotNull);
      });

      test('creates with custom storage', () {
        final mockStorage = MockFlutterSecureStorage();
        final repository = SecureStorageVaultRepository(storage: mockStorage);

        expect(repository, isNotNull);
      });

      test('creates with namespace', () {
        final repository = SecureStorageVaultRepository(namespace: 'test');

        expect(repository, isNotNull);
      });

      test('namespace is accessible', () {
        final repository = SecureStorageVaultRepository(namespace: 'myns');

        expect(repository.namespace, 'myns');
      });

      test('namespace defaults to null', () {
        final repository = SecureStorageVaultRepository();

        expect(repository.namespace, isNull);
      });
    });

    group('special characters in keys', () {
      late MockFlutterSecureStorage mockStorage;
      late SecureStorageVaultRepository repository;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        repository = SecureStorageVaultRepository(storage: mockStorage);
      });

      test('handles keys with dots', () async {
        await repository.write(key: 'config.api.key', value: 'secret');

        final result = await repository.read(key: 'config.api.key');
        expect(result, 'secret');
      });

      test('handles keys with underscores', () async {
        await repository.write(key: 'user_access_token', value: 'token');

        final result = await repository.read(key: 'user_access_token');
        expect(result, 'token');
      });

      test('handles keys with hyphens', () async {
        await repository.write(key: 'api-key-v2', value: 'key');

        final result = await repository.read(key: 'api-key-v2');
        expect(result, 'key');
      });
    });

    group('special characters in values', () {
      late MockFlutterSecureStorage mockStorage;
      late SecureStorageVaultRepository repository;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        repository = SecureStorageVaultRepository(storage: mockStorage);
      });

      test('handles unicode values', () async {
        await repository.write(key: 'name', value: '日本語テスト');

        final result = await repository.read(key: 'name');
        expect(result, '日本語テスト');
      });

      test('handles emoji values', () async {
        await repository.write(key: 'icon', value: '🔐🔑');

        final result = await repository.read(key: 'icon');
        expect(result, '🔐🔑');
      });

      test('handles multiline values', () async {
        const multiline = 'line1\nline2\nline3';
        await repository.write(key: 'cert', value: multiline);

        final result = await repository.read(key: 'cert');
        expect(result, multiline);
      });

      test('handles very long values', () async {
        final longValue = 'x' * 10000;
        await repository.write(key: 'long', value: longValue);

        final result = await repository.read(key: 'long');
        expect(result, longValue);
      });

      test('handles JSON values', () async {
        const json = '{"token":"abc123","expires":1234567890}';
        await repository.write(key: 'auth', value: json);

        final result = await repository.read(key: 'auth');
        expect(result, json);
      });
    });

    group('multiple namespaces', () {
      late MockFlutterSecureStorage sharedStorage;

      setUp(() {
        sharedStorage = MockFlutterSecureStorage();
      });

      test('different namespaces have isolated storage', () async {
        final repo1 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app1',
        );
        final repo2 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app2',
        );

        await repo1.write(key: 'token', value: 'token1');
        await repo2.write(key: 'token', value: 'token2');

        expect(await repo1.read(key: 'token'), 'token1');
        expect(await repo2.read(key: 'token'), 'token2');
      });

      test('deleteAll in one namespace does not affect another', () async {
        final repo1 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app1',
        );
        final repo2 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app2',
        );

        await repo1.write(key: 'data', value: 'data1');
        await repo2.write(key: 'data', value: 'data2');

        await repo1.deleteAll();

        expect(await repo1.read(key: 'data'), isNull);
        expect(await repo2.read(key: 'data'), 'data2');
      });

      test('readAll only returns own namespace keys', () async {
        final repo1 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app1',
        );
        final repo2 = SecureStorageVaultRepository(
          storage: sharedStorage,
          namespace: 'app2',
        );

        await repo1.write(key: 'a', value: '1');
        await repo1.write(key: 'b', value: '2');
        await repo2.write(key: 'c', value: '3');

        final all1 = await repo1.readAll();
        final all2 = await repo2.readAll();

        expect(all1, {'a': '1', 'b': '2'});
        expect(all2, {'c': '3'});
      });
    });

    group('implements VaultRepository interface', () {
      test('SecureStorageVaultRepository is a VaultRepository', () {
        final repository = SecureStorageVaultRepository();

        expect(repository, isA<VaultRepository>());
      });

      test('all interface methods are implemented', () async {
        final mockStorage = MockFlutterSecureStorage();
        final VaultRepository repository = SecureStorageVaultRepository(
          storage: mockStorage,
        );

        // All these should complete without error
        await repository.write(key: 'k', value: 'v');
        await repository.read(key: 'k');
        await repository.delete(key: 'k');
        await repository.containsKey(key: 'k');
        await repository.readAll();
        await repository.deleteAll();

        expect(true, isTrue);
      });
    });
  });
}
