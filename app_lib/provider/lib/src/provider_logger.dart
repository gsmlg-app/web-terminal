import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final _log = Logger('ProviderLogger');

class ProviderLogger implements ProviderObserver {
  const ProviderLogger();

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    _log.info('Provider+: ${provider.describe}');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    _log.info('Provider-: ${provider.describe}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _log.info('Provider*: ${provider.describe}');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _log.info('Provider!: ${provider.describe}');
  }
}

extension _ProviderName on ProviderBase {
  String get describe => name ?? toString();
}
