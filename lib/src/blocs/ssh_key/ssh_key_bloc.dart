import 'package:form_bloc/form_bloc.dart';
import 'package:gsmlg_security/gsmlg_security.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';
import 'package:web_terminal/constant.dart';
import 'package:web_terminal/object/ssh_key.dart';
import 'package:web_terminal/objectbox_api.dart';

part 'ssh_key_event.dart';
part 'ssh_key_form.dart';
part 'ssh_key_state.dart';

class SshKeyBloc extends Bloc<SshKeyEvent, SshKeyState> {
  final ObjectBox objectBox;

  SshKeyBloc(this.objectBox) : super(SshKeyInitial()) {
    on<SshKeyLoad>((event, emit) {
      Box<SshKey> hostBox = objectBox.store.box<SshKey>();
      final data = hostBox.getAll();
      emit(SshKeyLoaded(data));
    });
    on<SshKeyDelete>((event, emit) async {
      try {
        final Box<SshKey> hostBox = objectBox.store.box<SshKey>();
        final r = hostBox.remove(event.sshKey.id);
        if (!r) {
          throw Exception('Failed to delete ssh key');
        }
        final data = hostBox.getAll();
        emit(SshKeyLoaded(data));
      } catch (e) {
        emit(SshKeyError(e));
      }
    });
  }
}
