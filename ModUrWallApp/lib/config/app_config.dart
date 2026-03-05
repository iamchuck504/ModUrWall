/// Runtime configuration loaded via --dart-define-from-file.
///
/// Run commands:
///   flutter run  --dart-define-from-file=config/dev.json
///   flutter run  --dart-define-from-file=config/prod.json
///   flutter build apk --dart-define-from-file=config/prod.json
///
/// To merge secrets (local only, gitignored):
///   flutter run  --dart-define-from-file=config/dev.json \
///                --dart-define-from-file=config/secrets.json
///
/// All keys must be declared as String.fromEnvironment so the Flutter
/// tool can tree-shake them into the binary at compile time.
abstract class AppConfig {
  /// Base URL for the Lempyrλ ClearingHouse OAuth 2.0 server.
  /// dev  → http://auth.lempyra.com:7777
  /// prod → https://auth.lempyra.com
  static const authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'http://auth.lempyra.com:7777',
  );

  /// Base URL for the ModUrWall generation API.
  /// Endpoint: POST $apiBaseUrl/modurwall/generate
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.lempyra.com',
  );

  /// OAuth 2.0 client_id registered with Lempyrλ ClearingHouse.
  /// Pending: coordinate with Lempyrλ to register ModUrWall as a client.
  static const clientId = String.fromEnvironment(
    'MODURWALL_CLIENT_ID',
    defaultValue: 'modurwall_dev',
  );

  /// OAuth 2.0 client_secret — only needed if NOT using PKCE.
  /// For mobile apps PKCE is recommended (no secret required).
  /// Keep in config/secrets.json (gitignored) if used.
  static const clientSecret = String.fromEnvironment(
    'MODURWALL_CLIENT_SECRET',
    defaultValue: '',
  );
}
