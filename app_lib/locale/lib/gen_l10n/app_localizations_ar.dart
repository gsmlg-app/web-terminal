// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Ansible Semaphore Runner';

  @override
  String get show => 'عرض';

  @override
  String get hide => 'إخفاء';

  @override
  String get exit => 'خروج';

  @override
  String get add => 'Add';

  @override
  String get edit => 'تحرير';

  @override
  String get delete => 'حذف';

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
  String get destinationSetting => 'إعداد';

  @override
  String get settingsTitle => 'إعداد';

  @override
  String get smenuTheme => 'مظهر';

  @override
  String get titleSelectAppearance => 'اختر المظهر';

  @override
  String get titleSelectColorTheme => 'اختر لون التمييز';

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
  String get sshKeyImport => 'استيراد من ملف';

  @override
  String get sshKeyImportError =>
      'تعذرت قراءة ملف المفتاح الخاص. اختر ملفًا نصيًا غير فارغ بترميز UTF-8.';

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
  String get undo => 'تراجع';

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

  @override
  String get sessionSnapshots => 'Saved Tabs and History';

  @override
  String get sessionSaveWorkspace => 'Save Workspace';

  @override
  String get sessionSaveGroup => 'Save Group';

  @override
  String get sessionRestore => 'Restore';

  @override
  String get sessionReplace => 'Replace';

  @override
  String get sessionAppend => 'Append';

  @override
  String get sessionRestorePrompt => 'Restore tabs from your last session?';

  @override
  String get sessionLater => 'Later';

  @override
  String get sessionExitHistory => 'Recent Exits';

  @override
  String get sessionRecovery => 'Crash Recovery';

  @override
  String get sessionManualSaved => 'Manually Saved';

  @override
  String get sessionNoSnapshots => 'No saved sessions yet.';

  @override
  String get sessionSnapshotName => 'Name';

  @override
  String get sessionTargetGroup => 'Target group';

  @override
  String get sessionNewGroup => 'New group';

  @override
  String get sessionRestoreDescription =>
      'Restoration opens new sessions without previous output. Replace closes the selected group, or all tabs for a workspace.';

  @override
  String get sessionUnavailable =>
      'This tab could not be restored. Its configuration is preserved.';

  @override
  String get sessionDirectory => 'Working directory';

  @override
  String get sessionProfile => 'Shell profile';

  @override
  String get sessionHost => 'SSH host';

  @override
  String get sessionPersistenceError =>
      'Tabs could not be saved. Check storage access and retry.';

  @override
  String get sessionDeleteConfirm => 'Delete this saved session?';

  @override
  String get sessionSaved => 'Session saved';

  @override
  String get sessionStorageUnavailable =>
      'Session storage could not be opened. Existing files have been preserved.';

  @override
  String get sessionSecureStorageUnavailable =>
      'Credentials could not be read. Unlock or repair secure storage, then retry.';

  @override
  String get sessionRestoreFailed => 'Restore failed';

  @override
  String sessionDetails(int tabs, int groups) {
    return '$tabs tabs · $groups groups';
  }

  @override
  String get sessionMissingProfile => 'The saved shell profile is unavailable.';

  @override
  String get sessionMissingHost => 'The saved SSH host is unavailable.';

  @override
  String get sessionMissingDirectory =>
      'The saved working directory does not exist.';

  @override
  String get sessionSaveEmpty => 'There are no tabs to save.';

  @override
  String get sessionPreferenceError =>
      'Settings could not be saved. Check storage access and retry.';

  @override
  String get remoteClipboardAllow => 'Allow remote clipboard writes';

  @override
  String get remoteClipboardDescription =>
      'Allow trusted sessions to replace your clipboard. Also trust each session in its clipboard menu. Remote clipboard reads are always denied.';

  @override
  String get remoteClipboardTrust => 'Trust this session for clipboard writes';

  @override
  String get remoteClipboardRevoke => 'Revoke this session\'s clipboard access';

  @override
  String get remoteClipboardEnableFirst =>
      'Enable remote clipboard writes in Terminal settings first.';

  @override
  String get terminalClipboardActions => 'Terminal clipboard and selection';

  @override
  String get terminalSelectText => 'Select text (pause mouse reporting)';

  @override
  String get terminalMouseInteraction => 'Resume application mouse interaction';
}
