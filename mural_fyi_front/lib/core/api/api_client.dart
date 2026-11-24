import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient({
    required AuthSession session,
    http.Client? client,
  })  : _session = session,
        _client = client ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final http.Client _client;
  final AuthSession _session;

  Uri buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final normalizedPath =
        path.startsWith('/') ? path : '/$path';

    return Uri.parse('$root$normalizedPath').replace(
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) =>
      _request(
        'GET',
        path,
        queryParameters: queryParameters,
      );

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) =>
      _request('POST', path, body: body);

  Future<dynamic> patch(
    String path, [
    Map<String, dynamic>? body,
  ]) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) =>
      _request('DELETE', path);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final token =
        path == '/auth/login' ? null : _session.token;

    final request = http.Request(
      method,
      buildUri(path, queryParameters: queryParameters),
    );

    request.headers['Accept'] = 'application/json';

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 401 &&
          token != null &&
          _session.token == token) {
        _session.clear();
      }

      return _decodeResponse(response);
    } on http.ClientException catch (error) {
      throw ApiException(
        'Falha na conexão com a API: ${error.message}',
      );
    } on TimeoutException {
      throw const ApiException(
        'A API demorou para responder. Tente novamente.',
      );
    }
  }

  dynamic _decodeResponse(http.Response response) {
    dynamic body;

    try {
      body = response.bodyBytes.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        throw const ApiException(
          'A API retornou um JSON inválido.',
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }

    String message = switch (response.statusCode) {
      401 => 'Não autorizado. Faça login novamente.',
      403 => 'Você não tem permissão para realizar esta operação.',
      _ => 'Erro HTTP ${response.statusCode}',
    };

    if (body is Map<String, dynamic>) {
      final detail = body['detail'];
      final title = body['title'];

      if (detail is String && detail.isNotEmpty) {
        message = detail;
      } else if (title is String && title.isNotEmpty) {
        message = title;
      }
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  void close() => _client.close();
}