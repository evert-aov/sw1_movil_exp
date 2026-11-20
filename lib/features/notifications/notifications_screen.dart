import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/http_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../experience/screens/experience_detail_screen.dart';
import '../experience/services/experience_service.dart';

/// Bandeja persistente: recupera mensajes al abrirla y consulta cada 30 segundos.
class NotificationsScreen extends StatefulWidget {
  final AppLocalizations i18n;
  const NotificationsScreen({super.key, required this.i18n});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _client = HttpClient();
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _busy = false;
  int _offset = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final rows = await _client.get(
        '/notifications',
        queryParameters: {'limit': '50', 'offset': '$_offset'},
      ) as List<dynamic>;
      if (mounted) {
        setState(() {
          _items = rows.cast<Map<String, dynamic>>();
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Sin conexión. Reintentaremos recuperar los avisos.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _read(Map<String, dynamic> item) async {
    try {
      await _client.patch('/notifications/${item['id']}/read', {});
      await _load();
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo marcar el aviso.');
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    try {
      final experience = await ExperienceService().getExperienceById(
        item['experience_id'] as String,
      );
      if (!mounted || experience == null) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              ExperienceDetailScreen(experience: experience, i18n: widget.i18n),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo abrir la experiencia.');
    }
  }

  String _formatTimestamp(String raw) {
    final dt = DateTime.parse(raw).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = AppColors.accent(isDark);

    return RefreshIndicator(
      onRefresh: _load,
      color: accent,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.i18n.tr('notif_title'),
                style: AppTypography.editorial(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _load,
                icon: Icon(Icons.refresh_rounded, size: 17, color: accent),
                label: Text(widget.i18n.tr('btn_refresh')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
          if (_busy) ...<Widget>[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: accent,
            ),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerBg(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.error_outline_rounded,
                    size: 19,
                    color: AppColors.dangerText(isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTypography.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dangerText(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!_busy && _error == null && _items.isEmpty) ...<Widget>[
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.i18n.tr('notif_empty'),
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final item in _items)
            Builder(
              builder: (BuildContext context) {
                final bool unread = item['read_at'] == null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: unread
                          ? accent.withValues(alpha: 0.5)
                          : AppColors.border(isDark),
                      width: unread ? 1.4 : 1,
                    ),
                    boxShadow: AppColors.cardShadow(isDark),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: unread
                                ? AppColors.accentSoft(isDark)
                                : AppColors.surfaceSoft(isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            unread
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_none_rounded,
                            size: 20,
                            color: unread
                                ? accent
                                : AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _formatTimestamp(item['created_at'] as String),
                                style: AppTypography.sans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['message'] as String,
                                style: AppTypography.sans(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: <Widget>[
                                  OutlinedButton.icon(
                                    onPressed: () => _open(item),
                                    icon: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 15,
                                      color: accent,
                                    ),
                                    label: Text(
                                      widget.i18n.tr('notif_view_exp'),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      textStyle: AppTypography.sans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (unread)
                                    TextButton(
                                      onPressed: () => _read(item),
                                      child: Text(
                                        widget.i18n.tr('notif_mark_read'),
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
              },
            ),
          if (_items.isNotEmpty || _offset > 0) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _offset == 0 || _busy
                      ? null
                      : () {
                          _offset -= 50;
                          _load();
                        },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text(widget.i18n.tr('notif_previous')),
                ),
                OutlinedButton.icon(
                  onPressed: _items.length < 50 || _busy
                      ? null
                      : () {
                          _offset += 50;
                          _load();
                        },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(widget.i18n.tr('notif_older')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
