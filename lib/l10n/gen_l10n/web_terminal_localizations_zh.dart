// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'web_terminal_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class WebTerminalLocalizationsZh extends WebTerminalLocalizations {
  WebTerminalLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Ansible Semaphore 运行器';

  @override
  String get show => '显示';

  @override
  String get hide => '隐藏';

  @override
  String get exit => '退出';

  @override
  String get add => 'Add';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

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
  String get destinationSetting => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get smenuTheme => '主题';

  @override
  String get titleSelectAppearance => '选择外观';

  @override
  String get titleSelectColorTheme => '选择主题色';

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

/// The translations for Chinese, using the Han script (`zh_Hans`).
class WebTerminalLocalizationsZhHans extends WebTerminalLocalizationsZh {
  WebTerminalLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => 'Ansible Semaphore 运行器';

  @override
  String get show => '显示';

  @override
  String get hide => '隐藏';

  @override
  String get exit => '退出';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get destinationSetting => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get smenuTheme => '主题';

  @override
  String get titleSelectAppearance => '选择外观';

  @override
  String get titleSelectColorTheme => '选择强调色';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class WebTerminalLocalizationsZhHant extends WebTerminalLocalizationsZh {
  WebTerminalLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Ansible Semaphore 執行器';

  @override
  String get show => '顯示';

  @override
  String get hide => '隱藏';

  @override
  String get exit => '退出';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get destinationSetting => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get smenuTheme => '主題';

  @override
  String get titleSelectAppearance => '選擇外觀';

  @override
  String get titleSelectColorTheme => '選擇強調顏色';
}
