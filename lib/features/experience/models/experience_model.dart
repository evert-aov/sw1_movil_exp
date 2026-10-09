// Modelo de Experiencia en Flutter
class ExperienceModel {
  final int id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String modality;
  final double price;
  final int minCapacity;
  final int maxCapacity;
  final int reservedSlots;
  final DateTime eventDate;
  final bool isQuorumReached;

  ExperienceModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.modality,
    required this.price,
    required this.minCapacity,
    required this.maxCapacity,
    required this.reservedSlots,
    required this.eventDate,
    required this.isQuorumReached,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['cover_image_url'],
      modality: json['modality'] ?? 'IN_PERSON',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      minCapacity: json['min_capacity'] ?? 0,
      maxCapacity: json['max_capacity'] ?? 0,
      reservedSlots: json['reserved_slots'] ?? 0,
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      isQuorumReached: json['is_quorum_reached'] ?? false,
    );
  }
}
