import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/experience_model.dart';

/// Tarjeta visual cohesiva para representar un ítem de [ExperienceModel] en el catálogo móvil.
///
/// Cumple con el principio de responsabilidad única encargándose exclusivamente
/// de renderizar el resumen visual de una experiencia sin acoplarse al servicio de datos.
class ExperienceCard extends StatelessWidget {
  /// Modelo de la experiencia a mostrar.
  final ExperienceModel experience;

  /// Diccionario de localización activo (Español / Inglés).
  final AppLocalizations i18n;

  /// Callback ejecutado cuando el asistente selecciona la tarjeta para ver el detalle.
  final VoidCallback onTap;

  /// Crea una instancia de [ExperienceCard].
  const ExperienceCard({
    super.key,
    required this.experience,
    required this.i18n,
    required this.onTap,
  });

  /// Retorna el icono correspondiente a la modalidad de la experiencia (cero emojis).
  IconData _getModalityIcon(String modality) {
    switch (modality) {
      case 'VIRTUAL':
        return Icons.laptop_mac_outlined;
      case 'HYBRID':
        return Icons.hub_outlined;
      case 'IN_PERSON':
      default:
        return Icons.location_city_outlined;
    }
  }

  /// Retorna la etiqueta traducida de la modalidad de la experiencia.
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

  /// Formatea la fecha y hora del evento en formato legible DD/MM • HH:mm.
  String _formatEventDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool confirmed = experience.isConfirmed;

    final Color quorumBg = confirmed
        ? (isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight)
        : (isDark ? AppColors.amberBgDark : AppColors.amberBgLight);

    final Color quorumBorder = confirmed
        ? AppColors.emeraldSuccess.withValues(alpha: isDark ? 0.4 : 0.35)
        : AppColors.amberWarning.withValues(alpha: isDark ? 0.4 : 0.35);

    final Color quorumText = confirmed
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen de portada con insignias de categoría y modalidad (solo iconos)
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    experience.coverImageUrl ?? '',
                    height: 164,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 164,
                      color: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.primaryVioletLight,
                        ),
                      ),
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
                        fontWeight: FontWeight.w700,
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
                          _getModalityIcon(experience.modality),
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _getModalityLabel(experience.modality),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(15),
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
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatEventDate(experience.eventDate),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.primaryVioletLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            experience.zone ?? '',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.primaryVioletLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experience.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    experience.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Indicador de Quórum Mínimo con iconos
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: quorumBg,
                      borderRadius: BorderRadius.circular(12),
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
                                  size: 14,
                                  color: quorumText,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  confirmed
                                      ? i18n.tr('status_confirmed')
                                      : '${i18n.tr('status_pending_slots')} ${experience.slotsRemainingForQuorum}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: quorumText,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${experience.reservedSlots}/${experience.maxCapacity}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: experience.quorumProgress,
                            minHeight: 5,
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
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${i18n.tr('min_goal')}: ${experience.minCapacity} ${i18n.tr('people')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '${i18n.tr('max_cap')}: ${experience.maxCapacity}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Precio y botón de detalle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            i18n.tr('price_per_person'),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Bs. ${experience.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryViolet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                        label: Text(
                          i18n.tr('btn_view_detail'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
