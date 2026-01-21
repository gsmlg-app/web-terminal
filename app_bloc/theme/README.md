# Theme BLoC

A Flutter BLoC package for managing application theme and theme mode with SharedPreferences persistence.

## Features

- **Theme Management**: Change between pre-defined color themes (Violet, Green, Fire, Wheat)
- **Theme Mode**: Switch between system, light, and dark modes
- **Persistence**: Automatically saves preferences to SharedPreferences
- **Initial State**: Restores saved theme preferences on startup

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  theme_bloc:
    path: ../app_bloc/theme
```

## Usage

### Setup with BlocProvider

```dart
import 'package:theme_bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();

  runApp(
    BlocProvider(
      create: (_) => ThemeBloc(prefs),
      child: MyApp(),
    ),
  );
}
```

### Using ThemeBloc in MaterialApp

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          theme: state.theme.lightTheme,
          darkTheme: state.theme.darkTheme,
          themeMode: state.themeMode,
          home: HomePage(),
        );
      },
    );
  }
}
```

### Changing Theme

```dart
// Change color theme
context.read<ThemeBloc>().add(ChangeTheme(GreenTheme()));

// Change theme mode
context.read<ThemeBloc>().add(ChangeThemeMode(ThemeMode.dark));
```

## Components

### ThemeEvent

Sealed class with two event types:

| Event | Description |
|-------|-------------|
| `ChangeTheme(AppTheme)` | Switch to a different color theme |
| `ChangeThemeMode(ThemeMode)` | Switch between system/light/dark |

### ThemeState

State containing current theme preferences.

| Property | Type | Description |
|----------|------|-------------|
| `theme` | `AppTheme` | Current color theme |
| `themeMode` | `ThemeMode` | Current mode (system/light/dark) |

### ThemeBloc

BLoC that manages theme state and persistence.

- Constructor: `ThemeBloc(SharedPreferences pref)`
- Persists `themeName` and `themeMode` keys to SharedPreferences
- Restores preferences via `ThemeState.initial(pref)` factory

## Persistence Keys

| Key | Value |
|-----|-------|
| `themeName` | Theme name string (e.g., "Violet", "Green") |
| `themeMode` | Mode name string ("system", "light", "dark") |

## Dependencies

- `bloc` - BLoC state management
- `equatable` - Value equality for state
- `app_theme` - Theme definitions (AppTheme, themeList)
- `shared_preferences` - Local storage persistence
