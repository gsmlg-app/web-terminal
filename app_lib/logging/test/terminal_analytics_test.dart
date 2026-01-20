import 'package:flutter_test/flutter_test.dart';
import 'package:app_logging/app_logging.dart';

void main() {
  group('SessionType', () {
    test('has correct values', () {
      expect(SessionType.values, hasLength(3));
      expect(SessionType.local.name, 'local');
      expect(SessionType.ssh.name, 'ssh');
      expect(SessionType.sftp.name, 'sftp');
    });
  });

  group('TerminalEvent', () {
    test('has correct values', () {
      expect(TerminalEvent.values, hasLength(3));
      expect(TerminalEvent.sessionCreated.name, 'sessionCreated');
      expect(TerminalEvent.sessionClosed.name, 'sessionClosed');
      expect(TerminalEvent.fullscreenToggled.name, 'fullscreenToggled');
    });
  });

  group('AnalyticsEvent', () {
    test('creates with required parameters', () {
      final event = AnalyticsEvent(type: TerminalEvent.sessionCreated);

      expect(event.type, TerminalEvent.sessionCreated);
      expect(event.properties, isEmpty);
      expect(event.timestamp, isNotNull);
    });

    test('creates with properties', () {
      final event = AnalyticsEvent(
        type: TerminalEvent.sessionCreated,
        properties: {'session_type': 'local'},
      );

      expect(event.properties, {'session_type': 'local'});
    });

    test('creates with custom timestamp', () {
      final customTime = DateTime(2025, 1, 1, 12, 0);
      final event = AnalyticsEvent(
        type: TerminalEvent.sessionCreated,
        timestamp: customTime,
      );

      expect(event.timestamp, customTime);
    });

    test('toString includes all fields', () {
      final event = AnalyticsEvent(
        type: TerminalEvent.sessionCreated,
        properties: {'session_type': 'ssh'},
      );
      final str = event.toString();

      expect(str, contains('AnalyticsEvent'));
      expect(str, contains('sessionCreated'));
      expect(str, contains('session_type'));
    });
  });

  group('TerminalAnalytics', () {
    late TerminalAnalytics analytics;

    setUp(() {
      analytics = TerminalAnalytics();
    });

    test('is singleton', () {
      final analytics1 = TerminalAnalytics();
      final analytics2 = TerminalAnalytics();

      expect(identical(analytics1, analytics2), isTrue);
    });

    test('trackSessionCreated emits event', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionCreated(SessionType.local);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events[0].type, TerminalEvent.sessionCreated);
      expect(events[0].properties['session_type'], 'local');

      await subscription.cancel();
    });

    test('trackSessionCreated includes metadata', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionCreated(
        SessionType.ssh,
        metadata: {'host': 'example.com'},
      );
      await Future.delayed(Duration.zero);

      expect(events[0].properties['session_type'], 'ssh');
      expect(events[0].properties['host'], 'example.com');

      await subscription.cancel();
    });

    test('trackSessionClosed emits event', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionClosed(SessionType.local);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events[0].type, TerminalEvent.sessionClosed);
      expect(events[0].properties['session_type'], 'local');

      await subscription.cancel();
    });

    test('trackSessionClosed includes duration', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionClosed(SessionType.ssh, durationMs: 60000);
      await Future.delayed(Duration.zero);

      expect(events[0].properties['duration_ms'], 60000);

      await subscription.cancel();
    });

    test('trackFullscreenToggled emits event with true', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackFullscreenToggled(true);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events[0].type, TerminalEvent.fullscreenToggled);
      expect(events[0].properties['is_fullscreen'], true);

      await subscription.cancel();
    });

    test('trackFullscreenToggled emits event with false', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackFullscreenToggled(false);
      await Future.delayed(Duration.zero);

      expect(events[0].properties['is_fullscreen'], false);

      await subscription.cancel();
    });

    test('tracks multiple events in sequence', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionCreated(SessionType.local);
      analytics.trackFullscreenToggled(true);
      analytics.trackSessionClosed(SessionType.local);
      await Future.delayed(Duration.zero);

      expect(events, hasLength(3));
      expect(events[0].type, TerminalEvent.sessionCreated);
      expect(events[1].type, TerminalEvent.fullscreenToggled);
      expect(events[2].type, TerminalEvent.sessionClosed);

      await subscription.cancel();
    });

    test('tracks different session types', () async {
      final events = <AnalyticsEvent>[];
      final subscription = analytics.eventStream.listen(events.add);

      analytics.trackSessionCreated(SessionType.local);
      analytics.trackSessionCreated(SessionType.ssh);
      analytics.trackSessionCreated(SessionType.sftp);
      await Future.delayed(Duration.zero);

      expect(events[0].properties['session_type'], 'local');
      expect(events[1].properties['session_type'], 'ssh');
      expect(events[2].properties['session_type'], 'sftp');

      await subscription.cancel();
    });
  });
}
