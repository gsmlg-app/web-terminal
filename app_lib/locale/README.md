# App Locale

A Flutter localization package providing internationalization support for the Web Terminal app.

## Features

- **14 Supported Languages**: English, Spanish, French, German, Italian, Russian, Ukrainian, Korean, Japanese, Czech, Arabic, and Chinese (Simplified/Traditional)
- **Flutter l10n Integration**: Built on Flutter's official localization framework
- **BuildContext Extension**: Convenient `context.l10n` accessor for localized strings
- **Pre-configured Delegates**: Material, Cupertino, and Widgets localization delegates

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_locale:
    path: ../app_lib/locale
```

## Usage

### Setup in MaterialApp

```dart
import 'package:app_locale/app_locale.dart';

MaterialApp(
  localizationsDelegates: AppLocale.localizationsDelegates,
  supportedLocales: AppLocale.supportedLocales,
  home: HomePage(),
)
```

### Accessing Localized Strings

```dart
import 'package:app_locale/app_locale.dart';

// Using the BuildContext extension
Text(context.l10n.appTitle)
Text(context.l10n.errorMessage)
Text(context.l10n.retry)
```

## Supported Locales

| Code | Language | Script |
|------|----------|--------|
| `en` | English | - |
| `es` | Spanish | - |
| `fr` | French | - |
| `de` | German | - |
| `it` | Italian | - |
| `ru` | Russian | - |
| `uk` | Ukrainian | - |
| `ko` | Korean | - |
| `ja` | Japanese | - |
| `cs` | Czech | - |
| `ar` | Arabic | - |
| `zh` | Chinese (Generic) | - |
| `zh_Hans` | Chinese | Simplified |
| `zh_Hant` | Chinese | Traditional |

## Components

### AppLocale

Static class providing localization configuration.

| Property | Type | Description |
|----------|------|-------------|
| `localizationsDelegates` | `List<LocalizationsDelegate>` | All required delegates |
| `supportedLocales` | `List<Locale>` | All 14 supported locales |

### Localization Extension

BuildContext extension for convenient string access.

```dart
extension Localization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

## Adding New Strings

1. Add the string to `lib/l10n/app_en.arb` (primary language)
2. Add translations to other `.arb` files
3. Run `flutter gen-l10n` or `melos run gen-l10n`
4. Access via `context.l10n.yourNewString`

## Generated Files

The `lib/gen_l10n/` directory contains auto-generated localization classes:
- `app_localizations.dart` - Main AppLocalizations class
- `app_localizations_*.dart` - Per-language implementations

These files are generated from ARB files in `lib/l10n/` and should not be manually edited.
