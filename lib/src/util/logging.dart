import 'package:logging/logging.dart';

/// Available logging methods are:
/// ```
/// log.shout(logged_content);
/// log.severe(logged_content);
/// log.warning(logged_content);
/// log.info(logged_content);
/// log.config(logged_content);
/// log.fine(logged_content);
/// log.finer(logged_content);
/// log.finest(logged_content);
/// ```
final log = Logger('web_terminal');
