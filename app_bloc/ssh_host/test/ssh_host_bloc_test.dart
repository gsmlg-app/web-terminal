import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';

void main() {
  group('SshHostBloc', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    test('SshIdentityType enum values', () {
      expect(SshIdentityType.password.value, 1);
      expect(SshIdentityType.key.value, 2);
      expect(SshIdentityType.fromValue(1), SshIdentityType.password);
      expect(SshIdentityType.fromValue(2), SshIdentityType.key);
    });

    test('SshHostBloc initial state is SshHostInitial', () {
      final bloc = SshHostBloc(database);
      expect(bloc.state, isA<SshHostInitial>());
    });

    test('SshHostBloc emits SshHostLoaded on SshHostLoad', () async {
      final bloc = SshHostBloc(database);
      bloc.add(SshHostLoad());
      await expectLater(
        bloc.stream,
        emits(isA<SshHostLoaded>()),
      );
    });
  });
}
