// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'web_terminal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class WebTerminalLocalizationsJa extends WebTerminalLocalizations {
  WebTerminalLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Ansible Semaphore ランナー';

  @override
  String get show => '表示';

  @override
  String get hide => '非表示';

  @override
  String get exit => '終了';

  @override
  String get add => 'Add';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

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
  String get destinationSetting => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get smenuTheme => 'テーマ';

  @override
  String get titleSelectAppearance => '外観を選択';

  @override
  String get titleSelectColorTheme => 'アクセントカラーを選択';

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
}
