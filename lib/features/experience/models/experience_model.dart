/// Modelo de dominio de una Experiencia con cálculo de Quórum Mínimo (CU-04 / HU-05).
///
/// Representa exclusivamente los atributos y reglas de negocio de una actividad
/// disponible para los asistentes móviles.
class ExperienceModel {
  /// Identificador único de la experiencia.
  final String id;

  /// Título descriptivo de la experiencia.
  final String title;

  /// Descripción detallada de lo que incluye la sesión.
  final String description;

  /// URL de la imagen de portada del evento.
  final String? coverImageUrl;

  /// Modalidad del evento: 'IN_PERSON', 'VIRTUAL' o 'HYBRID'.
  final String modality;

  /// Nombre de la categoría temática.
  final String categoryName;

  /// Nombre del establecimiento o plataforma donde se realiza.
  final String? venueName;

  /// Zona o barrio urbano del evento.
  final String? zone;

  /// Dirección física exacta del establecimiento.
  final String? address;

  /// Precio unitario por asistente en Bolivianos (Bs.).
  final double price;

  /// Quórum mínimo de asistentes requerido para confirmar la realización del evento.
  final int minCapacity;

  /// Capacidad máxima total permitida en el evento.
  final int maxCapacity;

  /// Cantidad actual de cupos reservados o comprometidos.
  final int reservedSlots;

  /// Fecha y hora programada para el inicio del evento.
  final DateTime eventDate;

  /// Duración estimada de la experiencia en minutos.
  final int durationMinutes;

  /// Enlace de acceso en caso de modalidad virtual o híbrida.
  final String? virtualMeetingUrl;

  /// Indicador de confirmación por quórum alcanzado.
  final bool isQuorumReached;

  /// Construye una instancia inmutable de [ExperienceModel].
  const ExperienceModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.modality,
    this.categoryName = 'Experiencia',
    this.venueName,
    this.zone,
    this.address,
    required this.price,
    required this.minCapacity,
    required this.maxCapacity,
    required this.reservedSlots,
    required this.eventDate,
    this.durationMinutes = 120,
    this.virtualMeetingUrl,
    required this.isQuorumReached,
  });

  /// Evalúa si el evento ya alcanzó el quórum mínimo necesario para realizarse.
  bool get isConfirmed => isQuorumReached || reservedSlots >= minCapacity;

  /// Calcula cuántos asistentes faltan para alcanzar el quórum mínimo ([minCapacity]).
  int get slotsRemainingForQuorum =>
      (minCapacity - reservedSlots).clamp(0, minCapacity);

  /// Calcula cuántos cupos disponibles quedan antes de agotar el aforo máximo ([maxCapacity]).
  int get availableSlots => (maxCapacity - reservedSlots).clamp(0, maxCapacity);

  /// Calcula el porcentaje normalizado (0.0 a 1.0) de ocupación respecto al aforo máximo.
  double get quorumProgress =>
      maxCapacity > 0 ? (reservedSlots / maxCapacity).clamp(0.0, 1.0) : 0.0;

  /// Construye una instancia de [ExperienceModel] a partir de un mapa JSON.
  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String?,
      modality: json['modality'] as String? ?? 'IN_PERSON',
      categoryName: json['category_name'] as String? ?? 'General',
      venueName: json['venue_name'] as String?,
      zone: json['zone'] as String? ?? json['venue_zone'] as String?,
      address: json['address'] as String? ?? json['venue_address'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      minCapacity: json['min_capacity'] as int? ?? 5,
      maxCapacity: json['max_capacity'] as int? ?? 10,
      reservedSlots: json['reserved_slots'] as int? ?? 0,
      eventDate: DateTime.tryParse(json['event_date'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      durationMinutes: json['duration_minutes'] as int? ?? 120,
      virtualMeetingUrl: json['virtual_meeting_url'] as String?,
      isQuorumReached: json['is_quorum_reached'] as bool? ?? false,
    );
  }

  /// Convierte la instancia actual de [ExperienceModel] en un mapa JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'modality': modality,
      'category_name': categoryName,
      'venue_name': venueName,
      'zone': zone,
      'address': address,
      'price': price,
      'min_capacity': minCapacity,
      'max_capacity': maxCapacity,
      'reserved_slots': reservedSlots,
      'event_date': eventDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'virtual_meeting_url': virtualMeetingUrl,
      'is_quorum_reached': isQuorumReached,
    };
  }
}
