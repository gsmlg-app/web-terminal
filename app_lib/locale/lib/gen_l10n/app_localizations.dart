import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Web Terminal'**
  String get appName;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @destinationTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get destinationTerminal;

  /// No description provided for @destinationWebTerminal.
  ///
  /// In en, this message translates to:
  /// **'Web Terminal'**
  String get destinationWebTerminal;

  /// No description provided for @destinationSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get destinationSetting;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settingsTitle;

  /// No description provided for @smenuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get smenuTheme;

  /// No description provided for @titleSelectAppearance.
  ///
  /// In en, this message translates to:
  /// **'Select Appearance'**
  String get titleSelectAppearance;

  /// No description provided for @titleSelectColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Accent Color'**
  String get titleSelectColorTheme;

  /// No description provided for @smenuSSH.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get smenuSSH;

  /// No description provided for @sshHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get sshHost;

  /// No description provided for @titleSSHHost.
  ///
  /// In en, this message translates to:
  /// **'SSH Host'**
  String get titleSSHHost;

  /// No description provided for @addSshHost.
  ///
  /// In en, this message translates to:
  /// **'Add SSH Host'**
  String get addSshHost;

  /// No description provided for @editSshHost.
  ///
  /// In en, this message translates to:
  /// **'Edit SSH Host'**
  String get editSshHost;

  /// No description provided for @sshKey.
  ///
  /// In en, this message translates to:
  /// **'SSH Key'**
  String get sshKey;

  /// No description provided for @titleSSHKey.
  ///
  /// In en, this message translates to:
  /// **'SSH Key'**
  String get titleSSHKey;

  /// No description provided for @addSshKey.
  ///
  /// In en, this message translates to:
  /// **'Add SSH Key'**
  String get addSshKey;

  /// No description provided for @showPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Show Public Key'**
  String get showPublicKey;

  /// No description provided for @sshKeyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sshKeyNameLabel;

  /// No description provided for @sshKeyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name of your SSH Key'**
  String get sshKeyNameHint;

  /// No description provided for @sshKeyContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Key Content'**
  String get sshKeyContentLabel;

  /// No description provided for @sshKeyGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate SSH Key'**
  String get sshKeyGenerate;

  /// No description provided for @sshKeyImport.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get sshKeyImport;

  /// No description provided for @sshKeyImportError.
  ///
  /// In en, this message translates to:
  /// **'Unable to read the private key file. Choose a non-empty UTF-8 text file.'**
  String get sshKeyImportError;

  /// No description provided for @deleteSshKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this SSH Key?'**
  String get deleteSshKeyMessage;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get publicKey;

  /// No description provided for @sshHostHostLabel.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get sshHostHostLabel;

  /// No description provided for @sshHostHostnameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hostname'**
  String get sshHostHostnameLabel;

  /// No description provided for @sshHostPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get sshHostPortLabel;

  /// No description provided for @sshHostUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get sshHostUsernameLabel;

  /// No description provided for @sshHostIdentifyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Identify Type'**
  String get sshHostIdentifyTypeLabel;

  /// No description provided for @sshHostIdentityTypePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sshHostIdentityTypePassword;

  /// No description provided for @sshHostIdentityTypePrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get sshHostIdentityTypePrivateKey;

  /// No description provided for @sshHostPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sshHostPasswordLabel;

  /// No description provided for @sshHostPrivateKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get sshHostPrivateKeyLabel;

  /// No description provided for @deleteSshHostMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this SSH Host?'**
  String get deleteSshHostMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @sshHostKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trust SSH host key?'**
  String get sshHostKeyTitle;

  /// No description provided for @sshHostKeyTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust and connect'**
  String get sshHostKeyTrust;

  /// First connection requires explicitly accepting the server host key.
  ///
  /// In en, this message translates to:
  /// **'The identity of {hostname}:{port} is not yet trusted.\n\n{type}\n{fingerprint}\n\nCompare this fingerprint with the server administrator before trusting it.'**
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint);

  /// No description provided for @optionKeyBehavior.
  ///
  /// In en, this message translates to:
  /// **'Option Key Behavior'**
  String get optionKeyBehavior;

  /// No description provided for @optionKeyBehaviorLeftMeta.
  ///
  /// In en, this message translates to:
  /// **'Left Meta'**
  String get optionKeyBehaviorLeftMeta;

  /// No description provided for @optionKeyBehaviorBothMeta.
  ///
  /// In en, this message translates to:
  /// **'Both Meta'**
  String get optionKeyBehaviorBothMeta;

  /// No description provided for @optionKeyBehaviorNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get optionKeyBehaviorNormal;

  /// No description provided for @optionKeyBehaviorDescription.
  ///
  /// In en, this message translates to:
  /// **'Meta sends Esc + key. Normal types special characters.'**
  String get optionKeyBehaviorDescription;

  /// No description provided for @closeTabConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Close Tab?'**
  String get closeTabConfirmTitle;

  /// Shown before closing a tab whose shell has a foreground program running.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has a running program. Closing the tab will terminate it.'**
  String closeTabConfirmMessage(String title);

  /// No description provided for @quitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Web Terminal?'**
  String get quitConfirmTitle;

  /// Shown before quitting or closing the window while tabs have foreground programs running.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tab has a running program:} other{{count} tabs have running programs:}}\n{titles}\n\nQuitting will terminate them.'**
  String quitConfirmMessage(int count, String titles);

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'cs',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'ru',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
