import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocale', () {
    group('supportedLocales', () {
      test('is not empty', () {
        expect(AppLocale.supportedLocales.isNotEmpty, isTrue);
      });

      test('contains English locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'en'),
          isTrue,
        );
      });

      test('contains Spanish locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'es'),
          isTrue,
        );
      });

      test('contains French locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'fr'),
          isTrue,
        );
      });

      test('contains German locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'de'),
          isTrue,
        );
      });

      test('contains Italian locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'it'),
          isTrue,
        );
      });

      test('contains Russian locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'ru'),
          isTrue,
        );
      });

      test('contains Ukrainian locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'uk'),
          isTrue,
        );
      });

      test('contains Korean locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'ko'),
          isTrue,
        );
      });

      test('contains Japanese locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'ja'),
          isTrue,
        );
      });

      test('contains Czech locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'cs'),
          isTrue,
        );
      });

      test('contains Arabic locale', () {
        expect(
          AppLocale.supportedLocales.any((l) => l.languageCode == 'ar'),
          isTrue,
        );
      });

      test('contains Chinese locales', () {
        final chineseLocales = AppLocale.supportedLocales
            .where((l) => l.languageCode == 'zh')
            .toList();
        expect(chineseLocales.length, 3); // generic, Hans, Hant
      });

      test('has exactly 14 supported locales', () {
        expect(AppLocale.supportedLocales.length, 14);
      });

      test('Chinese Hans locale has correct script code', () {
        final hansLocale = AppLocale.supportedLocales.firstWhere(
          (l) => l.languageCode == 'zh' && l.scriptCode == 'Hans',
        );
        expect(hansLocale.scriptCode, 'Hans');
      });

      test('Chinese Hant locale has correct script code', () {
        final hantLocale = AppLocale.supportedLocales.firstWhere(
          (l) => l.languageCode == 'zh' && l.scriptCode == 'Hant',
        );
        expect(hantLocale.scriptCode, 'Hant');
      });

      test('all locales have non-empty language codes', () {
        for (final locale in AppLocale.supportedLocales) {
          expect(locale.languageCode.isNotEmpty, isTrue);
        }
      });
    });

    group('localizationsDelegates', () {
      test('is not empty', () {
        expect(AppLocale.localizationsDelegates.isNotEmpty, isTrue);
      });

      test('has exactly 4 delegates', () {
        expect(AppLocale.localizationsDelegates.length, 4);
      });

      test('all delegates are LocalizationsDelegate', () {
        for (final delegate in AppLocale.localizationsDelegates) {
          expect(delegate, isA<LocalizationsDelegate>());
        }
      });
    });
  });

  group('Localization extension on BuildContext', () {
    testWidgets('l10n returns AppLocalizations instance', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final l10n = capturedContext.l10n;
      expect(l10n, isA<AppLocalizations>());
    });

    testWidgets('l10n provides localized strings', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final l10n = capturedContext.l10n;
      // appName should be defined in the localizations
      expect(l10n.appName, isA<String>());
      expect(l10n.appName.isNotEmpty, isTrue);
    });
  });
}
