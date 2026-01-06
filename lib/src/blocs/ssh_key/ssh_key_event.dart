part of 'ssh_key_bloc.dart';

@immutable
sealed class SshKeyEvent {}

class SshKeyLoad extends SshKeyEvent {}

class SshKeyDelete extends SshKeyEvent {
  final SshKey sshKey;

  SshKeyDelete(this.sshKey);
}
