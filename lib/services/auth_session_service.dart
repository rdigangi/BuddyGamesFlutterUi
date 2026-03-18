import 'dart:convert';

class AuthSessionService {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();

  String? _accessToken;
  DateTime? _accessTokenExpiresAtUtc;
  String? _refreshToken;
  DateTime? _refreshTokenExpiresAtUtc;

  String? _userId;
  String? _givenName;
  String? _username;
  String? _email;
  List<String> _roles = const [];

  String? get accessToken => _accessToken;
  DateTime? get accessTokenExpiresAtUtc => _accessTokenExpiresAtUtc;
  String? get refreshToken => _refreshToken;
  DateTime? get refreshTokenExpiresAtUtc => _refreshTokenExpiresAtUtc;

  String? get userId => _userId;
  String? get givenName => _givenName;
  String? get username => _username;
  String? get email => _email;
  List<String> get roles => List.unmodifiable(_roles);

  bool get hasSession => _accessToken != null;

  bool get isAccessTokenExpired {
    final expiresAt = _accessTokenExpiresAtUtc;
    if (expiresAt == null) return true;

    return DateTime.now().toUtc().isAfter(
      expiresAt.subtract(const Duration(seconds: 20)),
    );
  }

  bool get isRefreshTokenExpired {
    final expiresAt = _refreshTokenExpiresAtUtc;
    if (expiresAt == null) return true;

    return DateTime.now().toUtc().isAfter(
      expiresAt.subtract(const Duration(seconds: 20)),
    );
  }

  void saveSession({
    required String accessToken,
    required DateTime accessTokenExpiresAtUtc,
    required String refreshToken,
    required DateTime refreshTokenExpiresAtUtc,
  }) {
    _accessToken = accessToken;
    _accessTokenExpiresAtUtc = accessTokenExpiresAtUtc.toUtc();
    _refreshToken = refreshToken;
    _refreshTokenExpiresAtUtc = refreshTokenExpiresAtUtc.toUtc();

    _applyClaimsFromAccessToken(accessToken);
  }

  void clearSession() {
    _accessToken = null;
    _accessTokenExpiresAtUtc = null;
    _refreshToken = null;
    _refreshTokenExpiresAtUtc = null;

    _userId = null;
    _givenName = null;
    _username = null;
    _email = null;
    _roles = const [];
  }

  void _applyClaimsFromAccessToken(String token) {
    final claims = _decodeJwtPayload(token);

    _userId = _readStringClaim(claims, const ['sub', 'nameid']);
    _givenName = _readStringClaim(
      claims,
      const [
        'nome',
        'given_name',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname',
      ],
    );
    _username = _readStringClaim(
      claims,
      const [
        'username',
        'unique_name',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
      ],
    );
    _email = _readStringClaim(
      claims,
      const [
        'email',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
      ],
    );
    _roles = _readRoles(claims);
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return const {};

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);

    try {
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) {
        return json;
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  String? _readStringClaim(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  List<String> _readRoles(Map<String, dynamic> claims) {
    final roleValue = claims['role'] ??
        claims['roles'] ??
        claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (roleValue is String && roleValue.trim().isNotEmpty) {
      return [roleValue.trim()];
    }

    if (roleValue is List) {
      return roleValue
          .whereType<String>()
          .map((r) => r.trim())
          .where((r) => r.isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }
}
