# App Theme

A Flutter package providing Material 3 theme definitions and theme mode utilities for the Web Terminal app.

## Features

- **Pre-built Themes**: Four curated color schemes (Violet, Green, Fire, Wheat)
- **Dynamic Themes**: Generate themes from any seed color
- **Material 3**: Full Material 3 (Material You) support
- **Theme Mode Extensions**: Helper methods for ThemeMode (icons, titles, parsing)
- **Light/Dark Variants**: Each theme includes both light and dark variants

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_theme:
    path: ../app_lib/theme
```

## Usage

### Using Pre-built Themes

```dart
import 'package:app_theme/app_theme.dart';

// Access the list of available themes
final themes = themeList; // [VioletTheme, GreenTheme, FireTheme, WheatTheme]

// Use a specific theme
final violetTheme = VioletTheme();
MaterialApp(
  theme: violetTheme.lightTheme,
  darkTheme: violetTheme.darkTheme,
)
```

### Creating Dynamic Themes

```dart
import 'package:app_theme/app_theme.dart';

// Create a theme from any color
final customTheme = DynamicTheme.fromSeed(Colors.teal);
MaterialApp(
  theme: customTheme.lightTheme,
  darkTheme: customTheme.darkTheme,
)
```

### Theme Mode Extensions

```dart
import 'package:app_theme/app_theme.dart';

// Parse theme mode from string
final mode = ThemeModeExtension.fromString('dark'); // ThemeMode.dark
final mode2 = ThemeModeExtension.fromString('ThemeMode.light'); // ThemeMode.light

// Get display title
ThemeMode.dark.title; // 'Dark'
ThemeMode.light.title; // 'Light'
ThemeMode.system.title; // 'System'

// Get icons
ThemeMode.dark.icon; // Icon(Icons.dark_mode)
ThemeMode.light.icon; // Icon(Icons.light_mode)
ThemeMode.system.icon; // Icon(Icons.brightness_auto)

// Get outlined icons
ThemeMode.dark.iconOutlined; // Icon(Icons.dark_mode_outlined)
```

## Available Themes

| Theme | Primary Color | Description |
|-------|---------------|-------------|
| `VioletTheme` | Purple/Violet | Default theme with violet accents |
| `GreenTheme` | Green | Nature-inspired green theme |
| `FireTheme` | Orange/Red | Warm fire-colored theme |
| `WheatTheme` | Yellow/Amber | Warm wheat/gold tones |

## API Reference

### AppTheme (Abstract)

Base class for all themes.

```dart
abstract class AppTheme {
  const AppTheme({
    required this.name,
    required this.lightTheme,
    required this.darkTheme,
  });

  final String name;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
}
```

### ThemeModeExtension

Extension on `ThemeMode` providing utility methods.

| Method/Property | Return Type | Description |
|-----------------|-------------|-------------|
| `fromString(String?)` | `ThemeMode` | Parse mode from string |
| `title` | `String` | Display name |
| `icon` | `Widget` | Filled icon |
| `iconOutlined` | `Widget` | Outlined icon |

### Theme Classes

- `VioletTheme` - Factory class for violet theme
- `GreenTheme` - Factory class for green theme
- `FireTheme` - Factory class for fire theme
- `WheatTheme` - Factory class for wheat theme
- `DynamicTheme.fromSeed(Color)` - Factory for custom seed-based themes

## Color Schemes

Each theme defines light and dark color schemes in separate files:
- `lib/src/color_schemes/violet.dart`
- `lib/src/color_schemes/green.dart`
- `lib/src/color_schemes/fire.dart`
- `lib/src/color_schemes/wheat.dart`
