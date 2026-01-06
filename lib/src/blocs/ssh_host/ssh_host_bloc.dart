import 'package:form_bloc/form_bloc.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';
import 'package:web_terminal/object/ssh_host.dart';
import 'package:web_terminal/object/ssh_key.dart';
import 'package:web_terminal/objectbox_api.dart';

part 'ssh_host_event.dart';
part 'ssh_host_form.dart';
part 'ssh_host_state.dart';

class SshHostBloc extends Bloc<SshHostEvent, SshHostState> {
  final ObjectBox objectBox;

  SshHostBloc(this.objectBox) : super(SshHostInitial()) {
    on<SshHostLoad>((event, emit) async {
      Box<SshHost> hostBox = objectBox.store.box<SshHost>();
      final data = hostBox.getAll();
      emit(SshHostLoaded(data));
    });
    on<SshHostDelete>((event, emit) async {
      try {
        Box<SshHost> hostBox = objectBox.store.box<SshHost>();
        final r = await hostBox.removeAsync(event.sshHost.id);
        if (r == false) {
          throw Exception('Failed to delete ssh host');
        }
        final data = hostBox.getAll();
        emit(SshHostLoaded(data));
      } catch (e) {
        emit(SshHostError(e));
      }
    });
  }
}
