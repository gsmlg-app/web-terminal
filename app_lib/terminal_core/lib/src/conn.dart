import 'package:flutter/foundation.dart';
import 'package:terminal_core/src/host.dart';

abstract class HostSpec {
  String get name;

  HostConnector createConnector();
}

enum HostConnectorStatus {
  initialized,
  connecting,
  connected,
  disconnected,
  aborted,
}

/// Manages the connection lifecycle to a host.
///
/// Extends [ChangeNotifier] to notify listeners when the connection status changes.
/// Use [addListener] to subscribe to status changes.
abstract class HostConnector<T extends Host> extends ChangeNotifier {
  HostConnector();

  HostConnectorStatus _status = HostConnectorStatus.initialized;

  T? _host;

  /// The last connection error, if any.
  Object? _lastError;

  /// Current connection status.
  HostConnectorStatus get status => _status;

  /// The connected host, or null if not connected.
  T? get host => _host;

  /// The last connection error, or null if connected successfully.
  Object? get lastError => _lastError;

  @protected
  Future<T> createHost();

  /// Updates the status and notifies listeners.
  @protected
  void setStatus(HostConnectorStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  Future<void> connect() async {
    if (_status == HostConnectorStatus.connected ||
        _status == HostConnectorStatus.connecting) {
      return;
    }

    _lastError = null;
    setStatus(HostConnectorStatus.connecting);

    try {
      _host = await createHost();
      _host!.done.then((_) => _onDone(), onError: _onError);

      setStatus(HostConnectorStatus.connected);
    } catch (e) {
      _lastError = e;
      setStatus(HostConnectorStatus.disconnected);
    }
  }

  Future<void> disconnect() async {
    await _host?.disconnect();
    _host = null;
    setStatus(HostConnectorStatus.disconnected);
  }

  void _onDone() {
    _host = null;
    setStatus(HostConnectorStatus.disconnected);
  }

  void _onError(Object error) {
    _host = null;
    setStatus(HostConnectorStatus.aborted);
  }
}
