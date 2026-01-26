import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:terminal_settings/terminal_settings.dart';

void main() {
  group('SettingsSectionWifiInfo', () {
    group('constructor', () {
      test('has private constructor', () {
        // SettingsSectionWifiInfo has a private constructor (._())
        // This class should only be used via static methods
        expect(SettingsSectionWifiInfo, isNotNull);
      });
    });

    group('build', () {
      testWidgets('creates SettingsSection', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(section, isA<SettingsSection>());
        expect((section.title as Text).data, 'WiFi Information');
      });

      testWidgets('displays Network Status tile', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Verify via the section object directly
        expect(section.tiles, hasLength(3));
        final firstTile = section.tiles[0] as SettingsTile;
        expect((firstTile.title as Text).data, 'Network Status');
        expect((firstTile.value as Text).data, 'Connected');
      });

      testWidgets('displays SSID tile', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        final ssidTile = section.tiles[1] as SettingsTile;
        expect((ssidTile.title as Text).data, 'SSID');
        expect((ssidTile.value as Text).data, 'Not available');
      });

      testWidgets('displays IP Address tile', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        final ipTile = section.tiles[2] as SettingsTile;
        expect((ipTile.title as Text).data, 'IP Address');
        expect((ipTile.value as Text).data, 'Not available');
      });

      testWidgets('displays wifi icons', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Verify icons via tile leading widgets
        final networkTile = section.tiles[0] as SettingsTile;
        final ssidTile = section.tiles[1] as SettingsTile;
        final ipTile = section.tiles[2] as SettingsTile;

        expect((networkTile.leading as Icon).icon, Icons.wifi);
        expect((ssidTile.leading as Icon).icon, Icons.wifi_lock);
        expect((ipTile.leading as Icon).icon, Icons.router);
      });

      testWidgets('displays hint about network_info_plus package',
          (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        final ssidTile = section.tiles[1] as SettingsTile;
        expect(
          (ssidTile.description as Text).data,
          'Add network_info_plus package for full WiFi details',
        );
      });

      testWidgets('contains exactly 3 tiles', (tester) async {
        late SettingsSection section;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  section = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // Network Status, SSID, IP Address
        expect(section.tiles, hasLength(3));
      });
    });

    group('section structure', () {
      testWidgets('returns SettingsSection type', (tester) async {
        late SettingsSection result;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  result = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(result, isA<SettingsSection>());
      });

      testWidgets('section title is Text widget', (tester) async {
        late SettingsSection result;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  result = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(result.title, isA<Text>());
        expect((result.title as Text).data, 'WiFi Information');
      });

      testWidgets('tiles list has 3 elements', (tester) async {
        late SettingsSection result;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  result = SettingsSectionWifiInfo.build(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(result.tiles, hasLength(3));
      });
    });
  });
}
