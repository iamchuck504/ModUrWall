/// ClearingHouse OAuth 2.0 — Lempyrλ auth server
///
/// Base URL resolved from AppConfig.authBaseUrl at compile time:
///   dev  → http://auth.lempyra.com:7777  (config/dev.json)
///   prod → https://auth.lempyra.com      (config/prod.json)
///
/// When implementing LempyraAuthService, add:
///   import '../config/app_config.dart';
///   final baseUrl = AppConfig.authBaseUrl;
///
/// Docs: {AppConfig.authBaseUrl}/docs
///
/// 3-step flow:
///   1. POST /register  { username, password, email }
///   2. POST /authorize { username, password, client_id, scope } → auth_code
///   3. POST /token     { grant_type: authorization_code, code, client_id, client_secret } → JWT + refresh_token
///
/// Refresh: POST /token { grant_type: refresh_token, refresh_token }
/// Logout:  POST /revoke { token }
///
/// Open items before real implementation:
///   [ ] Register ModUrWall → get client_id (not "portal") → set in config/dev.json
///   [ ] Define scopes (e.g. wallpaper,generate,profile)
///   [ ] Confirm JWT payload structure — does it include tier/plan claim?
///   [ ] Decide PKCE vs client_secret (PKCE recommended for mobile — no secret needed)

/// Abstract interface — UI depends only on this.
abstract class AuthService {
  /// POST /register — create new account
  Future<bool> register(String username, String password, String email);

  /// Combines POST /authorize + POST /token into one user-facing action.
  Future<bool> login(String username, String password);

  /// POST /token with grant_type: refresh_token
  Future<bool> refreshToken();

  /// POST /revoke — invalidate current token
  Future<void> logout();

  /// Returns the current JWT access token for Authorization: Bearer header.
  Future<String?> getAccessToken();

  bool get isAuthenticated;

  /// Derived from JWT claims — "free" | "premium"
  /// Exact claim key TBD pending Lempyrλ JWT payload spec.
  String get currentTier;
}

/// v0 mock — no network calls. Simulates auth state in memory.
class MockAuthService implements AuthService {
  bool _authenticated = false;
  String _tier = 'free';

  @override
  Future<bool> register(String username, String password, String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _authenticated = true;
    _tier = 'free';
    return true;
  }

  @override
  Future<bool> refreshToken() async => _authenticated;

  @override
  Future<void> logout() async {
    _authenticated = false;
  }

  @override
  Future<String?> getAccessToken() async =>
      _authenticated ? 'mock_jwt_token' : null;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String get currentTier => _tier;
}
