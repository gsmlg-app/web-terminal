import 'package:flutter_test/flutter_test.dart';
import 'package:connection_bloc/connection_bloc.dart';

void main() {
  group('ConnectionBloc', () {
    test('initial state is ConnectionInitial', () {
      final bloc = ConnectionBloc();
      expect(bloc.state, isA<ConnectionInitial>());
      bloc.close();
    });
  });
}
