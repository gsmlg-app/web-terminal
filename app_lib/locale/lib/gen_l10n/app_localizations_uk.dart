// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Виконавець Ansible Semaphore';

  @override
  String get show => 'Показати';

  @override
  String get hide => 'Приховати';

  @override
  String get exit => 'Вийти';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Редагувати';

  @override
  String get delete => 'Видалити';

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
  String get destinationWebTerminal => 'Web Terminal';

  @override
  String get destinationSetting => 'Налаштування';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get smenuTheme => 'Тема';

  @override
  String get titleSelectAppearance => 'Виберіть зовнішній вигляд';

  @override
  String get titleSelectColorTheme => 'Виберіть колір акценту';

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
  String get sshKeyImport => 'Імпортувати з файлу';

  @override
  String get sshKeyImportError =>
      'Не вдалося прочитати файл приватного ключа. Виберіть непорожній текстовий файл у кодуванні UTF-8.';

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
  String get undo => 'Скасувати';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get sshHostKeyTitle => 'Trust SSH host key?';

  @override
  String get sshHostKeyTrust => 'Trust and connect';

  @override
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint) {
    return 'The identity of $hostname:$port is not yet trusted.\n\n$type\n$fingerprint\n\nCompare this fingerprint with the server administrator before trusting it.';
  }

  @override
  String get optionKeyBehavior => 'Option Key Behavior';

  @override
  String get optionKeyBehaviorLeftMeta => 'Left Meta';

  @override
  String get optionKeyBehaviorBothMeta => 'Both Meta';

  @override
  String get optionKeyBehaviorNormal => 'Normal';

  @override
  String get optionKeyBehaviorDescription =>
      'Meta sends Esc + key. Normal types special characters.';

  @override
  String get closeTabConfirmTitle => 'Close Tab?';

  @override
  String closeTabConfirmMessage(String title) {
    return '\"$title\" has a running program. Closing the tab will terminate it.';
  }

  @override
  String get quitConfirmTitle => 'Quit Web Terminal?';

  @override
  String quitConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs have running programs:',
      one: '1 tab has a running program:',
    );
    return '$_temp0\n$titles\n\nQuitting will terminate them.';
  }

  @override
  String get quit => 'Quit';

  @override
  String get tabGroupUngrouped => 'Ungrouped';

  @override
  String get tabGroupMoveTo => 'Move to group';

  @override
  String get tabGroupNew => 'New group…';

  @override
  String get tabGroupRemove => 'Remove from group';

  @override
  String get tabGroupRename => 'Rename group…';

  @override
  String get tabGroupClose => 'Close group';

  @override
  String get tabGroupNameHint => 'Group name';

  @override
  String get tabRename => 'Rename…';

  @override
  String get tabGroupCloseConfirmTitle => 'Close Group?';

  @override
  String tabGroupCloseConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs in this group have running programs:',
      one: '1 tab in this group has a running program:',
    );
    return '$_temp0\n$titles\n\nClosing the group will terminate them.';
  }
}
