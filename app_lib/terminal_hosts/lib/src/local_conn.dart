import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_host.dart';

class LocalConnector extends HostConnector<LocalHost> {
  LocalConnector();

  @override
  Future<LocalHost> createHost() async {
    return LocalHost();
  }
}
