import 'package:flutter/material.dart';
import '../models/experience_model.dart';
import '../services/experience_service.dart';

// Pantalla de Catálogo y Exploración de Experiencias (CU-05 / HU-05)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ExperienceService _service = ExperienceService();

  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _selectedModality = 'ALL';

  final List<String> _categories = [
    'Todos',
    'Cocina & Repostería',
    'Catas & Café',
    'Arte & Pintura',
    'Coctelería',
    'Talleres',
  ];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    final data = await _service.getCatalog(
      searchQuery: _searchQuery,
      category: _selectedCategory,
      modality: _selectedModality,
    );
    if (mounted) {
      setState(() {
        _experiences = data;
        _isLoading = false;
      });
    }
  }

  void _showQuorumInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💡 ', style: TextStyle(fontSize: 22)),
            Expanded(
              child: Text(
                '¿Cómo funciona el Quórum?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXPERIENCIA resuelve el problema de los cupos mínimos:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '• Cada actividad tiene un Quórum Mínimo de asistentes necesarios para que el anfitrión confirme el evento y no se cancele.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '• Tu reserva suma al indicador de la barra. Cuando se alcanza la meta, el evento se declara CONFIRMADO.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 6),
            Text(
              '• Si la fecha límite llega sin alcanzar el quórum, no se cobra nada y se protege tu dinero.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDetailBottomSheet(ExperienceModel exp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Imagen grande
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.network(
                          exp.coverImageUrl ?? '',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.indigo.shade100,
                            child: const Icon(Icons.image, size: 48, color: Colors.indigo),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exp.categoryName,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              exp.modality == 'IN_PERSON'
                                  ? '🏢 Presencial'
                                  : exp.modality == 'VIRTUAL'
                                      ? '💻 Virtual'
                                      : '🌐 Híbrido',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título
                  Text(
                    exp.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
                  ),

                  const SizedBox(height: 12),

                  // Info chips (Ubicación, fecha, duración)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 4),
                          Text('${exp.zone ?? ''} • ${exp.venueName ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 4),
                          Text(
                            '${exp.eventDate.day}/${exp.eventDate.month}/${exp.eventDate.year} • ${exp.eventDate.hour.toString().padLeft(2, '0')}:${exp.eventDate.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 4),
                          Text('${exp.durationMinutes} min', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tarjeta destacada de Quórum
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: exp.isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: exp.isConfirmed ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exp.isConfirmed ? '✅ ¡Evento Confirmado por Quórum!' : '⏳ Meta para confirmarse:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: exp.isConfirmed ? const Color(0xFF047857) : const Color(0xFFB45309),
                              ),
                            ),
                            Text(
                              '${exp.reservedSlots} / ${exp.maxCapacity} cupos',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: exp.quorumProgress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              exp.isConfirmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exp.isConfirmed
                              ? 'Este evento ya cuenta con el mínimo de asistentes requerido y se realizará con certeza.'
                              : 'Faltan solo ${exp.slotsRemainingForQuorum} participantes para asegurar que el evento se concrete.',
                          style: TextStyle(
                            fontSize: 11,
                            color: exp.isConfirmed ? const Color(0xFF065F46) : const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  const Text('Sobre este evento', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(
                    exp.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.45),
                  ),

                  if (exp.address != null && exp.address!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Dirección exacta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(exp.address!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Precio total', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                      Text(
                        'Bs. ${exp.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: exp.availableSlots > 0
                          ? () async {
                              Navigator.pop(ctx);
                              final success = await _service.reserveSlot(exp.id);
                              if (success) {
                                await _loadCatalog();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF10B981),
                                      content: Row(
                                        children: [
                                          const Text('🎉 ', style: TextStyle(fontSize: 18)),
                                          Expanded(
                                            child: Text(
                                              '¡Reserva registrada! Sumaste un cupo para activar "${exp.title}".',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        exp.availableSlots > 0 ? 'Reservar Mi Lugar' : 'Agotado',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXPERIENCIA',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, fontSize: 20, color: Color(0xFF4F46E5)),
            ),
            Text(
              'Eventos con Quórum Inteligente',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
            tooltip: '¿Qué es el Quórum?',
            onPressed: _showQuorumInfoDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCatalog,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Barra de Búsqueda
            TextField(
              onChanged: (val) {
                _searchQuery = val;
                _loadCatalog();
              },
              decoration: InputDecoration(
                hintText: 'Buscar eventos, talleres, catas...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Banner explicativo compacto de Quórum
            InkWell(
              onTap: _showQuorumInfoDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Text('💡 ', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: Text(
                        'Quórum Mínimo: Tu reserva activa el evento cuando se alcanza la meta de participantes.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: Color(0xFFB45309)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Chips de Modalidad (Todos, Presencial, Virtual)
            Row(
              children: [
                _buildModalityFilterChip('ALL', 'Todos'),
                const SizedBox(width: 8),
                _buildModalityFilterChip('IN_PERSON', '🏢 Presencial'),
                const SizedBox(width: 8),
                _buildModalityFilterChip('VIRTUAL', '💻 Virtual'),
              ],
            ),

            const SizedBox(height: 10),

            // Chips horizontales de Categorías
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      _loadCatalog();
                    },
                    selectedColor: const Color(0xFF4F46E5),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300,
                      ),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Header de Resultados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eventos Disponibles (${_experiences.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Sprint 1 • CU-05',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Listado de Tarjetas
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
              )
            else if (_experiences.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No se encontraron eventos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Intenta cambiando la categoría o término de búsqueda', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              )
            else
              ..._experiences.map((exp) => _buildExperienceCard(exp)),
          ],
        ),
      ),
    );
  }

  Widget _buildModalityFilterChip(String value, String label) {
    final isSelected = _selectedModality == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedModality = value);
        _loadCatalog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceModel exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => _showDetailBottomSheet(exp),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    exp.coverImageUrl ?? '',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exp.categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      exp.modality == 'IN_PERSON' ? '🏢 Presencial' : '💻 Virtual',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha y Zona
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📅 ${exp.eventDate.day}/${exp.eventDate.month} • ${exp.eventDate.hour.toString().padLeft(2, '0')}:${exp.eventDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '📍 ${exp.zone ?? ''}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    exp.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.25),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    exp.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35),
                  ),

                  const SizedBox(height: 12),

                  // Barra de Quórum
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: exp.isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: exp.isConfirmed ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              exp.isConfirmed ? '✅ ¡Confirmado!' : '⏳ Faltan ${exp.slotsRemainingForQuorum} cupos',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: exp.isConfirmed ? const Color(0xFF047857) : const Color(0xFFB45309),
                              ),
                            ),
                            Text(
                              '${exp.reservedSlots}/${exp.maxCapacity}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: exp.quorumProgress,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              exp.isConfirmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Meta mín: ${exp.minCapacity} personas',
                              style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                            ),
                            Text(
                              'Máx: ${exp.maxCapacity}',
                              style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Precio y Botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cupo por persona', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                          Text(
                            'Bs. ${exp.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showDetailBottomSheet(exp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Ver Detalle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
