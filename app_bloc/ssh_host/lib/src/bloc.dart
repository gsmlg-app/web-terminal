import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Re-export SshHost and SshIdentityType from app_database for convenience
export 'package:app_database/app_database.dart' show SshHost, SshIdentityType;

part 'event.dart';
part 'state.dart';

class SshHostBloc extends Bloc<SshHostEvent, SshHostState> {
  final AppDatabase database;

  SshHostBloc(this.database) : super(const SshHostInitial()) {
    on<SshHostLoad>((event, emit) async {
      final data = await database.select(database.sshHosts).get();
      emit(SshHostLoaded(data));
    });
    on<SshHostAdd>((event, emit) async {
      try {
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: Value(event.host),
                hostname: Value(event.hostname),
                port: Value(event.port),
                username: Value(event.username),
                password: Value(event.password),
                salt: Value(event.salt),
                identityType: Value(event.identityType),
                identityKeyId: Value(event.identityKeyId),
                createdAt: Value(DateTime.now()),
              ),
            );
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
      } catch (e) {
        emit(SshHostError(e));
      }
    });
    on<SshHostDelete>((event, emit) async {
      try {
        final rowsAffected = await (database.delete(database.sshHosts)
              ..where((t) => t.id.equals(event.sshHost.id)))
            .go();
        if (rowsAffected == 0) {
          throw Exception('Failed to delete ssh host');
        }
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
      } catch (e) {
        emit(SshHostError(e));
      }
    });
  }
}
