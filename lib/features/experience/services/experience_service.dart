import '../../../core/constants/api_constants.dart';
import '../../../core/network/http_client.dart';
import '../models/experience_filter_model.dart';
import '../models/experience_model.dart';

/// Servicio de dominio para la exploración de catálogo y detalle de experiencias (CU-04 / HU-05).
///
/// Mantiene alta cohesión y cero datos harcodeados: todas las experiencias se obtienen
/// dinámicamente desde el endpoint remoto [ApiConstants.experiencesEndpoint].
class ExperienceService {
  final HttpClient _httpClient;

  /// Crea una instancia de [ExperienceService] con inyección opcional de [HttpClient].
  ExperienceService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  /// Consulta el catálogo de experiencias en el backend aplicando los criterios de [filter] (CU-04 / HU-05).
  ///
  /// Envía los filtros como parámetros de consulta HTTP y transforma la lista JSON
  /// devuelta por el servidor en instancias de [ExperienceModel].
  Future<List<ExperienceModel>> getCatalog(ExperienceFilterModel filter) async {
    final Map<String, String> queryParams = <String, String>{
      if (filter.searchQuery.trim().isNotEmpty)
        'search': filter.searchQuery.trim(),
      if (filter.category.isNotEmpty && filter.category != 'Todos')
        'category': filter.category,
      if (filter.modality.isNotEmpty && filter.modality != 'ALL')
        'modality': filter.modality,
      if (filter.zone != null &&
          filter.zone!.trim().isNotEmpty &&
          filter.zone != 'Todas')
        'zone': filter.zone!.trim(),
    };

    final dynamic response = await _httpClient.get(
      ApiConstants.experiencesEndpoint,
      queryParameters: queryParams,
    );

    List<dynamic> rawList = const <dynamic>[];
    if (response is List<dynamic>) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      if (response['items'] is List<dynamic>) {
        rawList = response['items'] as List<dynamic>;
      } else if (response['data'] is List<dynamic>) {
        rawList = response['data'] as List<dynamic>;
      } else if (response['results'] is List<dynamic>) {
        rawList = response['results'] as List<dynamic>;
      }
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ExperienceModel.fromJson)
        .toList();
  }

  /// Consulta el detalle de una experiencia específica en el servidor por su identificador [id].
  Future<ExperienceModel?> getExperienceById(int id) async {
    final dynamic response = await _httpClient.get(
      '${ApiConstants.experiencesEndpoint}/$id',
    );
    if (response is Map<String, dynamic>) {
      final Map<String, dynamic> data =
          response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;
      return ExperienceModel.fromJson(data);
    }
    return null;
  }
}
