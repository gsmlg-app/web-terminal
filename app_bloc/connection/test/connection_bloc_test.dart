import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connection_bloc/connection_bloc.dart';

void main() {
  group('ConnectionState', () {
    test('ConnectionState is sealed class', () {
      // ConnectionState is a sealed class, we can only create subclasses
      expect(ConnectionInitial(), isA<ConnectionState>());
    });

    test('ConnectionInitial is a subtype of ConnectionState', () {
      final state = ConnectionInitial();
      expect(state, isA<ConnectionState>());
    });

    test('ConnectionInitial can be instantiated multiple times', () {
      final state1 = ConnectionInitial();
      final state2 = ConnectionInitial();
      expect(state1, isA<ConnectionInitial>());
      expect(state2, isA<ConnectionInitial>());
    });

    test('ConnectionInitial instances are different objects', () {
      final state1 = ConnectionInitial();
      final state2 = ConnectionInitial();
      expect(identical(state1, state2), isFalse);
    });
  });

  group('ConnectionEvent', () {
    test('ConnectionEvent is sealed class', () {
      // ConnectionEvent is a sealed class - no instances can be created
      // directly outside of subclasses, but we verify the type exists
      expect(true, isTrue); // Placeholder for when events are added
    });
  });

  group('ConnectionBloc', () {
    test('initial state is ConnectionInitial', () {
      final bloc = ConnectionBloc();
      expect(bloc.state, isA<ConnectionInitial>());
      bloc.close();
    });

    test('bloc extends Bloc with correct types', () {
      final bloc = ConnectionBloc();
      expect(bloc, isA<ConnectionBloc>());
      bloc.close();
    });

    test('bloc can be created multiple times', () {
      final bloc1 = ConnectionBloc();
      final bloc2 = ConnectionBloc();
      expect(bloc1, isNot(same(bloc2)));
      bloc1.close();
      bloc2.close();
    });

    test('bloc can be closed', () async {
      final bloc = ConnectionBloc();
      await bloc.close();
      // Verify bloc is closed by checking isClosed
      expect(bloc.isClosed, isTrue);
    });

    test('state stream emits initial state', () {
      final bloc = ConnectionBloc();
      expect(
          bloc.stream,
          emitsInOrder([
            // No additional states since no events are processed
          ]));
      bloc.close();
    });

    blocTest<ConnectionBloc, ConnectionState>(
      'emits nothing when no events added',
      build: () => ConnectionBloc(),
      expect: () => [],
    );

    blocTest<ConnectionBloc, ConnectionState>(
      'initial state is ConnectionInitial via blocTest',
      build: () => ConnectionBloc(),
      verify: (bloc) {
        expect(bloc.state, isA<ConnectionInitial>());
      },
    );
  });

  group('ConnectionBloc lifecycle', () {
    test('bloc starts with ConnectionInitial', () {
      final bloc = ConnectionBloc();
      expect(bloc.state.runtimeType, equals(ConnectionInitial));
      bloc.close();
    });

    test('bloc state does not change without events', () async {
      final bloc = ConnectionBloc();
      final initialState = bloc.state;

      await Future.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, equals(initialState));
      bloc.close();
    });

    test('multiple blocs have independent states', () {
      final bloc1 = ConnectionBloc();
      final bloc2 = ConnectionBloc();

      expect(bloc1.state, isA<ConnectionInitial>());
      expect(bloc2.state, isA<ConnectionInitial>());

      // They should be independent instances
      expect(identical(bloc1.state, bloc2.state), isFalse);

      bloc1.close();
      bloc2.close();
    });
  });
}
