// Modelo de grupo de matching en Flutter
class MatchingModel {
  final int id;
  final int experienceId;
  final int targetQuorum;
  final int currentMembers;
  final String status;
  final DateTime deadline;
  final bool isQuorumReached;

  MatchingModel({
    required this.id,
    required this.experienceId,
    required this.targetQuorum,
    required this.currentMembers,
    required this.status,
    required this.deadline,
    required this.isQuorumReached,
  });

  factory MatchingModel.fromJson(Map<String, dynamic> json) {
    return MatchingModel(
      id: json['id'] ?? 0,
      experienceId: json['experience_id'] ?? 0,
      targetQuorum: json['target_quorum'] ?? 0,
      currentMembers: json['current_members'] ?? 0,
      status: json['status'] ?? 'OPEN',
      deadline: DateTime.tryParse(json['deadline'] ?? '') ?? DateTime.now(),
      isQuorumReached: json['is_quorum_reached'] ?? false,
    );
  }
}
