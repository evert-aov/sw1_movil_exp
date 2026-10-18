/// Modelo de Criterios de Filtrado del Catálogo de Experiencias (CU-04 / HU-05).
///
/// Separado en su propio archivo bajo el principio de responsabilidad única
/// para encapsular los parámetros de consulta del asistente móvil.
class ExperienceFilterModel {
  /// Término libre de búsqueda por título, descripción o zona.
  final String searchQuery;

  /// Categoría seleccionada ('Todos' o nombre de categoría específica).
  final String category;

  /// Modalidad seleccionada ('ALL', 'IN_PERSON', 'VIRTUAL', 'HYBRID').
  final String modality;

  /// Zona geográfica opcional para filtrado por cercanía.
  final String? zone;

  /// Crea una instancia inmutable de [ExperienceFilterModel].
  const ExperienceFilterModel({
    this.searchQuery = '',
    this.category = 'Todos',
    this.modality = 'ALL',
    this.zone,
  });

  /// Retorna una nueva instancia copiando los valores actuales y aplicando cambios.
  ExperienceFilterModel copyWith({
    String? searchQuery,
    String? category,
    String? modality,
    String? zone,
  }) {
    return ExperienceFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      modality: modality ?? this.modality,
      zone: zone ?? this.zone,
    );
  }
}
