import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_conn.dart';

class LocalHostSpec implements HostSpec {
  @override
  final name = 'Local';

  @override
  HostConnector createConnector() => LocalConnector();
}
