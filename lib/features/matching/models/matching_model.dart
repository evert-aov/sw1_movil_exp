/// Datos reales de un grupo; su interés no constituye una reserva pagada.
class MatchingModel {
  final String id;
  final String experienceId;
  final int targetQuorum;
  final int currentMembers;
  final String status;
  final DateTime deadline;
  final double affinityScore;
  final bool hasJoined;
  final bool experienceConfirmed;
  final int paidSlots;

  MatchingModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String, experienceId = json['experience_id'] as String,
      targetQuorum = json['target_quorum'] as int, currentMembers = json['current_members'] as int,
      status = json['status'] as String, deadline = DateTime.parse(json['deadline'] as String),
      affinityScore = (json['affinity_score'] as num).toDouble(), hasJoined = json['is_member'] as bool,
      experienceConfirmed = json['experience_confirmed'] as bool, paidSlots = json['paid_slots'] as int;
}
