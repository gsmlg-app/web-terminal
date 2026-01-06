part of 'ssh_host_bloc.dart';

@immutable
sealed class SshHostEvent {}

class SshHostLoad extends SshHostEvent {}

class SshHostDelete extends SshHostEvent {
  final SshHost sshHost;

  SshHostDelete(this.sshHost);
}
