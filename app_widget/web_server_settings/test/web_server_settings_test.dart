import 'package:flutter_test/flutter_test.dart';
import 'package:web_server_settings/web_server_settings.dart';

void main() {
  group('web_server_settings', () {
    test('exports are available', () {
      // Verify the package exports can be imported
      expect(WebServerStatusIndicator, isNotNull);
      expect(WebServerSettingsSection, isNotNull);
      expect(SessionApprovalList, isNotNull);
      expect(ActiveSessionsList, isNotNull);
      expect(ReadOnlyTerminalViewer, isNotNull);
    });
  });
}
