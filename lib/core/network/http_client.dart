import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Excepción de transporte HTTP para errores de comunicación con el backend.
class ApiException implements Exception {
  /// Mensaje descriptivo del error ocurrido.
  final String message;

  /// Código de estado HTTP opcional devuelto por el servidor.
  final int? statusCode;

  /// Stable diagnostic code returned by the API, when available.
  final String? code;

  /// Request correlation identifier returned by the API, when available.
  final String? requestId;

  /// Construye una instancia de [ApiException].
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.requestId,
  });

  @override
  String toString() => message;
}

/// Cliente HTTP desacoplado encargado exclusivamente del transporte de peticiones REST.
///
/// Cumple con el principio de responsabilidad única y bajo acoplamiento
/// ejecutando peticiones reales hacia [ApiConstants.baseUrl] y gestionando
/// la cabecera de autorización JWT sin contener lógica de dominio.
class HttpClient {
  final http.Client _client;

  /// Token JWT en memoria de la sesión autenticada actual.
  static String? _authToken;

  /// Crea una instancia de [HttpClient] permitiendo inyectar un [http.Client].
  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  /// Define o limpia el token JWT activo para las peticiones autenticadas.
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Obtiene el token JWT activo si existe una sesión iniciada.
  static String? get authToken => _authToken;

  /// Construye las cabeceras HTTP estándar incluyendo el token Bearer si está presente.
  Map<String, String> _buildHeaders([Map<String, String> supplied = const {}]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null && _authToken!.isNotEmpty)
        'Authorization': 'Bearer $_authToken',
    };
    final callerId = _headerValue(supplied, 'x-request-id');
    final requestId = callerId != null && _isUuidV4(callerId)
        ? callerId
        : _newUuidV4();
    headers.addAll(supplied);
    headers.removeWhere((key, _) => key.toLowerCase() == 'x-request-id');
    headers['X-Request-ID'] = requestId;
    return headers;
  }

  static final Random _random = Random.secure();
  static final RegExp _uuidV4 = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _errorCode = RegExp(r'^[A-Z][A-Z0-9_.-]{0,79}$');

  static bool _isUuidV4(String value) => _uuidV4.hasMatch(value);

  static String? _headerValue(Map<String, String> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value;
    }
    return null;
  }

  static String _newUuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  /// Construye el objeto [Uri] completo a partir del [endpoint] y los [queryParameters].
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final cleanParams = <String, String>{};
    if (queryParameters != null) {
      queryParameters.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          cleanParams[key] = value.trim();
        }
      });
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return cleanParams.isEmpty
        ? uri
        : uri.replace(queryParameters: cleanParams);
  }

  /// Ejecuta una petición HTTP GET real hacia el [endpoint] indicado.
  ///
  /// Retorna el cuerpo JSON decodificado (`dynamic`, que puede ser `Map` o `List`).
  /// Lanza [ApiException] si el servidor responde con un código de error o falla la red.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String> headers = const <String, String>{},
  }) async {
    try {
      final response = await _client.get(
        _buildUri(endpoint, queryParameters),
        headers: _buildHeaders(headers),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// Ejecuta una petición HTTP POST real hacia el [endpoint] enviando el [body] serializado.
  ///
  /// Retorna el cuerpo JSON decodificado o lanza [ApiException] en caso de error.
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String> headers = const <String, String>{},
  }) async {
    try {
      final response = await _client.post(
        _buildUri(endpoint),
        headers: _buildHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// Ejecuta una petición HTTP PUT real hacia el [endpoint] para actualizar recursos.
  ///
  /// Recibe el [body] con los campos actualizados y retorna la respuesta JSON decodificada.
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client.put(
        _buildUri(endpoint),
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.patch(
      _buildUri(endpoint),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await _client.delete(
      _buildUri(endpoint),
      headers: _buildHeaders(),
    );
    return _handleResponse(response);
  }

  /// Evalúa el código de estado de [response] y decodifica el cuerpo JSON.
  dynamic _handleResponse(http.Response response) {
    final String rawBody = utf8.decode(
      response.bodyBytes,
      allowMalformed: true,
    );
    dynamic decoded;
    if (rawBody.isNotEmpty) {
      try {
        decoded = jsonDecode(rawBody);
      } on FormatException {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String errorMessage = 'Error HTTP ${response.statusCode}';
    if (decoded is Map<String, dynamic>) {
      errorMessage =
          (decoded['detail'] ??
                  decoded['message'] ??
                  decoded['error'] ??
                  errorMessage)
              .toString();
    }
    final bodyCode = decoded is Map ? decoded['code'] : null;
    final bodyRequestId = decoded is Map ? decoded['request_id'] : null;
    final headerRequestId = _headerValue(response.headers, 'x-request-id');
    final requestId = bodyRequestId is String && _uuidV4.hasMatch(bodyRequestId)
        ? bodyRequestId
        : headerRequestId != null && _uuidV4.hasMatch(headerRequestId)
        ? headerRequestId
        : null;
    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      code: bodyCode is String && _errorCode.hasMatch(bodyCode.toUpperCase())
          ? bodyCode.toUpperCase()
          : null,
      requestId: requestId,
    );
  }
}
