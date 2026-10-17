// Modelo de Experiencia en Flutter con soporte de Quórum y Geolocalización (CU-05 / HU-05)
class ExperienceModel {
  final int id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String modality; // 'IN_PERSON', 'VIRTUAL', 'HYBRID'
  final String categoryName;
  final String? venueName;
  final String? zone;
  final String? address;
  final double price;
  final int minCapacity; // Quórum de confirmación
  final int maxCapacity; // Aforo límite
  final int reservedSlots;
  final DateTime eventDate;
  final int durationMinutes;
  final String? virtualMeetingUrl;
  final bool isQuorumReached;

  ExperienceModel({
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

  // Métodos de negocio para cálculo de quórum en UI
  bool get isConfirmed => isQuorumReached || reservedSlots >= minCapacity;
  int get slotsRemainingForQuorum => (minCapacity - reservedSlots).clamp(0, minCapacity);
  int get availableSlots => (maxCapacity - reservedSlots).clamp(0, maxCapacity);
  double get quorumProgress => maxCapacity > 0 ? (reservedSlots / maxCapacity).clamp(0.0, 1.0) : 0.0;

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['cover_image_url'],
      modality: json['modality'] ?? 'IN_PERSON',
      categoryName: json['category_name'] ?? 'General',
      venueName: json['venue_name'],
      zone: json['zone'],
      address: json['address'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      minCapacity: json['min_capacity'] ?? 5,
      maxCapacity: json['max_capacity'] ?? 10,
      reservedSlots: json['reserved_slots'] ?? 0,
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      durationMinutes: json['duration_minutes'] ?? 120,
      virtualMeetingUrl: json['virtual_meeting_url'],
      isQuorumReached: json['is_quorum_reached'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
