import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';

void main() {
  group('SshKeyBloc', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    test('SshKeyAlgorithm enum values', () {
      expect(SshKeyAlgorithm.rsa.value, 1);
      expect(SshKeyAlgorithm.dsa.value, 2);
      expect(SshKeyAlgorithm.ecdsa.value, 3);
      expect(SshKeyAlgorithm.ed25519.value, 4);
      expect(SshKeyAlgorithm.fromValue(1), SshKeyAlgorithm.rsa);
      expect(SshKeyAlgorithm.fromValue(4), SshKeyAlgorithm.ed25519);
    });

    test('SshKeyBloc initial state is SshKeyInitial', () {
      final bloc = SshKeyBloc(database);
      expect(bloc.state, isA<SshKeyInitial>());
    });

    test('SshKeyBloc emits SshKeyLoaded on SshKeyLoad', () async {
      final bloc = SshKeyBloc(database);
      bloc.add(SshKeyLoad());
      await expectLater(
        bloc.stream,
        emits(isA<SshKeyLoaded>()),
      );
    });
  });
}
