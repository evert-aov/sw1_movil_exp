import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';
import '../../../core/network/request_key.dart';
import '../models/experience_filter_model.dart';
import '../models/experience_model.dart';

/// Servicio de dominio para la exploración de catálogo y detalle de experiencias (CU-04 / HU-05).
///
/// Mantiene alta cohesión y cero datos harcodeados: todas las experiencias se obtienen
/// dinámicamente desde el endpoint remoto [ApiConstants.experiencesCatalogEndpoint].
class ExperienceService {
  static final _searchSession = newRequestKey();
  final HttpClient _httpClient;
  int totalPages = 1;
  int _catalogSequence = 0;
  int totalResults = 0;

  /// Caché en memoria para resolver nombres de categorías a sus identificadores UUID.
  static final Map<String, String> _categoryCache = <String, String>{};

  /// Crea una instancia de [ExperienceService] con inyección opcional de [HttpClient].
  ExperienceService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  /// Obtiene la lista oficial de categorías temáticas desde el servidor (`GET /api/categories`).
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final dynamic response = await _httpClient.get(
        ApiConstants.categoriesEndpoint,
      );
      if (response is List<dynamic>) {
        final list = response.whereType<Map<String, dynamic>>().toList();
        for (final item in list) {
          final String? id = item['id']?.toString();
          final String? name = item['name'] as String?;
          if (id != null && name != null && name.trim().isNotEmpty) {
            _categoryCache[name.trim()] = id;
          }
        }
        return list;
      }
    } catch (_) {
      rethrow;
    }
    return const <Map<String, dynamic>>[];
  }

  /// Consulta el catálogo de experiencias en el backend aplicando los criterios de [filter] (CU-04 / HU-05).
  ///
  /// Envía los filtros como parámetros de consulta HTTP y transforma la lista JSON
  /// devuelta por el servidor en instancias de [ExperienceModel].
  Future<List<ExperienceModel>> getCatalog(ExperienceFilterModel filter) async {
    final request = ++_catalogSequence;
    if ((filter.latitude == null) != (filter.longitude == null)) {
      throw const ApiException('Completa latitud y longitud.');
    }
    String? catId = filter.categoryId;
    if (catId == null &&
        filter.category.isNotEmpty &&
        filter.category != 'Todos') {
      catId = _categoryCache[filter.category];
    }

    final Map<String, String> queryParams = <String, String>{
      'page_size': '12',
      'page': filter.page.toString(),
      'only_available': filter.onlyAvailable.toString(),
      if (filter.dateFrom != null)
        'date_from': _calendarDate(filter.dateFrom!, false),
      if (filter.dateTo != null) 'date_to': _calendarDate(filter.dateTo!, true),
      if (filter.latitude != null) 'latitude': filter.latitude.toString(),
      if (filter.longitude != null) 'longitude': filter.longitude.toString(),
      if (filter.latitude != null && filter.longitude != null)
        'radius_km': filter.radiusKm.toString(),
      if (filter.searchQuery.trim().isNotEmpty)
        'search': filter.searchQuery.trim(),
      if (catId != null && catId.isNotEmpty) 'category_id': catId,
      if (filter.modality.isNotEmpty && filter.modality != 'ALL')
        'modality': filter.modality,
      if (filter.zone != null &&
          filter.zone!.trim().isNotEmpty &&
          filter.zone != 'Todas')
        'zone': filter.zone!.trim(),
    };

    final dynamic response = await _httpClient.get(
      ApiConstants.experiencesCatalogEndpoint,
      queryParameters: queryParams,
        headers: {'X-Search-Session': _searchSession},
    );

    List<dynamic> rawList = const <dynamic>[];
    if (response is List<dynamic>) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      if (request == _catalogSequence) {
        totalPages = response['total_pages'] as int? ?? 1;
        totalResults = response['total'] as int? ?? 0;
      }
      if (response['experiences'] is List<dynamic>) {
        rawList = response['experiences'] as List<dynamic>;
      } else if (response['items'] is List<dynamic>) {
        rawList = response['items'] as List<dynamic>;
      } else if (response['data'] is List<dynamic>) {
        rawList = response['data'] as List<dynamic>;
      } else if (response['results'] is List<dynamic>) {
        rawList = response['results'] as List<dynamic>;
      }
    }

    List<ExperienceModel> result = rawList
        .whereType<Map<String, dynamic>>()
        .map(ExperienceModel.fromJson)
        .toList();

    // Filtro cliente como fallback si se seleccionó una categoría que aún no tiene ID en caché
    if (filter.category.isNotEmpty &&
        filter.category != 'Todos' &&
        catId == null) {
      result = result
          .where(
            (exp) => exp.categoryName.toLowerCase().contains(
              filter.category.toLowerCase(),
            ),
          )
          .toList();
    }

    return result;
  }

  /// Interpreta los días de búsqueda en hora de Bolivia, independientemente del dispositivo.
  String _calendarDate(DateTime value, bool endOfDay) {
    final day =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return DateTime.parse(
      '${day}T${endOfDay ? '23:59:59.999' : '00:00:00'}-04:00',
    ).toUtc().toIso8601String();
  }

  /// Consulta el detalle de una experiencia específica en el servidor por su identificador [id] (UUID).
  Future<ExperienceModel?> getExperienceById(String id) async {
    final dynamic response = await _httpClient.get(
      '${ApiConstants.experiencesEndpoint}/$id',
    );
    if (response is Map<String, dynamic>) {
      final Map<String, dynamic> data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return ExperienceModel.fromJson(data);
    }
    return null;
  }
}
