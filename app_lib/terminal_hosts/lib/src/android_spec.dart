import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_conn.dart';

/// Host specification for Android devices using sandboxed shell.
class AndroidHostSpec implements HostSpec {
  @override
  final name = 'Android';

  @override
  HostConnector createConnector() => AndroidConnector();
}
