import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Excepción de transporte HTTP para errores de comunicación con el backend.
class ApiException implements Exception {
  /// Mensaje descriptivo del error ocurrido.
  final String message;

  /// Código de estado HTTP opcional devuelto por el servidor.
  final int? statusCode;

  /// Construye una instancia de [ApiException].
  const ApiException(this.message, {this.statusCode});

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
  Map<String, String> _buildHeaders() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null && _authToken!.isNotEmpty)
        'Authorization': 'Bearer $_authToken',
    };
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
  }) async {
    try {
      final response = await _client.get(
        _buildUri(endpoint, queryParameters),
        headers: _buildHeaders(),
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
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
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

  /// Ejecuta una petición HTTP PUT real hacia el [endpoint] para actualizar recursos.
  ///
  /// Recibe el [body] con los campos actualizados y retorna la respuesta JSON decodificada.
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
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

  /// Evalúa el código de estado de [response] y decodifica el cuerpo JSON.
  dynamic _handleResponse(http.Response response) {
    final String rawBody = utf8.decode(response.bodyBytes);
    final dynamic decoded = rawBody.isNotEmpty ? jsonDecode(rawBody) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String errorMessage = 'Error HTTP ${response.statusCode}';
    if (decoded is Map<String, dynamic>) {
      errorMessage = (decoded['detail'] ??
              decoded['message'] ??
              decoded['error'] ??
              errorMessage)
          .toString();
    }
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }
}
