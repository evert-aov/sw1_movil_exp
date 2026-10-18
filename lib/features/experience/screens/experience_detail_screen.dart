import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/experience_model.dart';

/// Vista de Detalle de una Experiencia para el Usuario Asistente (Sprint 1 • CU-04 / CU-05).
///
/// Muestra toda la información de ubicación, horario, progreso de Quórum Mínimo
/// y condiciones del evento con iconos vectoriales y soporte de tema claro/oscuro.
class ExperienceDetailScreen extends StatelessWidget {
  /// Instancia del modelo de experiencia a visualizar en detalle.
  final ExperienceModel experience;

  /// Diccionario de internacionalización activo.
  final AppLocalizations i18n;

  /// Crea una instancia de [ExperienceDetailScreen].
  const ExperienceDetailScreen({
    super.key,
    required this.experience,
    required this.i18n,
  });

  /// Formatea la fecha completa del evento en formato DD/MM/YYYY • HH:mm.
  String _formatFullDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/$y • $h:$min';
  }

  /// Obtiene la etiqueta traducida según la modalidad del evento.
  String _getModalityLabel(String modality) {
    switch (modality) {
      case 'VIRTUAL':
        return i18n.tr('mod_virtual');
      case 'HYBRID':
        return i18n.tr('mod_hybrid');
      case 'IN_PERSON':
      default:
        return i18n.tr('mod_in_person');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool confirmed = experience.isConfirmed;

    final Color quorumBg = confirmed
        ? (isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight)
        : (isDark ? AppColors.amberBgDark : AppColors.amberBgLight);

    final Color quorumBorder = confirmed
        ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
        : AppColors.amberWarning.withValues(alpha: 0.4);

    final Color quorumText = confirmed
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: <Widget>[
          // Barra superior de arrastre y botón de cierre
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(width: 32),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                // Portada
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        experience.coverImageUrl ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceElevated,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.primaryVioletLight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryViolet,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            i18n.translateCategory(experience.categoryName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                experience.modality == 'VIRTUAL'
                                    ? Icons.laptop_mac_outlined
                                    : Icons.location_city_outlined,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _getModalityLabel(experience.modality),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  experience.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                // Metadatos del evento con iconos
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.primaryVioletLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${experience.zone ?? ''} • ${experience.venueName ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: AppColors.primaryVioletLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatFullDate(experience.eventDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: AppColors.primaryVioletLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${experience.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tarjeta de estado de Quórum
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: quorumBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: quorumBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                confirmed
                                    ? Icons.verified_outlined
                                    : Icons.hourglass_bottom_rounded,
                                size: 16,
                                color: quorumText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                confirmed
                                    ? i18n.tr('status_confirmed')
                                    : '${i18n.tr('status_pending_slots')} ${experience.slotsRemainingForQuorum}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: quorumText,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${experience.reservedSlots} / ${experience.maxCapacity} ${i18n.tr('slots')}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: experience.quorumProgress,
                          minHeight: 7,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            confirmed
                                ? AppColors.emeraldSuccess
                                : AppColors.amberWarning,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        confirmed
                            ? i18n.tr('quorum_confirmed_desc')
                            : i18n.tr('quorum_pending_desc'),
                        style: TextStyle(fontSize: 11.5, color: quorumText),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  i18n.tr('about_event'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  experience.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.45,
                  ),
                ),

                if (experience.address != null &&
                    experience.address!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: AppColors.primaryVioletLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        i18n.tr('exact_address'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    experience.address!,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Barra inferior informativa de precio (Sprint 1: Detalle y exploración)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      i18n.tr('price_per_person'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Bs. ${experience.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryVioletLight,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    i18n.tr('btn_understood'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
