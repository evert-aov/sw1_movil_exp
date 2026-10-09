import '../models/matching_model.dart';

// Servicio de matching grupal: únicamente firmas de métodos (CU-07)
class MatchingService {
  Future<bool> applyToMatchingGroup(int experienceId) async {
    // Firma para postularse a grupo y sumar quórum
    return false;
  }

  Future<MatchingModel?> getMatchingStatus(int experienceId) async {
    // Firma para consultar progreso de participantes
    return null;
  }
}
