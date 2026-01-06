part of 'bloc.dart';

@immutable
sealed class SshKeyState {}

final class SshKeyInitial extends SshKeyState {}

final class SshKeyLoaded extends SshKeyState {
  final List<SshKey> sshKeys;

  SshKeyLoaded(this.sshKeys);
}

final class SshKeyError extends SshKeyState {
  final Object error;

  SshKeyError(this.error);
}
