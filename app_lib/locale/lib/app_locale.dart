import 'package:app_locale/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

export 'package:app_locale/extensions/build_context.dart';
export 'package:app_locale/gen_l10n/app_localizations.dart';

class AppLocale {
  static List<LocalizationsDelegate> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static List<Locale> supportedLocales = [
    const Locale('en'), // English
    const Locale('es'), // Spanish
    const Locale('fr'), // French
    const Locale('de'), // German
    const Locale('it'), // Italian
    const Locale('ru'), // Russian
    const Locale('uk'), // Ukrainian
    const Locale('ko'), // Korean
    const Locale('ja'), // Japanese
    const Locale('cs'), // Czech
    const Locale('ar'), // Arabic
    const Locale.fromSubtags(languageCode: 'zh'), // generic Chinese 'zh'
    const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
    const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
  ];
}
