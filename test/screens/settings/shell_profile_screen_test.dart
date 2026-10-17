import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:web_terminal/screens/settings/shell_profile_edit_screen.dart';
import 'package:web_terminal/screens/settings/shell_profile_screen.dart';

class MockShellProfileBloc
    extends MockBloc<ShellProfileEvent, ShellProfileState>
    implements ShellProfileBloc {}

ShellProfile createTestProfile({
  int id = 1,
  String name = 'My Zsh Profile',
  int shellType = 3,
  String environmentVariables = '{}',
  String aliases = '{}',
  String fontFamily = 'Source Code Pro',
  double fontSize = 14.0,
  String colorTheme = 'default',
  String workingDirectory = '/tmp',
  String startupCommand = 'echo hi',
  int cursorStyle = 0,
  int scrollbackLines = 10000,
  bool isDefault = false,
  bool inheritCurrentState = false,
}) {
  return ShellProfile(
    id: id,
    name: name,
    shellType: shellType,
    environmentVariables: environmentVariables,
    aliases: aliases,
    fontFamily: fontFamily,
    fontSize: fontSize,
    colorTheme: colorTheme,
    workingDirectory: workingDirectory,
    startupCommand: startupCommand,
    cursorStyle: cursorStyle,
    scrollbackLines: scrollbackLines,
    isDefault: isDefault,
    inheritCurrentState: inheritCurrentState,
  );
}

void main() {
  late MockShellProfileBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const LoadShellProfiles());
  });

  setUp(() {
    mockBloc = MockShellProfileBloc();
  });

  tearDown(() async {
    await mockBloc.close();
  });

  Widget buildRouterTestWidget({
    String initialLocation = '/settings/shell_profiles',
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          name: ShellProfileScreen.name,
          path: '/settings/shell_profiles',
          builder: (context, state) => const ShellProfileScreen(),
          routes: [
            GoRoute(
              name: ShellProfileEditScreen.name,
              path: ShellProfileEditScreen.path,
              builder: (context, state) {
                final idStr = state.uri.queryParameters['id'];
                final profileId = idStr != null ? int.tryParse(idStr) : null;
                return ShellProfileEditScreen(profileId: profileId);
              },
            ),
          ],
        ),
      ],
    );

    return BlocProvider<ShellProfileBloc>.value(
      value: mockBloc,
      child: MaterialApp.router(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('ShellProfileScreen & ShellProfileEditScreen', () {
    testWidgets('displays empty state with Add Profile tile when loaded', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileLoaded([]));

      await tester.pumpWidget(buildRouterTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Shell Profiles'), findsWidgets);
      expect(find.text('Add Profile'), findsWidgets);
      verifyNever(() => mockBloc.add(const LoadShellProfiles()));
    });

    testWidgets('shows New Profile screen with form fields', (tester) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileLoaded([]));

      await tester.pumpWidget(
        buildRouterTestWidget(initialLocation: '/settings/shell_profiles/edit'),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Profile'), findsWidgets);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Shell Type'), findsWidgets);
      expect(find.text('Default Profile'), findsWidgets);
    });

    testWidgets(
      'populates Edit Profile form even when profiles finish loading after mount',
      (tester) async {
        final controller = StreamController<ShellProfileState>.broadcast();
        addTearDown(controller.close);
        final profile = createTestProfile(id: 42, name: 'My Zsh Profile');

        whenListen(
          mockBloc,
          controller.stream,
          initialState: const ShellProfileLoading(),
        );

        await tester.pumpWidget(
          buildRouterTestWidget(
            initialLocation: '/settings/shell_profiles/edit?id=42',
          ),
        );
        await tester.pump();

        // Emit loaded state after widget mounted while in loading state
        when(() => mockBloc.state).thenReturn(ShellProfileLoaded([profile]));
        controller.add(ShellProfileLoaded([profile]));
        await tester.pumpAndSettle();

        expect(find.text('Edit Profile'), findsWidgets);
        expect(find.text('My Zsh Profile'), findsWidgets);
      },
    );
  });
}
