part of 'bloc.dart';

@immutable
sealed class SshHostEvent extends Equatable {
  const SshHostEvent();

  @override
  List<Object?> get props => [];
}

class SshHostLoad extends SshHostEvent {}

class SshHostAdd extends SshHostEvent {
  final String? host;
  final String? hostname;
  final int? port;
  final String? username;
  final String? password;
  final String? salt;
  final int? identityType;
  final int? identityKeyId;

  SshHostAdd({
    this.host,
    this.hostname,
    this.port,
    this.username,
    this.password,
    this.salt,
    this.identityType,
    this.identityKeyId,
  });

  @override
  List<Object?> get props => [
        host,
        hostname,
        port,
        username,
        password,
        salt,
        identityType,
        identityKeyId,
      ];
}

class SshHostDelete extends SshHostEvent {
  final SshHost sshHost;

  SshHostDelete(this.sshHost);

  @override
  List<Object?> get props => [sshHost];
}
