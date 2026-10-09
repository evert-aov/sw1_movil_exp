// Cliente HTTP base: únicamente firmas de métodos para llamadas a la API
class HttpClient {
  Future<Map<String, dynamic>?> get(String endpoint, {Map<String, String>? headers}) async {
    // Firma para peticiones GET
    return null;
  }

  Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    // Firma para peticiones POST
    return null;
  }

  Future<Map<String, dynamic>?> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    // Firma para peticiones PUT
    return null;
  }
}
