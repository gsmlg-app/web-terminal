# App Artwork

A Flutter package providing custom artwork widgets including vector logos and Lottie animations for the Web Terminal app.

## Features

- **Custom Vector Logo**: `LogoGSMLGDEV` - A vector-based logo using Flutter's CustomPaint, rendering the GSMLG.DEV brand mark
- **Lottie Animations**: `LaddingPageLottie` - Landing page animation with full Lottie configuration support
- **Scalable Graphics**: AspectRatio-preserving widgets that scale cleanly across different screen sizes

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_artwork:
    path: ../app_widget/artwork
```

## Usage

### Vector Logo

Display the GSMLG.DEV logo as a scalable vector graphic:

```dart
import 'package:app_artwork/app_artwork.dart';

// Basic usage
LogoGSMLGDEV()

// With child widget overlay
LogoGSMLGDEV(
  child: Text('GSMLG.DEV'),
)
```

The logo maintains a 10:2 aspect ratio and renders at 1000x200 pixels by default.

### Lottie Animation

Display the landing page animation with customizable Lottie settings:

```dart
import 'package:app_artwork/app_artwork.dart';

// Basic animated usage
LaddingPageLottie()

// Customized
LaddingPageLottie(
  width: 300,
  height: 300,
  fit: BoxFit.contain,
  animate: true,
  repeat: true,
)

// With animation controller
LaddingPageLottie(
  controller: _animationController,
  onLoaded: (composition) {
    _animationController.duration = composition.duration;
  },
)
```

## Components

### LogoGSMLGDEV

A `StatelessWidget` that renders a custom vector logo using `CustomPaint`.

| Property | Type | Description |
|----------|------|-------------|
| `key` | `Key?` | Widget key |
| `child` | `Widget?` | Optional child widget to overlay on the logo |

### LaddingPageLottie

A `StatelessWidget` wrapping `Lottie.asset` with the landing page animation.

| Property | Type | Description |
|----------|------|-------------|
| `controller` | `Animation<double>?` | Animation controller |
| `animate` | `bool?` | Whether to animate |
| `frameRate` | `FrameRate?` | Animation frame rate |
| `repeat` | `bool?` | Whether to loop |
| `reverse` | `bool?` | Whether to reverse |
| `width` | `double?` | Widget width |
| `height` | `double?` | Widget height |
| `fit` | `BoxFit?` | How to fit the animation |
| `alignment` | `AlignmentGeometry?` | Alignment within bounds |

See `Lottie.asset` documentation for the complete list of supported properties.

## Assets

The package includes bundled assets in `assets/`:
- `lottie/landing_page.json` - Landing page Lottie animation

Assets are referenced via the `packages/app_artwork/` path prefix for package asset resolution.
