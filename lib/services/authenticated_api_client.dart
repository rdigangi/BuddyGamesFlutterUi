import 'package:http/http.dart' as http;

import '../core/app_navigator.dart';
import 'auth_api_service.dart';
import 'auth_session_service.dart';

class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException(this.message);

  @override
  String toString() => message;
}

class AuthenticatedApiClient {
  AuthenticatedApiClient._();

  static final AuthenticatedApiClient instance = AuthenticatedApiClient._();

  final _session = AuthSessionService.instance;
  final _authApi = AuthApiService.instance;

  Future<http.Response> send(
    Future<http.Response> Function(Map<String, String> headers) requestBuilder,
  ) async {
    final initialToken = _session.accessToken;
    if (initialToken == null) {
      throw SessionExpiredException('Sessione non disponibile');
    }

    final firstResponse = await requestBuilder(_buildJsonHeaders(initialToken));
    if (firstResponse.statusCode != 401) {
      return firstResponse;
    }

    final refreshResult = await _authApi.refresh();
    if (!refreshResult.isSuccess) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException(refreshResult.message);
    }

    final refreshedToken = _session.accessToken;
    if (refreshedToken == null) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException('Sessione scaduta');
    }

    final retryResponse = await requestBuilder(
      _buildJsonHeaders(refreshedToken),
    );
    if (retryResponse.statusCode == 401) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException('Sessione scaduta');
    }

    return retryResponse;
  }

  Future<http.Response> sendMultipart(
    Future<http.StreamedResponse> Function(Map<String, String> headers)
    requestBuilder,
  ) async {
    final initialToken = _session.accessToken;
    if (initialToken == null) {
      throw SessionExpiredException('Sessione non disponibile');
    }

    final firstStreamedResponse = await requestBuilder(
      _buildAuthHeaders(initialToken),
    );
    final firstResponse = await http.Response.fromStream(firstStreamedResponse);
    if (firstResponse.statusCode != 401) {
      return firstResponse;
    }

    final refreshResult = await _authApi.refresh();
    if (!refreshResult.isSuccess) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException(refreshResult.message);
    }

    final refreshedToken = _session.accessToken;
    if (refreshedToken == null) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException('Sessione scaduta');
    }

    final retryStreamedResponse = await requestBuilder(
      _buildAuthHeaders(refreshedToken),
    );
    final retryResponse = await http.Response.fromStream(retryStreamedResponse);
    if (retryResponse.statusCode == 401) {
      _session.clearSession();
      AppNavigator.goToLogin();
      throw SessionExpiredException('Sessione scaduta');
    }

    return retryResponse;
  }

  Map<String, String> _buildAuthHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, String> _buildJsonHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}
