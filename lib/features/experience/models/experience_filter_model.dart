/// Modelo de Criterios de Filtrado del Catálogo de Experiencias (CU-04 / HU-05).
///
/// Separado en su propio archivo bajo el principio de responsabilidad única
/// para encapsular los parámetros de consulta del asistente móvil.
class ExperienceFilterModel {
  /// Término libre de búsqueda por título, descripción o zona.
  final String searchQuery;

  /// Categoría seleccionada ('Todos' o nombre de categoría específica).
  final String category;

  /// Identificador opcional de categoría (UUID) para consulta directa en backend.
  final String? categoryId;

  /// Modalidad seleccionada ('ALL', 'IN_PERSON', 'VIRTUAL', 'HYBRID').
  final String modality;

  /// Zona geográfica opcional para filtrado por cercanía.
  final String? zone;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final int page;
  final bool onlyAvailable;

  /// Crea una instancia inmutable de [ExperienceFilterModel].
  const ExperienceFilterModel({
    this.searchQuery = '',
    this.category = 'Todos',
    this.categoryId,
    this.modality = 'ALL',
    this.zone,
    this.dateFrom,
    this.dateTo,
    this.latitude,
    this.longitude,
    this.radiusKm = 10,
    this.page = 1,
    this.onlyAvailable = false,
  });

  /// Retorna una nueva instancia copiando los valores actuales y aplicando cambios.
  ExperienceFilterModel copyWith({
    String? searchQuery,
    String? category,
    String? categoryId,
    bool clearCategoryId = false,
    String? modality,
    String? zone,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? page,
    bool? onlyAvailable,
    bool clearAdvanced = false,
  }) {
    return ExperienceFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      modality: modality ?? this.modality,
      zone: zone ?? this.zone,
      dateFrom: clearAdvanced ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearAdvanced ? null : (dateTo ?? this.dateTo),
      latitude: clearAdvanced ? null : (latitude ?? this.latitude),
      longitude: clearAdvanced ? null : (longitude ?? this.longitude),
      radiusKm: radiusKm ?? this.radiusKm,
      page: page ?? 1,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }
}
