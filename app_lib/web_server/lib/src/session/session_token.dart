import 'dart:convert';
import 'dart:math';

/// A secure session token for web terminal authentication.
class SessionToken {
  /// Unique identifier for this token.
  final String id;

  /// The actual token string used for authentication.
  final String token;

  /// When the token was created.
  final DateTime createdAt;

  /// When the token expires.
  final DateTime expiresAt;

  /// Optional user-provided label for identification.
  final String? label;

  SessionToken({
    required this.id,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    this.label,
  });

  /// Generate a new secure session token.
  factory SessionToken.generate({
    Duration validity = const Duration(hours: 24),
    String? label,
  }) {
    final id = _generateId();
    final token = _generateSecureToken();
    final now = DateTime.now();

    return SessionToken(
      id: id,
      token: token,
      createdAt: now,
      expiresAt: now.add(validity),
      label: label,
    );
  }

  /// Generate a short unique ID.
  static String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(8, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Generate a 256-bit secure token.
  static String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Check if the token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the token is valid (not expired).
  bool get isValid => !isExpired;

  /// Time remaining until expiry.
  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Convert to JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'label': label,
      };

  /// Create from JSON map.
  factory SessionToken.fromJson(Map<String, dynamic> json) => SessionToken(
        id: json['id'] as String,
        token: json['token'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        label: json['label'] as String?,
      );

  @override
  String toString() =>
      'SessionToken(id: $id, label: $label, expiresAt: $expiresAt)';
}
