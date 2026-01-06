part of 'ssh_host_bloc.dart';

@immutable
sealed class SshHostState {}

final class SshHostInitial extends SshHostState {}

final class SshHostLoaded extends SshHostState {
  final List<SshHost> sshHosts;

  SshHostLoaded(this.sshHosts);
}

final class SshHostError extends SshHostState {
  final Object error;

  SshHostError(this.error);
}
