// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get destinationWebTerminal => 'Web Terminal';

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
  String get sshKeyImport => '从文件导入';

  @override
  String get sshKeyImportError => '无法读取私钥文件。请选择非空的 UTF-8 文本文件。';

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
  String get undo => '撤销';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get sshHostKeyTitle => '信任 SSH 主机密钥？';

  @override
  String get sshHostKeyTrust => '信任并连接';

  @override
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint) {
    return '尚未信任 $hostname:$port 的身份。\n\n$type\n$fingerprint\n\n请先与服务器管理员核对指纹，再确认信任。';
  }

  @override
  String get optionKeyBehavior => 'Option 键行为';

  @override
  String get optionKeyBehaviorLeftMeta => '左侧 Meta';

  @override
  String get optionKeyBehaviorBothMeta => '两侧 Meta';

  @override
  String get optionKeyBehaviorNormal => '正常';

  @override
  String get optionKeyBehaviorDescription => 'Meta 发送 Esc + 按键；正常模式输入特殊字符。';

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
  String get tabGroupUngrouped => '未分组';

  @override
  String get tabGroupMoveTo => '移到分组';

  @override
  String get tabGroupNew => '新建分组…';

  @override
  String get tabGroupRemove => '移出分组';

  @override
  String get tabGroupRename => '重命名分组…';

  @override
  String get tabGroupClose => '关闭分组';

  @override
  String get tabGroupNameHint => '分组名称';

  @override
  String get tabRename => '重命名…';

  @override
  String get tabGroupCloseConfirmTitle => '关闭分组？';

  @override
  String tabGroupCloseConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '该分组中有 $count 个标签页正在运行程序：',
    );
    return '$_temp0\n$titles\n\n关闭分组将终止这些程序。';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

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

  @override
  String get sshKeyImport => '从文件导入';

  @override
  String get sshKeyImportError => '无法读取私钥文件。请选择非空的 UTF-8 文本文件。';

  @override
  String get undo => '撤销';

  @override
  String get sshHostKeyTitle => '信任 SSH 主机密钥？';

  @override
  String get sshHostKeyTrust => '信任并连接';

  @override
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint) {
    return '尚未信任 $hostname:$port 的身份。\n\n$type\n$fingerprint\n\n请先与服务器管理员核对指纹，再确认信任。';
  }

  @override
  String get optionKeyBehavior => 'Option 键行为';

  @override
  String get optionKeyBehaviorLeftMeta => '左侧 Meta';

  @override
  String get optionKeyBehaviorBothMeta => '两侧 Meta';

  @override
  String get optionKeyBehaviorNormal => '正常';

  @override
  String get optionKeyBehaviorDescription => 'Meta 发送 Esc + 按键；正常模式输入特殊字符。';

  @override
  String get tabGroupUngrouped => '未分组';

  @override
  String get tabGroupMoveTo => '移到分组';

  @override
  String get tabGroupNew => '新建分组…';

  @override
  String get tabGroupRemove => '移出分组';

  @override
  String get tabGroupRename => '重命名分组…';

  @override
  String get tabGroupClose => '关闭分组';

  @override
  String get tabGroupNameHint => '分组名称';

  @override
  String get tabRename => '重命名…';

  @override
  String get tabGroupCloseConfirmTitle => '关闭分组？';

  @override
  String tabGroupCloseConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '该分组中有 $count 个标签页正在运行程序：',
    );
    return '$_temp0\n$titles\n\n关闭分组将终止这些程序。';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

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

  @override
  String get sshKeyImport => '從檔案匯入';

  @override
  String get sshKeyImportError => '無法讀取私鑰檔案。請選擇非空白的 UTF-8 文字檔案。';

  @override
  String get undo => '復原';

  @override
  String get sshHostKeyTitle => '信任 SSH 主機金鑰？';

  @override
  String get sshHostKeyTrust => '信任並連線';

  @override
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint) {
    return '尚未信任 $hostname:$port 的身分。\n\n$type\n$fingerprint\n\n請先與伺服器管理員核對指紋，再確認信任。';
  }

  @override
  String get optionKeyBehavior => 'Option 鍵行為';

  @override
  String get optionKeyBehaviorLeftMeta => '左側 Meta';

  @override
  String get optionKeyBehaviorBothMeta => '兩側 Meta';

  @override
  String get optionKeyBehaviorNormal => '正常';

  @override
  String get optionKeyBehaviorDescription => 'Meta 傳送 Esc + 按鍵；正常模式輸入特殊字元。';

  @override
  String get tabGroupUngrouped => '未分組';

  @override
  String get tabGroupMoveTo => '移到分組';

  @override
  String get tabGroupNew => '新增分組…';

  @override
  String get tabGroupRemove => '移出分組';

  @override
  String get tabGroupRename => '重新命名分組…';

  @override
  String get tabGroupClose => '關閉分組';

  @override
  String get tabGroupNameHint => '分組名稱';

  @override
  String get tabRename => '重新命名…';

  @override
  String get tabGroupCloseConfirmTitle => '關閉分組？';

  @override
  String tabGroupCloseConfirmMessage(int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此分組中有 $count 個分頁正在執行程式：',
    );
    return '$_temp0\n$titles\n\n關閉分組將終止這些程式。';
  }
}
