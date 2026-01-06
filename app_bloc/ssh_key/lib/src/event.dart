part of 'bloc.dart';

@immutable
sealed class SshKeyEvent {}

class SshKeyLoad extends SshKeyEvent {}

class SshKeyAdd extends SshKeyEvent {
  final String? name;
  final String? content;
  final String? password;
  final String? salt;
  final int? algorithm;

  SshKeyAdd({
    this.name,
    this.content,
    this.password,
    this.salt,
    this.algorithm,
  });
}

class SshKeyDelete extends SshKeyEvent {
  final SshKey sshKey;

  SshKeyDelete(this.sshKey);
}
