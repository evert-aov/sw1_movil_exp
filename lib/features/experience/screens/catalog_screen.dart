import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../models/experience_filter_model.dart';
import '../models/experience_model.dart';
import '../services/experience_service.dart';
import '../widgets/experience_card.dart';
import 'experience_detail_screen.dart';

/// Pantalla de Catálogo y Exploración de Experiencias multiplataforma (Sprint 1 • CU-04 / CU-05 / HU-05).
///
/// Se adapta tanto a pantallas móviles como a pantallas anchas (Web, Tablet, Desktop)
/// consultando dinámicamente el servidor mediante [ExperienceService] sin datos harcodeados.
class CatalogScreen extends StatefulWidget {
  /// Diccionario de localización activo (Español / Inglés).
  final AppLocalizations i18n;

  /// Crea una instancia de [CatalogScreen].
  const CatalogScreen({
    super.key,
    required this.i18n,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ExperienceService _service = ExperienceService();

  List<ExperienceModel> _experiences = <ExperienceModel>[];
  List<String> _dynamicCategories = <String>['Todos'];
  bool _isLoading = true;
  String? _errorMessage;

  ExperienceFilterModel _filter = const ExperienceFilterModel();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  /// Consulta el catálogo en [ExperienceService.getCatalog] y extrae las categorías disponibles de los datos recibidos.
  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<ExperienceModel> data = await _service.getCatalog(_filter);
      if (mounted) {
        final Set<String> categorySet = <String>{'Todos', ..._dynamicCategories};
        for (final exp in data) {
          if (exp.categoryName.trim().isNotEmpty) {
            categorySet.add(exp.categoryName.trim());
          }
        }
        setState(() {
          _experiences = data;
          _dynamicCategories = categorySet.toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _experiences = <ExperienceModel>[];
          _isLoading = false;
          _errorMessage = '${widget.i18n.tr('api_error_prefix')} ${e.message}';
        });
      }
    }
  }

  /// Muestra un diálogo informativo explicando el funcionamiento del Quórum Mínimo (sin emojis).
  void _showQuorumInfoDialog() {
    final i18n = widget.i18n;
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primaryVioletLight,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                i18n.tr('quorum_dialog_title'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              i18n.tr('quorum_dialog_intro'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            _buildBulletRow(Icons.groups_outlined, i18n.tr('quorum_dialog_p1')),
            const SizedBox(height: 8),
            _buildBulletRow(
              Icons.trending_up_rounded,
              i18n.tr('quorum_dialog_p2'),
            ),
            const SizedBox(height: 8),
            _buildBulletRow(
              Icons.verified_user_outlined,
              i18n.tr('quorum_dialog_p3'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              i18n.tr('btn_understood'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryVioletLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una fila de texto con icono para el modal explicativo de Quórum.
  Widget _buildBulletRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.primaryVioletLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.4),
          ),
        ),
      ],
    );
  }

  /// Abre la hoja modal inferior con el detalle completo de la experiencia [exp].
  void _openExperienceDetail(ExperienceModel exp) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 680),
      builder: (BuildContext ctx) => ExperienceDetailScreen(
        experience: exp,
        i18n: widget.i18n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = widget.i18n;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      color: AppColors.primaryViolet,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Buscador por palabra clave, categoría o zona
          TextField(
            onChanged: (String val) {
              _filter = _filter.copyWith(searchQuery: val);
              _loadCatalog();
            },
            decoration: InputDecoration(
              hintText: i18n.tr('search_hint'),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryVioletLight,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Banner explicativo de Quórum Mínimo (solo iconos)
          InkWell(
            onTap: _showQuorumInfoDialog,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: isDark ? AppColors.amberBgDark : AppColors.amberBgLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.amberWarning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: AppColors.amberWarning,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      i18n.tr('quorum_banner_text'),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFB45309),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Filtros de modalidad con iconos vectoriales
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _buildModalityChip('ALL', i18n.tr('mod_all'), Icons.apps_rounded),
              _buildModalityChip(
                'IN_PERSON',
                i18n.tr('mod_in_person'),
                Icons.location_city_outlined,
              ),
              _buildModalityChip(
                'VIRTUAL',
                i18n.tr('mod_virtual'),
                Icons.laptop_mac_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chips horizontales de categorías extraídas dinámicamente de la respuesta API
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dynamicCategories.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 8),
              itemBuilder: (BuildContext ctx, int index) {
                final String cat = _dynamicCategories[index];
                final bool isSelected = cat == _filter.category;
                return ChoiceChip(
                  label: Text(i18n.translateCategory(cat)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _filter = _filter.copyWith(category: cat);
                    });
                    _loadCatalog();
                  },
                  selectedColor: AppColors.primaryViolet,
                  backgroundColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryViolet
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Cabecera de resultados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${i18n.tr('available_events')} (${_experiences.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                onPressed: _loadCatalog,
                tooltip: i18n.tr('btn_retry'),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.primaryVioletLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: AppColors.primaryViolet,
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: AppColors.roseDanger,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _loadCatalog,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryViolet,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: Text(i18n.tr('btn_retry')),
                  ),
                ],
              ),
            )
          else if (_experiences.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.search_off_rounded,
                    size: 44,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    i18n.tr('no_events_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    i18n.tr('no_events_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth >= 720) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _experiences.map((ExperienceModel exp) {
                      final double cardWidth =
                          (constraints.maxWidth - 16) / 2;
                      return SizedBox(
                        width: cardWidth,
                        child: ExperienceCard(
                          experience: exp,
                          i18n: i18n,
                          onTap: () => _openExperienceDetail(exp),
                        ),
                      );
                    }).toList(),
                  );
                }
                return Column(
                  children: _experiences
                      .map(
                        (ExperienceModel exp) => ExperienceCard(
                          experience: exp,
                          i18n: i18n,
                          onTap: () => _openExperienceDetail(exp),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Construye un botón de filtro de modalidad con icono y estado activo.
  Widget _buildModalityChip(String value, String label, IconData icon) {
    final bool isSelected = _filter.modality == value;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = _filter.copyWith(modality: value);
        });
        _loadCatalog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryViolet
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryViolet
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
