import '../models/experience_model.dart';

// Servicio de exploración y catálogo: únicamente firmas de métodos (CU-04)
class ExperienceService {
  Future<List<ExperienceModel>> getCatalog({
    int? categoryId,
    String? modality,
    String? zone,
  }) async {
    // Firma para obtener listado de experiencias filtradas
    return [];
  }

  Future<ExperienceModel?> getExperienceById(int id) async {
    // Firma para obtener detalle de una experiencia
    return null;
  }
}
