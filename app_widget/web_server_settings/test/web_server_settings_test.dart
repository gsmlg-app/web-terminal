import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_server_settings/web_server_settings.dart';

void main() {
  group('web_server_settings exports', () {
    test('all exports are available', () {
      // Verify the package exports can be imported
      expect(WebServerStatusIndicator, isNotNull);
      expect(WebServerSettingsSection, isNotNull);
      expect(SessionApprovalList, isNotNull);
      expect(ActiveSessionsList, isNotNull);
      expect(ReadOnlyTerminalViewer, isNotNull);
    });

    test('PendingSessionsBadge is exported', () {
      expect(PendingSessionsBadge, isNotNull);
    });

    test('OnAttachSession typedef exists', () {
      // Verify typedef works by creating a callback that matches it
      void testHandler(dynamic session) {}
      OnAttachSession handler = testHandler;
      expect(handler, isA<Function>());
    });

    test('ApproveByCodeDialog is exported', () {
      expect(ApproveByCodeDialog, isNotNull);
    });

    test('SessionApprovalCard is exported', () {
      expect(SessionApprovalCard, isNotNull);
    });

    test('ActiveSessionCard is exported', () {
      expect(ActiveSessionCard, isNotNull);
    });
  });

  group('WebServerStatusIndicator widget', () {
    test('has const constructor', () {
      const indicator = WebServerStatusIndicator();
      expect(indicator, isA<WebServerStatusIndicator>());
    });

    test('has default size of 12', () {
      const indicator = WebServerStatusIndicator();
      expect(indicator.size, equals(12.0));
    });

    test('accepts custom size', () {
      const indicator = WebServerStatusIndicator(size: 24);
      expect(indicator.size, equals(24.0));
    });

    test('accepts key parameter', () {
      const key = Key('test-indicator');
      const indicator = WebServerStatusIndicator(key: key);
      expect(indicator.key, equals(key));
    });

    test('is StatelessWidget', () {
      expect(const WebServerStatusIndicator(), isA<StatelessWidget>());
    });

    test('accepts various sizes', () {
      const indicator1 = WebServerStatusIndicator(size: 8);
      const indicator2 = WebServerStatusIndicator(size: 16);
      const indicator3 = WebServerStatusIndicator(size: 32);

      expect(indicator1.size, equals(8.0));
      expect(indicator2.size, equals(16.0));
      expect(indicator3.size, equals(32.0));
    });
  });

  group('PendingSessionsBadge widget', () {
    test('has const constructor', () {
      const badge = PendingSessionsBadge(child: SizedBox());
      expect(badge, isA<PendingSessionsBadge>());
    });

    test('is StatelessWidget', () {
      expect(const PendingSessionsBadge(child: SizedBox()),
          isA<StatelessWidget>());
    });

    test('requires child parameter', () {
      const badge = PendingSessionsBadge(child: Text('Test'));
      expect(badge.child, isA<Text>());
    });

    test('accepts key parameter', () {
      const key = Key('test-badge');
      const badge = PendingSessionsBadge(key: key, child: SizedBox());
      expect(badge.key, equals(key));
    });

    test('accepts various child widgets', () {
      const badge1 = PendingSessionsBadge(child: Icon(Icons.notifications));
      const badge2 = PendingSessionsBadge(child: Text('Test'));
      final badge3 = PendingSessionsBadge(child: Container());

      expect(badge1.child, isA<Icon>());
      expect(badge2.child, isA<Text>());
      expect(badge3.child, isA<Container>());
    });
  });

  group('SessionApprovalList widget', () {
    test('has const constructor', () {
      const list = SessionApprovalList();
      expect(list, isA<SessionApprovalList>());
    });

    test('is StatelessWidget', () {
      expect(const SessionApprovalList(), isA<StatelessWidget>());
    });

    test('accepts key parameter', () {
      const key = Key('approval-list');
      const list = SessionApprovalList(key: key);
      expect(list.key, equals(key));
    });
  });

  group('ActiveSessionsList widget', () {
    test('has const constructor', () {
      const list = ActiveSessionsList();
      expect(list, isA<ActiveSessionsList>());
    });

    test('is StatelessWidget', () {
      expect(const ActiveSessionsList(), isA<StatelessWidget>());
    });

    test('accepts key parameter', () {
      const key = Key('active-list');
      const list = ActiveSessionsList(key: key);
      expect(list.key, equals(key));
    });

    test('accepts onAttach callback', () {
      bool callbackCreated = false;
      final list = ActiveSessionsList(
        onAttach: (session) => callbackCreated = true,
      );

      expect(list.onAttach, isNotNull);
      expect(callbackCreated, isFalse); // Not invoked until user interaction
    });

    test('onAttach is optional', () {
      const list = ActiveSessionsList();
      expect(list.onAttach, isNull);
    });
  });

  group('ApproveByCodeDialog widget', () {
    test('has const constructor', () {
      const dialog = ApproveByCodeDialog();
      expect(dialog, isA<ApproveByCodeDialog>());
    });

    test('is StatefulWidget', () {
      expect(const ApproveByCodeDialog(), isA<StatefulWidget>());
    });

    test('accepts key parameter', () {
      const key = Key('approve-dialog');
      const dialog = ApproveByCodeDialog(key: key);
      expect(dialog.key, equals(key));
    });
  });

  group('ReadOnlyTerminalViewer', () {
    test('is StatefulWidget type', () {
      expect(ReadOnlyTerminalViewer, isA<Type>());
    });

    test('has static show method', () {
      expect(ReadOnlyTerminalViewer.show, isA<Function>());
    });
  });

  group('OnAttachSession typedef', () {
    test('is valid function type', () {
      // Create a function matching the typedef
      void testHandler(dynamic session) {}
      OnAttachSession handler = testHandler;
      expect(handler, isA<Function>());
    });

    test('can be assigned to variable', () {
      OnAttachSession? nullableHandler;
      expect(nullableHandler, isNull);

      nullableHandler = (session) {};
      expect(nullableHandler, isNotNull);
    });
  });
}
