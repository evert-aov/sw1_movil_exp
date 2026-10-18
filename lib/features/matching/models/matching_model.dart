/// Modelo de dominio que representa un Grupo de Matching Dinámico para Quórum (CU-06 / HU-08, HU-09).
///
/// Mantiene responsabilidad única modelando el estado de agrupación de asistentes
/// compatibles interesados en activar una experiencia.
class MatchingModel {
  /// Identificador único del grupo de matching (UUID).
  final String id;

  /// Identificador de la experiencia asociada (UUID).
  final String experienceId;

  /// Título de la experiencia asociada.
  final String experienceTitle;

  /// Categoría temática de la experiencia.
  final String categoryName;

  /// Zona geográfica o modalidad donde se realiza.
  final String zone;

  /// Meta mínima de asistentes necesaria para confirmar el quórum.
  final int targetQuorum;

  /// Número actual de asistentes unidos al grupo.
  final int currentMembers;

  /// Capacidad máxima total del grupo.
  final int maxCapacity;

  /// Precio por asistente en Bolivianos (Bs.).
  final double price;

  /// Estado actual del grupo ('OPEN', 'CONFIRMED', 'EXPIRED').
  final String status;

  /// Fecha límite para consolidar el quórum mínimo.
  final DateTime deadline;

  /// Porcentaje de afinidad temática con los intereses del asistente (0 a 100).
  final int compatibilityScore;

  /// Indica si el asistente actual ya se ha postulado a este grupo.
  final bool hasJoined;

  /// Construye una instancia inmutable de [MatchingModel].
  const MatchingModel({
    required this.id,
    required this.experienceId,
    required this.experienceTitle,
    required this.categoryName,
    required this.zone,
    required this.targetQuorum,
    required this.currentMembers,
    required this.maxCapacity,
    required this.price,
    required this.status,
    required this.deadline,
    this.compatibilityScore = 92,
    this.hasJoined = false,
  });

  /// Evalúa si el grupo ya completó el quórum mínimo requerido.
  bool get isQuorumReached =>
      status == 'CONFIRMED' || currentMembers >= targetQuorum;

  /// Calcula cuántos miembros faltan para llegar a [targetQuorum].
  int get missingForQuorum =>
      (targetQuorum - currentMembers).clamp(0, targetQuorum);

  /// Calcula el progreso normalizado (0.0 a 1.0) hacia el quórum mínimo.
  double get progressRatio =>
      targetQuorum > 0 ? (currentMembers / targetQuorum).clamp(0.0, 1.0) : 0.0;

  /// Crea una copia actualizada del grupo de matching.
  MatchingModel copyWith({
    int? currentMembers,
    String? status,
    bool? hasJoined,
  }) {
    return MatchingModel(
      id: id,
      experienceId: experienceId,
      experienceTitle: experienceTitle,
      categoryName: categoryName,
      zone: zone,
      targetQuorum: targetQuorum,
      currentMembers: currentMembers ?? this.currentMembers,
      maxCapacity: maxCapacity,
      price: price,
      status: status ?? this.status,
      deadline: deadline,
      compatibilityScore: compatibilityScore,
      hasJoined: hasJoined ?? this.hasJoined,
    );
  }

  /// Construye una instancia de [MatchingModel] desde un mapa JSON.
  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
      id: (json['id'] ?? '').toString(),
      experienceId: (json['experience_id'] ?? '').toString(),
      experienceTitle: json['experience_title'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      targetQuorum: json['target_quorum'] as int? ?? 6,
      currentMembers: json['current_members'] as int? ?? 0,
      maxCapacity: json['max_capacity'] as int? ?? 12,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'OPEN',
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 3)),
      compatibilityScore: json['compatibility_score'] as int? ?? 90,
      hasJoined: json['has_joined'] as bool? ?? false,
    );
  }
}
