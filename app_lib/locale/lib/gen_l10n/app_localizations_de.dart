// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Ansible Semaphore Runner';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get exit => 'Beenden';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

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
  String get destinationSetting => 'Einstellung';

  @override
  String get settingsTitle => 'Einstellung';

  @override
  String get smenuTheme => 'Thema';

  @override
  String get titleSelectAppearance => 'Erscheinungsbild auswählen';

  @override
  String get titleSelectColorTheme => 'Akzentfarbe auswählen';

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
  String get sshKeyImport => 'Aus Datei importieren';

  @override
  String get sshKeyImportError =>
      'Die Datei mit dem privaten Schlüssel konnte nicht gelesen werden. Wählen Sie eine nicht leere UTF-8-Textdatei aus.';

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
  String get undo => 'Rückgängig machen';

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
  String get optionKeyBehavior => 'Verhalten der Wahltaste';

  @override
  String get optionKeyBehaviorLeftMeta => 'Links Meta';

  @override
  String get optionKeyBehaviorBothMeta => 'Beide Meta';

  @override
  String get optionKeyBehaviorNormal => 'Normal';

  @override
  String get optionKeyBehaviorDescription =>
      'Meta sendet Esc + Taste. Normal gibt Sonderzeichen ein.';

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
  String get tabGroupUngrouped => 'Ohne Gruppe';

  @override
  String get tabGroupMoveTo => 'In Gruppe verschieben';

  @override
  String get tabGroupNew => 'Neue Gruppe…';

  @override
  String get tabGroupRemove => 'Aus Gruppe entfernen';

  @override
  String get tabGroupRename => 'Gruppe umbenennen…';

  @override
  String get tabGroupClose => 'Gruppe schließen';

  @override
  String get tabGroupNameHint => 'Gruppenname';

  @override
  String get tabRename => 'Umbenennen…';

  @override
  String get tabGroupCloseConfirmTitle => 'Gruppe schließen?';

  @override
  String tabGroupCloseConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count Tabs dieser Gruppe laufen Programme:',
      one: 'In 1 Tab dieser Gruppe läuft ein Programm:',
    );
    return '$_temp0\n$titles\n\nBeim Schließen der Gruppe werden sie beendet.';
  }

  @override
  String get zmodemDownloads => 'Downloads (sz)';

  @override
  String get zmodemDownloadModeFolder => 'In Ordner speichern';

  @override
  String get zmodemDownloadModeAsk => 'Speicherort jedes Mal erfragen';

  @override
  String get zmodemDownloadFolder => 'Download-Ordner';

  @override
  String get zmodemSystemDownloads => 'System-Downloads';

  @override
  String get zmodemChooseFolder => 'Auswählen…';

  @override
  String get zmodemReset => 'Zurücksetzen';

  @override
  String get zmodemCancel => 'Abbrechen';

  @override
  String zmodemSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String zmodemSavedFiles(int count, String folder) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien in $folder gespeichert',
      one: '1 Datei in $folder gespeichert',
    );
    return '$_temp0';
  }

  @override
  String zmodemUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien hochgeladen',
      one: '1 Datei hochgeladen',
    );
    return '$_temp0';
  }

  @override
  String zmodemSkippedExisting(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Dateien existieren bereits auf dem Zielsystem und wurden übersprungen (rz -y zum Überschreiben)',
      one:
          '$name existiert bereits auf dem Zielsystem und wurde übersprungen (rz -y zum Überschreiben)',
    );
    return '$_temp0';
  }

  @override
  String get zmodemCancelled => 'Übertragung abgebrochen';

  @override
  String zmodemFailed(String reason) {
    return 'Übertragung fehlgeschlagen: $reason';
  }

  @override
  String get zmodemShowInFinder => 'Im Finder zeigen';

  @override
  String zmodemFileOf(int index, int count) {
    return '$index von $count';
  }

  @override
  String get tabGroupSelected => 'Ausgewählte Tabs gruppieren';

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
