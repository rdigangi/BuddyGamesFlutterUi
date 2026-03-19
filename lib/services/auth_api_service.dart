import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/app_config.dart';
import 'authenticated_api_client.dart';
import 'auth_session_service.dart';

class RegisterResult {
  final bool isSuccess;
  final String message;

  const RegisterResult({required this.isSuccess, required this.message});
}

class LoginResult {
  final bool isSuccess;
  final String message;

  const LoginResult({required this.isSuccess, required this.message});
}

class RefreshResult {
  final bool isSuccess;
  final String message;

  const RefreshResult({required this.isSuccess, required this.message});
}

class MeInfo {
  final String nome;
  final String cognome;
  final String email;
  final String? profileImageUrl;

  const MeInfo({
    required this.nome,
    required this.cognome,
    required this.email,
    this.profileImageUrl,
  });
}

class MeResult {
  final bool isSuccess;
  final String message;
  final MeInfo? data;

  const MeResult({required this.isSuccess, required this.message, this.data});
}

class ProfileImageUpdateResult {
  final bool isSuccess;
  final String message;
  final String? profileImageUrl;

  const ProfileImageUpdateResult({
    required this.isSuccess,
    required this.message,
    this.profileImageUrl,
  });
}

class AuthApiService {
  AuthApiService._();

  static final AuthApiService instance = AuthApiService._();
  final _session = AuthSessionService.instance;

  Future<RegisterResult> register({
    required String username,
    required String password,
    required String email,
    required String nome,
    required String cognome,
  }) async {
    try {
      final response = await http
          .post(
            AppConfig.registerUri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
              'email': email,
              'nome': nome,
              'cognome': cognome,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const RegisterResult(
          isSuccess: true,
          message: 'Registrazione completata',
        );
      }

      if (response.statusCode == 400) {
        return RegisterResult(
          isSuccess: false,
          message:
              _extractMessage(response.body) ??
              'Dati di registrazione non validi',
        );
      }

      return RegisterResult(
        isSuccess: false,
        message:
            _extractMessage(response.body) ??
            'Registrazione fallita (${response.statusCode})',
      );
    } catch (_) {
      return const RegisterResult(
        isSuccess: false,
        message: 'Errore di connessione al server',
      );
    }
  }

  Future<LoginResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            AppConfig.loginUri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'usernameOrEmail': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = _decodeMap(response.body);
        if (body == null) {
          return const LoginResult(
            isSuccess: false,
            message: 'Risposta login non valida',
          );
        }

        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'];
        final accessTokenExpiresAtUtc = body['accessTokenExpiresAtUtc'];
        final refreshTokenExpiresAtUtc = body['refreshTokenExpiresAtUtc'];
        final isAuthenticated = body['isAuthenticated'] == true;

        if (!isAuthenticated ||
            accessToken is! String ||
            refreshToken is! String ||
            accessTokenExpiresAtUtc is! String ||
            refreshTokenExpiresAtUtc is! String) {
          return LoginResult(
            isSuccess: false,
            message:
                _extractMessage(response.body) ?? 'Dati di login incompleti',
          );
        }

        final accessExpiry = DateTime.tryParse(accessTokenExpiresAtUtc);
        final refreshExpiry = DateTime.tryParse(refreshTokenExpiresAtUtc);
        if (accessExpiry == null || refreshExpiry == null) {
          return const LoginResult(
            isSuccess: false,
            message: 'Formato date token non valido',
          );
        }

        _session.saveSession(
          accessToken: accessToken,
          accessTokenExpiresAtUtc: accessExpiry,
          refreshToken: refreshToken,
          refreshTokenExpiresAtUtc: refreshExpiry,
        );

        return LoginResult(
          isSuccess: true,
          message:
              _extractMessage(response.body) ?? 'Login effettuato con successo',
        );
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        return LoginResult(
          isSuccess: false,
          message:
              _extractMessage(response.body) ??
              (response.statusCode == 401
                  ? 'Credenziali non valide'
                  : 'Richiesta non valida'),
        );
      }

      return LoginResult(
        isSuccess: false,
        message:
            _extractMessage(response.body) ??
            'Login fallito (${response.statusCode})',
      );
    } catch (_) {
      return const LoginResult(
        isSuccess: false,
        message: 'Errore di connessione al server',
      );
    }
  }

  Future<RefreshResult> refresh() async {
    final refreshToken = _session.refreshToken;
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return const RefreshResult(
        isSuccess: false,
        message: 'Refresh token non disponibile',
      );
    }

    if (_session.isRefreshTokenExpired) {
      return const RefreshResult(
        isSuccess: false,
        message: 'Refresh token scaduto',
      );
    }

    try {
      final response = await http
          .post(
            AppConfig.refreshUri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = _decodeMap(response.body);
        if (body == null) {
          return const RefreshResult(
            isSuccess: false,
            message: 'Risposta refresh non valida',
          );
        }

        final newAccessToken = body['accessToken'];
        final newRefreshToken = body['refreshToken'];
        final newAccessTokenExpiresAtUtc = body['accessTokenExpiresAtUtc'];
        final newRefreshTokenExpiresAtUtc = body['refreshTokenExpiresAtUtc'];

        if (newAccessToken is! String ||
            newRefreshToken is! String ||
            newAccessTokenExpiresAtUtc is! String ||
            newRefreshTokenExpiresAtUtc is! String) {
          return const RefreshResult(
            isSuccess: false,
            message: 'Dati refresh incompleti',
          );
        }

        final accessExpiry = DateTime.tryParse(newAccessTokenExpiresAtUtc);
        final refreshExpiry = DateTime.tryParse(newRefreshTokenExpiresAtUtc);
        if (accessExpiry == null || refreshExpiry == null) {
          return const RefreshResult(
            isSuccess: false,
            message: 'Formato date token non valido',
          );
        }

        _session.saveSession(
          accessToken: newAccessToken,
          accessTokenExpiresAtUtc: accessExpiry,
          refreshToken: newRefreshToken,
          refreshTokenExpiresAtUtc: refreshExpiry,
        );

        return const RefreshResult(
          isSuccess: true,
          message: 'Token aggiornati',
        );
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        return RefreshResult(
          isSuccess: false,
          message:
              _extractMessage(response.body) ??
              (response.statusCode == 401
                  ? 'Refresh token non valido o scaduto'
                  : 'Richiesta refresh non valida'),
        );
      }

      return RefreshResult(
        isSuccess: false,
        message:
            _extractMessage(response.body) ??
            'Refresh fallito (${response.statusCode})',
      );
    } catch (_) {
      return const RefreshResult(
        isSuccess: false,
        message: 'Errore di connessione al server',
      );
    }
  }

  Future<MeResult> getMe() async {
    try {
      final response = await AuthenticatedApiClient.instance.send(
        (headers) => http
            .get(AppConfig.meUri, headers: headers)
            .timeout(const Duration(seconds: 15)),
      );

      if (response.statusCode == 200) {
        final body = _decodeMap(response.body);
        if (body == null) {
          return const MeResult(
            isSuccess: false,
            message: 'Risposta /me non valida',
          );
        }

        final source = _extractProfileMap(body);
        final nome = _readString(source, const [
          'nome',
          'firstName',
          'givenName',
        ]);
        final cognome = _readString(source, const [
          'cognome',
          'lastName',
          'familyName',
        ]);
        final email = _readString(source, const ['email', 'mail']);
        final profileImageUrl = _readNullableString(source, const [
          'profileImageUrl',
          'avatarUrl',
        ]);

        if (nome == null || cognome == null || email == null) {
          return const MeResult(
            isSuccess: false,
            message: 'Dati utente incompleti dalla /me',
          );
        }

        return MeResult(
          isSuccess: true,
          message: 'Dati utente recuperati',
          data: MeInfo(
            nome: nome,
            cognome: cognome,
            email: email,
            profileImageUrl: profileImageUrl,
          ),
        );
      }

      return MeResult(
        isSuccess: false,
        message:
            _extractMessage(response.body) ??
            'Recupero dati utente fallito (${response.statusCode})',
      );
    } catch (_) {
      return const MeResult(
        isSuccess: false,
        message: 'Errore di connessione al server',
      );
    }
  }

  Future<ProfileImageUpdateResult> uploadProfileImage({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final response = await AuthenticatedApiClient.instance.sendMultipart((
        headers,
      ) {
        final request = http.MultipartRequest(
          'POST',
          AppConfig.meProfileImageUri,
        );
        request.headers.addAll(headers);
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        return request.send().timeout(const Duration(seconds: 30));
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = _decodeMap(response.body);
        final source = body == null ? null : _extractProfileMap(body);
        final profileImageUrl = source == null
            ? null
            : _readNullableString(source, const [
                'profileImageUrl',
                'avatarUrl',
              ]);

        return ProfileImageUpdateResult(
          isSuccess: true,
          message: 'Immagine profilo aggiornata',
          profileImageUrl: profileImageUrl,
        );
      }

      return ProfileImageUpdateResult(
        isSuccess: false,
        message:
            _extractMessage(response.body) ??
            'Upload immagine fallito (${response.statusCode})',
      );
    } catch (_) {
      return const ProfileImageUpdateResult(
        isSuccess: false,
        message: 'Errore di connessione al server',
      );
    }
  }

  void logout() {
    _session.clearSession();
  }

  Map<String, dynamic>? _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          final details = <String>[];
          for (final entry in errors.entries) {
            final value = entry.value;
            if (value is List) {
              for (final item in value) {
                if (item is String && item.trim().isNotEmpty) {
                  details.add(item.trim());
                }
              }
            }
          }

          if (details.isNotEmpty) {
            return details.join('\n');
          }
        }

        final message =
            decoded['message'] ?? decoded['error'] ?? decoded['title'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      if (body.trim().isNotEmpty) {
        return body;
      }
    }

    return null;
  }

  Map<String, dynamic> _extractProfileMap(Map<String, dynamic> body) {
    final userNode = body['user'];
    if (userNode is Map<String, dynamic>) {
      return userNode;
    }

    final dataNode = body['data'];
    if (dataNode is Map<String, dynamic>) {
      return dataNode;
    }

    return body;
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  String? _readNullableString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is String) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
    }

    return null;
  }
}
