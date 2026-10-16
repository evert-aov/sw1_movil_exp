import '../models/experience_model.dart';

// Servicio de exploración y catálogo de experiencias (CU-05 / HU-05)
class ExperienceService {
  // Lista inicial de experiencias semilla con datos realistas
  static final List<ExperienceModel> _experiences = [
    ExperienceModel(
      id: 1,
      title: 'Masterclass de Masa Madre y Focaccias Artesanales',
      description: 'Aprende los secretos del fermento natural, técnicas de hidratación al 80% y horneado en piedra viva. Te llevas tu propio pan y frasco de masa madre activa.',
      coverImageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80',
      modality: 'IN_PERSON',
      categoryName: 'Cocina & Repostería',
      venueName: 'La Rustika Panadería',
      zone: 'Equipetrol',
      address: 'Calle Los Tajibos #142',
      price: 180.0,
      minCapacity: 6,
      maxCapacity: 12,
      reservedSlots: 4,
      eventDate: DateTime.now().add(const Duration(days: 4, hours: 3)),
      durationMinutes: 180,
      isQuorumReached: false,
    ),
    ExperienceModel(
      id: 2,
      title: 'Cata Sensorial de Cafés de Altura de Caranavi',
      description: 'Descubre perfiles de taza geisha, borbón y típica mediante rueda de aromas SCAA. Incluye maridaje con chocolates de origen amazónico.',
      coverImageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&auto=format&fit=crop&q=80',
      modality: 'IN_PERSON',
      categoryName: 'Catas & Café',
      venueName: 'Café Typica Centro',
      zone: 'Centro Histórico',
      address: 'Calle 24 de Septiembre #350',
      price: 95.0,
      minCapacity: 8,
      maxCapacity: 15,
      reservedSlots: 7,
      eventDate: DateTime.now().add(const Duration(days: 6, hours: 5)),
      durationMinutes: 120,
      isQuorumReached: false,
    ),
    ExperienceModel(
      id: 3,
      title: 'Pintura al Óleo & Vino al Atardecer',
      description: 'Una velada descontracturada donde guiados por una artista plástica pintarás tu propio lienzo en formato mediano mientras disfrutas de una copa de vino.',
      coverImageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&auto=format&fit=crop&q=80',
      modality: 'IN_PERSON',
      categoryName: 'Arte & Pintura',
      venueName: 'Estudio Botánico Urubó',
      zone: 'Urubó',
      address: 'Av. Principal #45',
      price: 220.0,
      minCapacity: 5,
      maxCapacity: 10,
      reservedSlots: 6,
      eventDate: DateTime.now().add(const Duration(days: 8, hours: 2)),
      durationMinutes: 150,
      isQuorumReached: true,
    ),
    ExperienceModel(
      id: 4,
      title: 'Masterclass de Coctelería de Autor & Gin Botánico',
      description: 'Domina técnicas de maceración, mixología botánica con gin La República y maridaje con tapas fusión en terraza privada con vista panorámica.',
      coverImageUrl: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&auto=format&fit=crop&q=80',
      modality: 'IN_PERSON',
      categoryName: 'Coctelería',
      venueName: 'Terraza Rooftop 21',
      zone: 'Equipetrol',
      address: 'Calle Los Cusis #300, Piso 7',
      price: 210.0,
      minCapacity: 8,
      maxCapacity: 15,
      reservedSlots: 5,
      eventDate: DateTime.now().add(const Duration(days: 10, hours: 4)),
      durationMinutes: 150,
      isQuorumReached: false,
    ),
    ExperienceModel(
      id: 5,
      title: 'Taller de Cerámica Artesanal & Torno Alfarero',
      description: 'Conéctate con la arcilla natural. Aprenderás amasado, centrado en torno manual y técnicas de esmaltado para crear tus propias tazas cerámicas.',
      coverImageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=800&auto=format&fit=crop&q=80',
      modality: 'IN_PERSON',
      categoryName: 'Talleres',
      venueName: 'Casa Alfarera',
      zone: 'Las Palmas',
      address: 'Av. Las Palmeras #520',
      price: 160.0,
      minCapacity: 5,
      maxCapacity: 8,
      reservedSlots: 5,
      eventDate: DateTime.now().add(const Duration(days: 12, hours: 1)),
      durationMinutes: 180,
      isQuorumReached: true,
    ),
    ExperienceModel(
      id: 6,
      title: 'Masterclass Virtual: Pastelería Francesa en Casa',
      description: 'Sesión interactiva en vivo de macarons y pasta choux dictada por chef pastelero con ingredientes que puedes conseguir en cualquier supermercado.',
      coverImageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80',
      modality: 'VIRTUAL',
      categoryName: 'Cocina & Repostería',
      venueName: 'Google Meet en Vivo',
      zone: 'En Línea',
      virtualMeetingUrl: 'https://meet.google.com/exp-pasteleria-francesa',
      price: 80.0,
      minCapacity: 10,
      maxCapacity: 25,
      reservedSlots: 8,
      eventDate: DateTime.now().add(const Duration(days: 5, hours: 6)),
      durationMinutes: 120,
      isQuorumReached: false,
    ),
  ];

  // Listar catálogo con filtros dinámicos
  Future<List<ExperienceModel>> getCatalog({
    String? searchQuery,
    String? category,
    String? modality,
    String? zone,
  }) async {
    // Simulación de retraso de red natural
    await Future.delayed(const Duration(milliseconds: 150));

    return _experiences.where((exp) {
      if (category != null && category != 'Todos' && exp.categoryName != category) {
        return false;
      }
      if (modality != null && modality != 'ALL' && exp.modality != modality) {
        return false;
      }
      if (zone != null && zone != 'Todas' && exp.zone != zone) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final inTitle = exp.title.toLowerCase().contains(q);
        final inDesc = exp.description.toLowerCase().contains(q);
        final inZone = exp.zone?.toLowerCase().contains(q) ?? false;
        final inVenue = exp.venueName?.toLowerCase().contains(q) ?? false;
        final inCat = exp.categoryName.toLowerCase().contains(q);
        if (!inTitle && !inDesc && !inZone && !inVenue && !inCat) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Reservar un cupo simulado y actualizar el quórum en vivo
  Future<bool> reserveSlot(int experienceId) async {
    final index = _experiences.indexWhere((e) => e.id == experienceId);
    if (index != -1) {
      final current = _experiences[index];
      if (current.reservedSlots < current.maxCapacity) {
        final newReserved = current.reservedSlots + 1;
        final reached = newReserved >= current.minCapacity;
        _experiences[index] = ExperienceModel(
          id: current.id,
          title: current.title,
          description: current.description,
          coverImageUrl: current.coverImageUrl,
          modality: current.modality,
          categoryName: current.categoryName,
          venueName: current.venueName,
          zone: current.zone,
          address: current.address,
          price: current.price,
          minCapacity: current.minCapacity,
          maxCapacity: current.maxCapacity,
          reservedSlots: newReserved,
          eventDate: current.eventDate,
          durationMinutes: current.durationMinutes,
          virtualMeetingUrl: current.virtualMeetingUrl,
          isQuorumReached: reached,
        );
        return true;
      }
    }
    return false;
  }

  Future<ExperienceModel?> getExperienceById(int id) async {
    try {
      return _experiences.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
