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
  String get destinationWebTerminal => 'Web Terminal';

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
  String get sshKeyImport => '파일에서 가져오기';

  @override
  String get sshKeyImportError =>
      '개인 키 파일을 읽을 수 없습니다. 비어 있지 않은 UTF-8 텍스트 파일을 선택하세요.';

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

  @override
  String get zmodemDownloads => 'Downloads (sz)';

  @override
  String get zmodemDownloadModeFolder => 'Save to folder';

  @override
  String get zmodemDownloadModeAsk => 'Ask where to save';

  @override
  String get zmodemDownloadFolder => 'Download folder';

  @override
  String get zmodemSystemDownloads => 'System Downloads';

  @override
  String get zmodemChooseFolder => 'Choose…';

  @override
  String get zmodemReset => 'Reset';

  @override
  String get zmodemCancel => 'Cancel';

  @override
  String zmodemSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String zmodemSavedFiles(int count, String folder) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count files to $folder',
      one: 'Saved 1 file to $folder',
    );
    return '$_temp0';
  }

  @override
  String zmodemUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uploaded $count files',
      one: 'Uploaded 1 file',
    );
    return '$_temp0';
  }

  @override
  String get zmodemCancelled => 'Transfer cancelled';

  @override
  String zmodemFailed(String reason) {
    return 'Transfer failed: $reason';
  }

  @override
  String get zmodemShowInFinder => 'Show in Finder';

  @override
  String zmodemFileOf(int index, int count) {
    return '$index of $count';
  }

  @override
  String get tabGroupSelected => 'Group selected tabs';
}
