import '../models/matching_model.dart';

/// Servicio de dominio para grupos de Matching Dinámico (Planificado para Sprint 2 • CU-07).
///
/// En el alcance del Sprint 1 define únicamente las firmas documentadas de contrato
/// bajo el principio de responsabilidad única.
class MatchingService {
  /// Crea una instancia de [MatchingService].
  const MatchingService();

  /// Firma de contrato para postularse al grupo de matching de la experiencia [experienceId] (UUID).
  Future<bool> applyToMatchingGroup(String experienceId) async {
    return false;
  }

  /// Firma de contrato para consultar el estado de quórum grupal de la experiencia [experienceId] (UUID).
  Future<MatchingModel?> getMatchingStatus(String experienceId) async {
    return null;
  }
}
