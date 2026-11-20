import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../booking/screens/checkout_screen.dart';
import '../models/matching_model.dart';
import '../services/matching_service.dart';

/// Pantalla de Matching y Grupos por Afinidad (Sprint 2 • CU-06 / HU-08, HU-09).
///
/// Permite a un asistente postularse a un grupo afín indicando disponibilidad y zona,
/// monitorear el progreso hacia el quórum y pasar directamente a la reserva formal.
class MatchingScreen extends StatefulWidget {
  final String experienceId;
  final AppLocalizations? i18n;
  const MatchingScreen({super.key, required this.experienceId, this.i18n});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  AppLocalizations get i18n => widget.i18n ?? const AppLocalizations('es');

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
        title: Text(i18n.tr('matching_leave_confirm_title')),
        content: Text(i18n.tr('matching_leave_confirm_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(i18n.tr('btn_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.roseDanger),
            child: Text(i18n.tr('btn_withdraw')),
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
        color = AppColors.accent(isDark);
        bg = AppColors.accentSoft(isDark);
        break;
      case 'REACHED':
      case 'CONFIRMED':
        label = 'META ALCANZADA';
        color = AppColors.emeraldSuccess;
        bg = isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight;
        break;
      case 'EXPIRED':
        label = 'EXPIRADO';
        color = AppColors.textSecondary(isDark);
        bg = AppColors.surfaceSoft(isDark);
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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.sans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.textPrimary(isDark);
    final secondaryText = AppColors.textSecondary(isDark);
    final cardBg = AppColors.card(isDark);
    final borderColor = AppColors.border(isDark);
    final accent = AppColors.accent(isDark);
    final group = _group;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          i18n.tr('matching_title'),
          style: AppTypography.editorial(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_busy)
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: accent,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              children: [
                // Banner explicativo superior
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: accent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          i18n.tr('matching_banner_desc'),
                          style: AppTypography.sans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: primaryText,
                            height: 1.45,
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
                      color: AppColors.dangerBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.roseDanger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.dangerText(isDark),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTypography.sans(
                              color: AppColors.dangerText(isDark),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Tarjeta de estado del grupo
                if (group != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.hub_outlined,
                                  size: 20,
                                  color: accent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  group.hasJoined
                                      ? i18n.tr('matching_your_group')
                                      : i18n.tr('matching_forming_group'),
                                  style: AppTypography.editorial(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
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
                              i18n.tr('matching_members_label'),
                              style: AppTypography.sans(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            Text(
                              '${group.currentMembers} / ${group.targetQuorum}',
                              style: AppTypography.sans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
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
                            backgroundColor: AppColors.surfaceSoft(isDark),
                            color: accent,
                          ),
                        ),

                        if (group.currentMembers > 1) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Afinidad temática estimada',
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  color: secondaryText,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${(group.affinityScore * 100).toStringAsFixed(0)}% afín',
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.emeraldTextDark : AppColors.emeraldTextLight,
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
                              style: AppTypography.sans(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            Text(
                              '${group.paidSlots} cupos',
                              style: AppTypography.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
                          style: AppTypography.sans(
                            fontSize: 11.5,
                            color: group.experienceConfirmed
                                ? (isDark ? AppColors.emeraldTextDark : AppColors.emeraldTextLight)
                                : (isDark ? AppColors.amberTextDark : AppColors.amberTextLight),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (group.hasJoined) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _leave,
                              icon: Icon(
                                Icons.exit_to_app_rounded,
                                size: 16,
                                color: AppColors.dangerText(isDark),
                              ),
                              label: Text(
                                i18n.tr('matching_leave_btn'),
                                style: TextStyle(color: AppColors.dangerText(isDark)),
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
                      color: AppColors.surfaceSoft(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            i18n.tr('matching_no_group_yet'),
                            style: AppTypography.sans(
                              fontSize: 12.5,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Formulario de postulación
                if (_group?.hasJoined != true) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n.tr('matching_form_kicker').toUpperCase(),
                          style: AppTypography.eyebrow(isDark),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _from,
                          readOnly: false,
                          decoration: InputDecoration(
                            labelText: i18n.tr('matching_from_label'),
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
                            labelText: i18n.tr('matching_to_label'),
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
                            labelText: i18n.tr('matching_zone_label'),
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

                        const SizedBox(height: 12),

                        // Selección rápida de zonas sugeridas (rounded-full)
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
                              selectedColor: accent,
                              backgroundColor: AppColors.surfaceSoft(isDark),
                              labelStyle: AppTypography.sans(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : primaryText,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide(
                                  color: isSelected ? accent : borderColor,
                                ),
                              ),
                              showCheckmark: false,
                              avatar: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.place_outlined,
                                size: 14,
                                color: isSelected ? Colors.white : accent,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy || _group?.status == 'EXPIRED' ? null : _apply,
                            icon: const Icon(Icons.group_add_rounded, size: 20),
                            label: Text(
                              i18n.tr('matching_apply_btn'),
                              style: AppTypography.sans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: Colors.white,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botones de acción inferiores
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _load,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(i18n.tr('matching_refresh_btn')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        builder: (_) => CheckoutScreen(experienceId: widget.experienceId, i18n: i18n),
                      ),
                    ),
                    icon: Icon(Icons.confirmation_number_outlined, size: 18, color: accent),
                    label: Text(
                      i18n.tr('matching_direct_checkout_btn'),
                      style: AppTypography.sans(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentSoft(isDark),
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
