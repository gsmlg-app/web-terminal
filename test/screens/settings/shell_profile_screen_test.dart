import 'package:app_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:web_terminal/screens/settings/shell_profile_screen.dart';

void main() {
  late AppDatabase database;
  late ShellProfileBloc shellProfileBloc;

  setUp(() {
    database = AppDatabase.forTesting();
    shellProfileBloc = ShellProfileBloc(database);
  });

  tearDown(() async {
    await shellProfileBloc.close();
    await database.close();
  });

  Widget buildTestWidget({Widget? child}) {
    return MaterialApp(
      home: BlocProvider<ShellProfileBloc>.value(
        value: shellProfileBloc,
        child: child ?? const Scaffold(body: SizedBox()),
      ),
    );
  }

  group('showShellProfileForm', () {
    testWidgets('shows create dialog with correct title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Profile'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Shell Type'), findsOneWidget);
      expect(find.text('Default Profile'), findsOneWidget);
    });

    testWidgets('shows edit dialog with correct title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final profile = ShellProfile(
        id: 1,
        name: 'Test Profile',
        shellType: 1,
        environmentVariables: '{}',
        aliases: '{}',
        fontFamily: 'monospace',
        fontSize: 14.0,
        colorTheme: 'default',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
        profile: profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Test Profile'), findsOneWidget);
    });

    testWidgets('has Cancel and Add buttons for new profile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('has Cancel and Save buttons for edit', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final profile = ShellProfile(
        id: 1,
        name: 'Test Profile',
        shellType: 1,
        environmentVariables: '{}',
        aliases: '{}',
        fontFamily: 'monospace',
        fontSize: 14.0,
        colorTheme: 'default',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
        profile: profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('closes dialog on Cancel', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('New Profile'), findsNothing);
    });

    testWidgets('does not submit with empty name', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      // Clear the name field and try to add
      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Dialog should still be open
      expect(find.text('New Profile'), findsOneWidget);
    });

    testWidgets('submits form with valid name', (tester) async {
      // Use a Builder to get a context that has access to the BlocProvider
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ShellProfileBloc>.value(
            value: shellProfileBloc,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => showShellProfileForm(context: context),
                    child: const Text('Open Form'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'My Profile');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('New Profile'), findsNothing);
    });

    testWidgets('shows shell type dropdown', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      // Find and tap the shell type dropdown
      expect(find.byType(DropdownButtonFormField<ShellType>), findsOneWidget);
    });

    testWidgets('shows default profile switch', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      showShellProfileForm(
        context: tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Default Profile'), findsOneWidget);
    });
  });
}
