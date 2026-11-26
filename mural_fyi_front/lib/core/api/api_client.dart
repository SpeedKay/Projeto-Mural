import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
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
    final request = http.Request(
      method,
      buildUri(path, queryParameters: queryParameters),
    );

    request.headers['Accept'] = 'application/json';

    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    return _send(request);
  }

  Future<dynamic> multipart(
      String method,
      String path,
      Map<String, dynamic> data, {
        Uint8List? photo,
      }) {
    final request = http.MultipartRequest(
      method,
      buildUri(path),
    );

    request.headers['Accept'] =
    'application/json, application/problem+json';

    request.files.add(
      http.MultipartFile.fromString(
        'item',
        jsonEncode(data),
        contentType: MediaType('application', 'json'),
      ),
    );

    if (photo != null) {
      final png = photo.isNotEmpty && photo.first == 137;

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photo,
          filename: png ? 'photo.png' : 'photo.jpg',
          contentType: MediaType(
            'image',
            png ? 'png' : 'jpeg',
          ),
        ),
      );
    }

    return _send(request);
  }

  Future<Uint8List> getBytes(String path) async {
    final request = http.Request(
      'GET',
      buildUri(path),
    );

    request.headers['Accept'] =
    'image/png, image/jpeg, application/problem+json';

    final result = await _send(
      request,
      binary: true,
    );

    return result as Uint8List;
  }

  Future<dynamic> _send(
      http.BaseRequest request, {
        bool binary = false,
      }) async {
    final token = request.url.path == '/auth/login'
        ? null
        : _session.token;

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
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

      if (binary &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return response.bodyBytes;
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