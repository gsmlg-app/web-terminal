import 'package:app_locale/app_locale.dart' show AppLocalizations;
import 'package:flutter/material.dart' show BuildContext;

extension Localization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
