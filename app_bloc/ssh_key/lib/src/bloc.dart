import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

/// Re-export SshKey from app_database for convenience
export 'package:app_database/app_database.dart' show SshKey, SshKeyAlgorithm;

/// Re-export extensions for encryption functionality
export 'ssh_key_extensions.dart';

part 'event.dart';
part 'state.dart';

class SshKeyBloc extends Bloc<SshKeyEvent, SshKeyState> {
  final AppDatabase database;

  SshKeyBloc(this.database) : super(SshKeyInitial()) {
    on<SshKeyLoad>((event, emit) async {
      final data = await database.select(database.sshKeys).get();
      emit(SshKeyLoaded(data));
    });
    on<SshKeyAdd>((event, emit) async {
      try {
        await database.into(database.sshKeys).insert(
              SshKeysCompanion.insert(
                name: Value(event.name),
                content: Value(event.content),
                password: Value(event.password),
                salt: Value(event.salt),
                algorithm: Value(event.algorithm),
                createdAt: Value(DateTime.now()),
              ),
            );
        final data = await database.select(database.sshKeys).get();
        emit(SshKeyLoaded(data));
      } catch (e) {
        emit(SshKeyError(e));
      }
    });
    on<SshKeyDelete>((event, emit) async {
      try {
        final rowsAffected = await (database.delete(database.sshKeys)
              ..where((t) => t.id.equals(event.sshKey.id)))
            .go();
        if (rowsAffected == 0) {
          throw Exception('Failed to delete ssh key');
        }
        final data = await database.select(database.sshKeys).get();
        emit(SshKeyLoaded(data));
      } catch (e) {
        emit(SshKeyError(e));
      }
    });
  }
}
