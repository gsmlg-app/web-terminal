import 'package:flutter/material.dart' show BuildContext;
import 'package:web_terminal/l10n/gen_l10n/web_terminal_localizations.dart'
    show WebTerminalLocalizations;

extension Localization on BuildContext {
  WebTerminalLocalizations get l10n => WebTerminalLocalizations.of(this);
}
