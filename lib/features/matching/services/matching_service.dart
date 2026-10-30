import '../../../core/network/http_client.dart';
import '../models/matching_model.dart';

class MatchingService {
  final HttpClient _client;
  MatchingService({HttpClient? httpClient}) : _client = httpClient ?? HttpClient();

  Future<MatchingModel> applyToMatchingGroup(String experienceId, {DateTime? from, DateTime? to, String? zone}) async {
    final result = await _client.post('/matching/apply', {
      'experience_id': experienceId,
      if (from != null) 'available_from': from.toUtc().toIso8601String(),
      if (to != null) 'available_to': to.toUtc().toIso8601String(),
      if (zone != null && zone.trim().isNotEmpty) 'preferred_zone': zone.trim(),
    });
    return MatchingModel.fromJson(result as Map<String, dynamic>);
  }

  Future<MatchingModel> getMatchingStatus(String id) async => MatchingModel.fromJson(
    await _client.get('/matching/group/$id') as Map<String, dynamic>);

  Future<void> leave(String id) async { await _client.delete('/matching/group/$id/membership'); }
}
