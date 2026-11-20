import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/services/auth_service.dart';
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
  const CatalogScreen({super.key, required this.i18n});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ExperienceService _service = ExperienceService();
  final AuthService _authService = AuthService();

  List<ExperienceModel> _experiences = <ExperienceModel>[];
  List<String> _dynamicCategories = <String>['Todos'];
  bool _isLoading = true;
  int _requestSequence = 0;
  Timer? _searchDebounce;
  String? _errorMessage;

  ExperienceFilterModel _filter = const ExperienceFilterModel();

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null && user.interests.isNotEmpty) {
      _filter = _filter.copyWith(category: 'Para ti');
    }
    _checkInitialUserInterests();
    _loadCatalog();
  }

  void _checkInitialUserInterests() {
    if (_authService.currentUser == null && HttpClient.authToken != null) {
      _authService.fetchProfile().then((user) {
        if (mounted && user.interests.isNotEmpty && _filter.category == 'Todos') {
          setState(() {
            _filter = _filter.copyWith(category: 'Para ti');
          });
          _loadCatalog();
        }
      }).catchError((_) {});
    }
  }

  bool _matchesInterests(ExperienceModel exp, List<String> interests) {
    if (interests.isEmpty) return true;
    final categoryNorm = exp.categoryName.toLowerCase().trim();
    final titleNorm = exp.title.toLowerCase();
    final descNorm = exp.description.toLowerCase();

    return interests.any((interest) {
      final tag = interest.toLowerCase().trim();
      if (tag.isEmpty) return false;
      if (categoryNorm.contains(tag) || tag.contains(categoryNorm)) return true;
      if (titleNorm.contains(tag) || descNorm.contains(tag)) return true;
      final words = tag.split(RegExp(r'\s+')).where((w) => w.length > 3);
      return words.any((w) => titleNorm.contains(w) || descNorm.contains(w));
    });
  }

  /// Consulta el catálogo en [ExperienceService.getCatalog] y extrae las categorías disponibles de los datos recibidos.
  Future<void> _loadCatalog() async {
    final request = ++_requestSequence;
    final filter = _filter;
    final bool isForYou = filter.category == 'Para ti';
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_dynamicCategories.length <= 1) {
        final categories = await _service.getCategories();
        if (categories.isNotEmpty && mounted) {
          final Set<String> loadedCategories = <String>{'Todos'};
          for (final item in categories) {
            final String? name = item['name'] as String?;
            if (name != null && name.trim().isNotEmpty) {
              loadedCategories.add(name.trim());
            }
          }
          _dynamicCategories = loadedCategories.toList();
        }
      }

      final serverFilter = isForYou ? filter.copyWith(category: 'Todos') : filter;
      final List<ExperienceModel> data = await _service.getCatalog(serverFilter);
      if (mounted && request == _requestSequence) {
        final Set<String> categorySet = <String>{
          'Todos',
          ..._dynamicCategories,
        };
        for (final exp in data) {
          if (exp.categoryName.trim().isNotEmpty) {
            categorySet.add(exp.categoryName.trim());
          }
        }

        List<ExperienceModel> displayedData = data;
        if (isForYou) {
          final userInterests = _authService.currentUser?.interests ?? <String>[];
          if (userInterests.isNotEmpty) {
            displayedData = data.where((exp) => _matchesInterests(exp, userInterests)).toList();
          }
        }

        setState(() {
          _experiences = displayedData;
          _dynamicCategories = categorySet.toList();
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted && request == _requestSequence) {
        setState(() {
          _experiences = <ExperienceModel>[];
          _isLoading = false;
          _errorMessage = '${widget.i18n.tr('api_error_prefix')} ${e.message}';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Edita fechas y ubicación sin confundir un nombre de zona con coordenadas GPS.
  Future<void> _showAdvancedFilters() async {
    final i18n = widget.i18n;
    DateTime? from = _filter.dateFrom, to = _filter.dateTo;
    bool available = _filter.onlyAvailable;
    final latitude = TextEditingController(
      text: _filter.latitude?.toString() ?? '',
    );
    final longitude = TextEditingController(
      text: _filter.longitude?.toString() ?? '',
    );
    final radius = TextEditingController(text: _filter.radiusKm.toString());
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(i18n.tr('advanced_filters')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final value = await showDatePicker(
                            context: ctx,
                            initialDate: from ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (value != null && ctx.mounted) {
                            update(() => from = value);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 15),
                        label: Text(
                          from != null
                              ? '${i18n.tr('date_from')}\n${from!.toIso8601String().substring(0, 10)}'
                              : '${i18n.tr('date_from')}: —',
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final value = await showDatePicker(
                            context: ctx,
                            initialDate: to ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (value != null && ctx.mounted) {
                            update(() => to = value);
                          }
                        },
                        icon: const Icon(Icons.event_available_rounded, size: 15),
                        label: Text(
                          to != null
                              ? '${i18n.tr('date_to')}\n${to!.toIso8601String().substring(0, 10)}'
                              : '${i18n.tr('date_to')}: —',
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: latitude,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: i18n.tr('latitude'),
                    prefixIcon: const Icon(Icons.place_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: longitude,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: i18n.tr('longitude'),
                    prefixIcon: const Icon(Icons.explore_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: radius,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: i18n.tr('radius_km'),
                    prefixIcon: const Icon(Icons.radar_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    i18n.tr('only_available'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: available,
                  onChanged: (value) => update(() => available = value),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                from = null;
                to = null;
                latitude.clear();
                longitude.clear();
                radius.text = '10';
                available = false;
                update(() {});
              },
              child: Text(i18n.tr('clear_filters')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent(
                  Theme.of(ctx).brightness == Brightness.dark,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(i18n.tr('apply_filters')),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && mounted) {
      final lat = double.tryParse(latitude.text),
          lon = double.tryParse(longitude.text);
      final distance = double.tryParse(radius.text);
      if ((lat == null) != (lon == null) ||
          (latitude.text.isNotEmpty && lat == null) ||
          (longitude.text.isNotEmpty && lon == null) ||
          (lat != null && (lat < -90 || lat > 90)) ||
          (lon != null && (lon < -180 || lon > 180)) ||
          distance == null ||
          distance <= 0 ||
          (from != null && to != null && from!.isAfter(to!))) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(i18n.tr('invalid_filters'))));
      } else {
        _filter = _filter.copyWith(clearAdvanced: true);
        _filter = _filter.copyWith(
          dateFrom: from,
          dateTo: to,
          latitude: lat,
          longitude: lon,
          radiusKm: distance,
          onlyAvailable: available,
        );
        await _loadCatalog();
      }
    }
    latitude.dispose();
    longitude.dispose();
    radius.dispose();
  }

  /// Muestra un diálogo informativo explicando el funcionamiento del Quórum Mínimo (sin emojis).
  void _showQuorumInfoDialog() {
    final i18n = widget.i18n;
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
        final Color accent = AppColors.accent(isDark);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline_rounded,
                color: accent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  i18n.tr('quorum_dialog_title'),
                  style: AppTypography.editorial(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(isDark),
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
                style: AppTypography.sans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 10),
              _buildBulletRow(
                Icons.groups_outlined,
                i18n.tr('quorum_dialog_p1'),
                accent,
              ),
              const SizedBox(height: 8),
              _buildBulletRow(
                Icons.trending_up_rounded,
                i18n.tr('quorum_dialog_p2'),
                accent,
              ),
              const SizedBox(height: 8),
              _buildBulletRow(
                Icons.verified_user_outlined,
                i18n.tr('quorum_dialog_p3'),
                accent,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                i18n.tr('btn_understood'),
                style: AppTypography.sans(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye una fila de texto con icono para el modal explicativo de Quórum.
  Widget _buildBulletRow(IconData icon, String text, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.45),
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
      builder: (BuildContext ctx) =>
          ExperienceDetailScreen(experience: exp, i18n: widget.i18n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = widget.i18n;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = AppColors.accent(isDark);
    final userInterests = _authService.currentUser?.interests ?? <String>[];
    final bool isForYou = _filter.category == 'Para ti';
    final int resultCount = isForYou ? _experiences.length : _service.totalResults;
    final List<String> displayCategories = <String>[
      if (userInterests.isNotEmpty) 'Para ti',
      'Todos',
      ..._dynamicCategories.where((c) => c != 'Todos' && c != 'Para ti'),
    ];

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      color: accent,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          // Buscador por palabra clave, categoría o zona
          TextField(
            onChanged: (String val) {
              _filter = _filter.copyWith(searchQuery: val);
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                if (mounted) _loadCatalog();
              });
            },
            decoration: InputDecoration(
              hintText: i18n.tr('search_hint'),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: accent,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _showAdvancedFilters,
              icon: Icon(Icons.tune_rounded, size: 17, color: accent),
              label: Text(
                i18n.tr('advanced_filters'),
                style: AppTypography.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: accent,
                ),
              ),
            ),
          ),

          // Banner explicativo de Quórum Mínimo
          InkWell(
            onTap: _showQuorumInfoDialog,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      i18n.tr('quorum_banner_text'),
                      style: AppTypography.sans(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.amberTextDark
                            : AppColors.amberTextLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.amberTextDark
                        : AppColors.amberTextLight,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selector de modalidad estilo pill editorial (como la web)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
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
          ),

          const SizedBox(height: 14),

          // Pills horizontales de categorías (rounded-full)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayCategories.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 8),
              itemBuilder: (BuildContext ctx, int index) {
                final String cat = displayCategories[index];
                final bool isSelected = cat == _filter.category;
                final bool isForYouChip = cat == 'Para ti';
                return ChoiceChip(
                  avatar: isForYouChip
                      ? Icon(
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: isSelected ? Colors.white : accent,
                        )
                      : null,
                  label: Text(i18n.translateCategory(cat)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _filter = _filter.copyWith(category: cat);
                    });
                    _loadCatalog();
                  },
                  selectedColor: accent,
                  backgroundColor: AppColors.card(isDark),
                  labelStyle: AppTypography.sans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary(isDark),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: isSelected ? accent : AppColors.border(isDark),
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          if (_filter.category == 'Para ti' && userInterests.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.accentSoft(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${i18n.tr('for_you_banner_prefix')} (${userInterests.map((t) => i18n.translateCategory(t)).join(', ')})',
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          if (_service.totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: _isLoading || _filter.page <= 1
                      ? null
                      : () {
                          _filter = _filter.copyWith(page: _filter.page - 1);
                          _loadCatalog();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_filter.page} / ${_service.totalPages}',
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading || _filter.page >= _service.totalPages
                      ? null
                      : () {
                          _filter = _filter.copyWith(page: _filter.page + 1);
                          _loadCatalog();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

          // Cabecera editorial de resultados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${i18n.tr('available_events')} ($resultCount)',
                style: AppTypography.editorial(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              IconButton(
                onPressed: _loadCatalog,
                tooltip: i18n.tr('btn_retry'),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 19,
                  color: accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(color: accent),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: AppColors.dangerText(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _loadCatalog,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
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
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 32,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    i18n.tr('no_events_title'),
                    style: AppTypography.editorial(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isForYou
                        ? i18n.tr('no_for_you_events_subtitle')
                        : i18n.tr('no_events_subtitle'),
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary(isDark),
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
                      final double cardWidth = (constraints.maxWidth - 16) / 2;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card(isDark) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.border(isDark))
              : null,
          boxShadow: isSelected ? AppColors.cardShadow(isDark) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.accent(isDark)
                  : AppColors.textSecondary(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary(isDark)
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
