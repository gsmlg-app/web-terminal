import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// Applies local policy to OSC 52 events from a terminal parser.
///
/// This deliberately has no clipboard reader or transport writer. Each session
/// defaults to trusted, subject to the global write policy. Manual revocation
/// lasts until the next session.
class RemoteClipboard {
  RemoteClipboard({
    required this.writesAllowed,
    Future<void> Function(String text)? writeClipboard,
  }) : _writeClipboard = writeClipboard ?? _writeNativeClipboard;

  static const maxDecodedBytes = 100 * 1024;
  static const _maxEncodedLength = ((maxDecodedBytes + 2) ~/ 3) * 4;
  static final _base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');

  final bool Function() writesAllowed;
  final Future<void> Function(String text) _writeClipboard;

  bool get sessionActive => _sessionActive;
  bool _sessionActive = false;
  bool get trusted => _trusted && writesAllowed();
  bool _trusted = false;
  int _generation = 0;
  (String, int)? _pending;
  bool _writing = false;

  void startSession() {
    _generation++;
    _pending = null;
    _trusted = true;
    _sessionActive = true;
  }

  void endSession() {
    _generation++;
    _pending = null;
    _trusted = false;
    _sessionActive = false;
  }

  void setTrusted(bool trusted) {
    _generation++;
    _pending = null;
    _trusted = trusted && _sessionActive && writesAllowed();
  }

  bool get _canWrite => _sessionActive && trusted;

  /// Receives parsed OSC arguments; incomplete sequences stay in the parser.
  void handleOSC(String code, List<String> args) {
    if (code != '52' || !_canWrite || args.length != 2) return;
    final selection = args[0];
    final payload = args[1];
    if (selection != 'c' && selection.isNotEmpty) return;
    if (payload == '?' ||
        payload.length > _maxEncodedLength ||
        !_base64Pattern.hasMatch(payload)) {
      return;
    }

    try {
      final bytes = base64.decode(payload);
      if (bytes.length > maxDecodedBytes) return;
      final text = utf8.decode(bytes);
      _pending = (text, _generation);
      if (!_writing) {
        _writing = true;
        unawaited(Future<void>.microtask(_drain));
      }
    } on FormatException {
      // Invalid Base64 or UTF-8 is not clipboard text.
    }
  }

  Future<void> _drain() async {
    try {
      while (_pending != null) {
        final (text, generation) = _pending!;
        _pending = null;
        if (generation != _generation || !_canWrite) continue;
        try {
          await _writeClipboard(text);
        } catch (_) {
          // Clipboard errors must not interrupt the terminal or expose data.
        }
      }
    } finally {
      _writing = false;
    }
  }

  static Future<void> _writeNativeClipboard(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
