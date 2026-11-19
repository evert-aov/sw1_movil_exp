import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../live_monitor_strings.dart';
import '../models/live_telemetry_model.dart';
import '../services/live_telemetry_service.dart';

/// Tarjeta del Asistente de Maestro de Ceremonias en el monitor móvil (CU-11 / HU-18, HU-19).
///
/// Muestra la alerta de atención baja con la dinámica sugerida y las acciones rápidas,
/// la cuenta regresiva de una pausa aplicada o el resultado de una alerta ya resuelta.
class McAlertCard extends StatefulWidget {
  /// Alerta vigente.
  final McAlert alert;

  /// Textos del monitor en el idioma activo.
  final LiveMonitorStrings strings;

  /// Código de idioma para los textos de la dinámica.
  final String languageCode;

  /// Verdadero mientras se envía una respuesta.
  final bool busy;

  /// Respuesta elegida por el moderador.
  final ValueChanged<McAlertAction> onAction;

  /// Se llama cuando termina la cuenta regresiva de la pausa.
  final VoidCallback? onBreakFinished;

  /// Reloj inyectable para pruebas.
  final DateTime Function() clock;

  /// Crea la tarjeta.
  McAlertCard({
    super.key,
    required this.alert,
    required this.strings,
    required this.languageCode,
    required this.onAction,
    this.busy = false,
    this.onBreakFinished,
    DateTime Function()? clock,
  }) : clock = clock ?? (() => DateTime.now().toUtc());

  @override
  State<McAlertCard> createState() => _McAlertCardState();
}

class _McAlertCardState extends State<McAlertCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(McAlertCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Segundos que faltan para terminar la pausa aplicada (0 si no hay pausa en curso).
  int get _breakRemainingSeconds {
    final DateTime? ends = widget.alert.breakEndsAt;
    if (widget.alert.status != McAlertStatus.applied || ends == null) return 0;
    final int seconds = ends.difference(widget.clock()).inMilliseconds;
    return seconds <= 0 ? 0 : (seconds / 1000).ceil();
  }

  /// Avanza la cuenta regresiva cada segundo mientras haya una pausa en curso.
  void _syncTicker() {
    _ticker?.cancel();
    if (_breakRemainingSeconds == 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() {});
      if (_breakRemainingSeconds == 0) {
        timer.cancel();
        widget.onBreakFinished?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final McAlert alert = widget.alert;
    final Color accent = alert.status == McAlertStatus.active
        ? AppColors.amberWarning
        : AppColors.emeraldSuccess;
    return Card(
      key: const Key('mc-alert-card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: alert.status == McAlertStatus.active
            ? _buildActive(context, alert)
            : _buildResolved(context, alert),
      ),
    );
  }

  Widget _buildActive(BuildContext context, McAlert alert) {
    final ThemeData theme = Theme.of(context);
    final LiveMonitorStrings t = widget.strings;
    final McDynamic? dynamic = alert.suggestedDynamic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.amberWarning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.tr(alert.manual ? 'mc_manual_title' : 'mc_alert_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (!alert.manual)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${t.tr('mc_low_for')} ${(alert.lowAttentionSeconds / 60).round()} ${t.tr('mc_minutes')}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (dynamic != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            dynamic.title(widget.languageCode),
            key: const Key('mc-dynamic-title'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dynamic.instructions(widget.languageCode),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('mc-apply'),
            onPressed: widget.busy
                ? null
                : () => widget.onAction(McAlertAction.apply),
            icon: const Icon(Icons.check_rounded),
            label: Text(t.tr('mc_action_${dynamic.type.name}')),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('mc-next'),
                  onPressed: widget.busy
                      ? null
                      : () => widget.onAction(McAlertAction.next),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: Text(t.tr('mc_another')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  key: const Key('mc-dismiss'),
                  onPressed: widget.busy
                      ? null
                      : () => widget.onAction(McAlertAction.dismiss),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(t.tr('mc_dismiss')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildResolved(BuildContext context, McAlert alert) {
    final ThemeData theme = Theme.of(context);
    final LiveMonitorStrings t = widget.strings;
    final int remaining = _breakRemainingSeconds;
    if (remaining > 0) {
      final String countdown =
          '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}';
      return Row(
        children: <Widget>[
          const Icon(Icons.timer_outlined, color: AppColors.emeraldSuccess),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${t.tr('mc_break_running')} · ${t.tr('mc_break_ends')} $countdown',
              key: const Key('mc-countdown'),
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.emeraldSuccess,
        ),
        const SizedBox(width: 10),
        Text(
          t.tr(
            alert.status == McAlertStatus.expired ? 'mc_expired' : 'mc_applied',
          ),
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}
