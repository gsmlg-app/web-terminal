# App Web View

A Flutter package for displaying local HTML files in a WebView with robust error handling and retry logic.

## Features

- **Local HTML Viewing**: Display local HTML files using `webview_flutter`
- **Automatic Retry**: Built-in retry mechanism (up to 5 attempts) for file loading failures
- **Gesture Support**: Full gesture recognition for scrolling, zooming, and tapping
- **Error Recovery**: User-friendly error display with retry button
- **Touch Scrolling**: Injected CSS for smooth touch-based scrolling

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_web_view:
    path: ../app_widget/web_view
```

## Usage

### Basic Usage

Display a local HTML file:

```dart
import 'package:app_web_view/app_web_view.dart';

// Display a local HTML file
LocalHtmlViewer(
  indexFile: '/path/to/document.html',
)
```

### In a Screen

```dart
class DocumentScreen extends StatelessWidget {
  final String documentPath;

  const DocumentScreen({
    super.key,
    required this.documentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document')),
      body: LocalHtmlViewer(
        indexFile: documentPath,
      ),
    );
  }
}
```

## Components

### LocalHtmlViewer

A `StatefulWidget` that loads and displays local HTML files.

| Property | Type | Description |
|----------|------|-------------|
| `key` | `Key?` | Widget key |
| `indexFile` | `String` | **Required.** Absolute path to the HTML file to display |

### Behavior

1. **Initialization**: On creation, attempts to load the specified HTML file
2. **Retry Logic**: If loading fails, automatically retries with increasing delays:
   - Attempts 1-2: 1 second delay
   - Attempts 3+: delay equals attempt number (3s, 4s, 5s)
3. **File Waiting**: Waits up to 4 seconds for newly created files to be available
4. **Error Display**: Shows error UI with retry button after all attempts fail

### Gesture Recognition

The widget registers gesture recognizers for:
- `VerticalDragGestureRecognizer` - Vertical scrolling
- `HorizontalDragGestureRecognizer` - Horizontal scrolling
- `ScaleGestureRecognizer` - Pinch to zoom
- `TapGestureRecognizer` - Tap interactions

### JavaScript Injection

After page load, CSS is injected to enable smooth scrolling:
```css
body, html {
  overflow: auto;
  -webkit-overflow-scrolling: touch;
}
```

## Dependencies

- `webview_flutter` - WebView rendering
- `app_logging` - Debug and error logging
- `app_locale` - Localized error messages

## Platform Support

This package requires native WebView support:
- **Android**: Uses Android WebView
- **iOS**: Uses WKWebView
- **macOS**: Uses WKWebView
- **Web**: Not supported (use iframe-based solutions)
