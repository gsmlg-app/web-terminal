// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Web Terminal';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get exit => 'Exit';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

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
  String get destinationSetting => 'Setting';

  @override
  String get settingsTitle => 'Setting';

  @override
  String get smenuTheme => 'Theme';

  @override
  String get titleSelectAppearance => 'Select Appearance';

  @override
  String get titleSelectColorTheme => 'Select Accent Color';

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
  String get sshKeyImport => 'Import from file';

  @override
  String get sshKeyImportError =>
      'Unable to read the private key file. Choose a non-empty UTF-8 text file.';

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
  String get undo => 'Undo';

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
  String zmodemSkippedExisting(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count files already exist on the remote and were skipped (run rz -y to overwrite)',
      one:
          '$name already exists on the remote and was skipped (run rz -y to overwrite)',
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
