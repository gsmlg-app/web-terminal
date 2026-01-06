// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Ansible Semaphore 실행기';

  @override
  String get show => '보이기';

  @override
  String get hide => '숨기기';

  @override
  String get exit => '종료';

  @override
  String get add => 'Add';

  @override
  String get edit => '편집';

  @override
  String get delete => '삭제';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get reload => 'Reload';

  @override
  String get copy => 'Copy';

  @override
  String get destinationTerminal => 'Terminal';

  @override
  String get destinationSetting => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get smenuTheme => '테마';

  @override
  String get titleSelectAppearance => '모양 선택';

  @override
  String get titleSelectColorTheme => '색상 테마 선택';

  @override
  String get smenuSSH => 'SSH';

  @override
  String get sshHost => 'Host';

  @override
  String get titleSSHHost => 'SSH Host';

  @override
  String get addSshHost => 'Add SSH Host';

  @override
  String get editSshHost => 'Edit SSH Host';

  @override
  String get sshKey => 'SSH Key';

  @override
  String get titleSSHKey => 'SSH Key';

  @override
  String get addSshKey => 'Add SSH Key';

  @override
  String get showPublicKey => 'Show Public Key';

  @override
  String get sshKeyNameLabel => 'Name';

  @override
  String get sshKeyNameHint => 'Name of your SSH Key';

  @override
  String get sshKeyContentLabel => 'Key Content';

  @override
  String get sshKeyGenerate => 'Generate SSH Key';

  @override
  String get deleteSshKeyMessage =>
      'Are you sure you want to delete this SSH Key?';

  @override
  String get publicKey => 'Public Key';

  @override
  String get sshHostHostLabel => 'Host';

  @override
  String get sshHostHostnameLabel => 'Hostname';

  @override
  String get sshHostPortLabel => 'Port';

  @override
  String get sshHostUsernameLabel => 'Username';

  @override
  String get sshHostIdentifyTypeLabel => 'Identify Type';

  @override
  String get sshHostIdentityTypePassword => 'Password';

  @override
  String get sshHostIdentityTypePrivateKey => 'Private Key';

  @override
  String get sshHostPasswordLabel => 'Password';

  @override
  String get sshHostPrivateKeyLabel => 'Private Key';

  @override
  String get deleteSshHostMessage =>
      'Are you sure you want to delete this SSH Host?';

  @override
  String get retry => 'Retry';

  @override
  String get undo => '실행 취소';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';
}
