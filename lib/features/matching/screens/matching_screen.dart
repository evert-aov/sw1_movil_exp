import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../booking/screens/checkout_screen.dart';
import '../models/matching_model.dart';
import '../services/matching_service.dart';

/// Pantalla de Matching y Grupos por Afinidad (Sprint 2 • CU-06 / HU-08, HU-09).
///
/// Permite a un asistente postularse a un grupo afín indicando disponibilidad y zona,
/// monitorear el progreso hacia el quórum y pasar directamente a la reserva formal.
class MatchingScreen extends StatefulWidget {
  final String experienceId;
  const MatchingScreen({super.key, required this.experienceId});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  static const List<String> _suggestedZones = <String>[
    'Equipetrol',
    'Centro',
    'Urbarí',
    'Las Palmas',
    'Manzana 40',
    'Urubó',
    'Zona Norte',
  ];

  final _service = MatchingService();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _zone = TextEditingController();
  MatchingModel? _group;
  String? _error;
  bool _busy = false;
  Timer? _timer;
  int _sequence = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _from.dispose();
    _to.dispose();
    _zone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy) return;
    final request = ++_sequence;
    try {
      final group = await _service.getMatchingStatus(widget.experienceId);
      if (mounted && request == _sequence) {
        setState(() {
          _group = group;
          _error = null;
        });
      }
    } on ApiException catch (error) {
      if (mounted && request == _sequence && error.statusCode != 404) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted && request == _sequence) {
        setState(() => _error = error.toString());
      }
    }
  }

  Future<void> _apply() async {
    if (_busy) return;
    ++_sequence;
    final from = DateTime.tryParse(_from.text);
    final to = DateTime.tryParse(_to.text);
    if ((_from.text.isNotEmpty || _to.text.isNotEmpty) &&
        (from == null || to == null || !from.isBefore(to))) {
      setState(() => _error = 'Completa un rango válido de disponibilidad (Desde debe ser antes que Hasta).');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final group = await _service.applyToMatchingGroup(
        widget.experienceId,
        from: from,
        to: to,
        zone: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
      );
      if (mounted) setState(() => _group = group);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Retirar postulación?'),
        content: const Text(
          'Dejarás de formar parte del grupo de afinidad para esta experiencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.roseDanger),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    if (_busy) return;
    ++_sequence;
    setState(() => _busy = true);
    try {
      await _service.leave(widget.experienceId);
      if (mounted) setState(() => _group = null);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _load();
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (pickedTime == null || !mounted) return;

    final dt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    controller.text = '$y-$m-${d}T$h:$min';
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color color;
    Color bg;
    String label;

    switch (status.toUpperCase()) {
      case 'OPEN':
        label = 'ABIERTO';
        color = AppColors.primaryVioletLight;
        bg = isDark ? const Color(0xFF221538) : AppColors.primaryVioletSoft;
        break;
      case 'REACHED':
      case 'CONFIRMED':
        label = 'META ALCANZADA';
        color = AppColors.emeraldSuccess;
        bg = isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight;
        break;
      case 'EXPIRED':
        label = 'EXPIRADO';
        color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        break;
      default:
        label = status.toUpperCase();
        color = AppColors.amberWarning;
        bg = isDark ? AppColors.amberBgDark : AppColors.amberBgLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final group = _group;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grupo por afinidad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_busy)
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: AppColors.primaryViolet,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Banner explicativo superior
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryViolet.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryViolet.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: AppColors.primaryViolet,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'La postulación reúne asistentes afines para alcanzar el quórum. '
                          'Cuando el grupo se complete, cada miembro reserva y paga sus entradas.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.primaryViolet,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.roseDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.roseDanger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.roseDanger, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.roseDanger,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Tarjeta de estado del grupo (si ya existe o si el usuario pertenece)
                if (group != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.hub_outlined,
                                  size: 20,
                                  color: AppColors.primaryViolet,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  group.hasJoined ? 'Tu grupo asignado' : 'Grupo en formación',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryText,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusChip(group.status, isDark),
                          ],
                        ),

                        Divider(color: borderColor, height: 28),

                        // Métricas del grupo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Interesados en el grupo',
                              style: TextStyle(fontSize: 13, color: secondaryText),
                            ),
                            Text(
                              '${group.currentMembers} / ${group.targetQuorum}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (group.currentMembers / (group.targetQuorum > 0 ? group.targetQuorum : 1)).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade200,
                            color: AppColors.primaryViolet,
                          ),
                        ),

                        if (group.currentMembers > 1) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Afinidad temática estimada',
                                style: TextStyle(fontSize: 13, color: secondaryText),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldSuccess.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(group.affinityScore * 100).toStringAsFixed(0)}% afín',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.emeraldSuccess,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cupos pagados confirmados',
                              style: TextStyle(fontSize: 13, color: secondaryText),
                            ),
                            Text(
                              '${group.paidSlots} cupos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          group.experienceConfirmed
                              ? 'Evento confirmado por quórum pagado'
                              : 'Pendiente de confirmación económica por quórum',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: group.experienceConfirmed ? AppColors.emeraldSuccess : AppColors.amberWarning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        if (group.hasJoined) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _leave,
                              icon: const Icon(Icons.exit_to_app_rounded, size: 16, color: AppColors.roseDanger),
                              label: const Text(
                                'Retirar postulación',
                                style: TextStyle(color: AppColors.roseDanger),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.roseDanger.withValues(alpha: 0.4)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ] else ...[
                  // Si aún no hay grupo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primaryVioletLight, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Todavía no participas de un grupo. Postúlate indicando tu disponibilidad horaria.',
                            style: TextStyle(fontSize: 12.5, color: secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Formulario de postulación (solo si aún no se ha unido al grupo)
                if (_group?.hasJoined != true) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POSTULARME AL GRUPO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _from,
                          readOnly: false,
                          decoration: InputDecoration(
                            labelText: 'Disponible desde (hora local)',
                            hintText: 'AAAA-MM-DDTHH:mm',
                            prefixIcon: const Icon(Icons.schedule_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined, size: 20),
                              tooltip: 'Seleccionar fecha y hora',
                              onPressed: () => _pickDateTime(_from),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _to,
                          readOnly: false,
                          decoration: InputDecoration(
                            labelText: 'Disponible hasta (hora local)',
                            hintText: 'AAAA-MM-DDTHH:mm',
                            prefixIcon: const Icon(Icons.schedule_send_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined, size: 20),
                              tooltip: 'Seleccionar fecha y hora',
                              onPressed: () => _pickDateTime(_to),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _zone,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Zona preferida (opcional)',
                            hintText: 'Ej. Equipetrol, Centro, Urbarí...',
                            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                            suffixIcon: _zone.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() => _zone.clear()),
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Selección rápida de zonas sugeridas con un toque sin escribir
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _suggestedZones.map((String z) {
                            final bool isSelected =
                                _zone.text.trim().toLowerCase() == z.toLowerCase();
                            return ChoiceChip(
                              label: Text(z),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  _zone.text = selected ? z : '';
                                });
                              },
                              selectedColor: AppColors.primaryViolet,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceElevated
                                  : Colors.grey.shade100,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryViolet
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                              showCheckmark: false,
                              avatar: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.place_outlined,
                                size: 14,
                                color: isSelected ? Colors.white : AppColors.primaryViolet,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy || _group?.status == 'EXPIRED' ? null : _apply,
                            icon: const Icon(Icons.group_add_rounded, size: 20),
                            label: const Text(
                              'Postularme al grupo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryViolet,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botones de acción inferiores con espaciado adecuado
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _load,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Actualizar estado del grupo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CheckoutScreen(experienceId: widget.experienceId),
                      ),
                    ),
                    icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                    label: const Text(
                      'Reservar entradas directamente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
