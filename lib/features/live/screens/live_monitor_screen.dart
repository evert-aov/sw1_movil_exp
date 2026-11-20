import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/network/http_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../live_monitor_strings.dart';
import '../models/live_telemetry_model.dart';
import '../services/live_telemetry_service.dart';
import '../widgets/pulse_sparkline.dart';
import '../widgets/telemetry_traffic_light.dart';

/// Pantalla del Monitor de Telemetría en Vivo para tablets y celulares (CU-09 / HU-17).
///
/// Paso 1: el anfitrión ingresa el código generado en la consola web.
/// Paso 2: la pantalla muestra solo el semáforo, el porcentaje de energía y el pulso,
/// actualizados cada 2.5 s, para consultarlos de un vistazo sin distraerse del evento.
class LiveMonitorScreen extends StatefulWidget {
  /// Código de idioma activo ('es' o 'en').
  final String languageCode;

  /// Servicio inyectable para pruebas.
  final LiveTelemetryService? service;

  /// Crea la pantalla del monitor.
  const LiveMonitorScreen({
    super.key,
    required this.languageCode,
    this.service,
  });

  @override
  State<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends State<LiveMonitorScreen> {
  late final LiveTelemetryService _service =
      widget.service ?? LiveTelemetryService();
  late final LiveMonitorStrings _t = LiveMonitorStrings(widget.languageCode);
  final TextEditingController _codeController = TextEditingController();

  MonitorSession? _session;
  LiveTelemetrySnapshot? _snapshot;
  TelemetryConnectionState _connection = TelemetryConnectionState.connecting;
  StreamSubscription<TelemetryEvent>? _subscription;
  bool _pairing = false;
  String? _error;

  @override
  void dispose() {
    _subscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  /// Canjea el código ingresado y abre el canal de telemetría.
  Future<void> _pair() async {
    final String code = _codeController.text.replaceAll(RegExp(r'\s'), '');
    if (code.length != 6) {
      setState(() => _error = _t.tr('code_invalid'));
      return;
    }
    setState(() {
      _pairing = true;
      _error = null;
    });
    try {
      final MonitorSession session = await _service.redeemCode(code);
      if (!mounted) return;
      setState(() {
        _session = session;
        _pairing = false;
      });
      _listen(session);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _pairing = false;
        _error = e.message;
      });
    }
  }

  /// Se suscribe al flujo de telemetría de la [session] vinculada.
  void _listen(MonitorSession session) {
    _subscription?.cancel();
    _subscription = _service.watch(session).listen((TelemetryEvent event) {
      setState(() {
        if (event.connection != null) _connection = event.connection!;
        if (event.snapshot != null) _snapshot = event.snapshot;
      });
    }, onError: (Object _) => _unpair(error: _t.tr('denied')));
  }

  /// Cierra el canal y vuelve al ingreso de código.
  void _unpair({String? error}) {
    _subscription?.cancel();
    _subscription = null;
    if (!mounted) return;
    setState(() {
      _session = null;
      _snapshot = null;
      _connection = TelemetryConnectionState.connecting;
      _error = error;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MonitorSession? session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          session?.experienceTitle ?? _t.tr('title'),
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          if (session != null)
            TextButton.icon(
              key: const Key('unpair-button'),
              onPressed: _unpair,
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: Text(_t.tr('unpair')),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: session == null
                ? _buildPairForm(context)
                : _buildMonitor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPairForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = AppColors.accent(isDark);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border(isDark)),
            boxShadow: AppColors.cardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    size: 36,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _t.tr('pair_title'),
                textAlign: TextAlign.center,
                style: AppTypography.editorial(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t.tr('pair_description'),
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary(isDark),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('monitor-code-field'),
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  TextInputFormatter.withFunction(
                    (TextEditingValue _, TextEditingValue next) =>
                        next.copyWith(text: next.text.toUpperCase()),
                  ),
                ],
                style: AppTypography.sans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: AppColors.textPrimary(isDark),
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: _t.tr('code_label'),
                  errorText: _error,
                ),
                onSubmitted: (_) => _pair(),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                key: const Key('pair-button'),
                onPressed: _pairing ? null : _pair,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.link_rounded),
                label: Text(
                  _pairing ? _t.tr('pairing') : _t.tr('pair_button'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonitor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = AppColors.accent(isDark);
    final LiveTelemetrySnapshot? snapshot = _snapshot;
    final EnergyTrafficLight? light = snapshot?.trafficLight;
    final bool live = snapshot?.signalStatus == TelemetrySignalStatus.live;
    final double? energy = snapshot?.energyScore;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: _StatusChip(label: _statusLabel(), tone: _statusColor()),
        ),
        const SizedBox(height: 24),
        Center(
          child: TelemetryTrafficLight(light: light, live: live),
        ),
        const SizedBox(height: 20),
        Text(
          _t.tr('light_${light?.name ?? 'none'}'),
          key: const Key('light-label'),
          textAlign: TextAlign.center,
          style: AppTypography.editorial(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: light == null
                ? AppColors.textPrimary(isDark)
                : trafficLightColor(light),
          ),
        ),
        if (energy != null) ...<Widget>[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${(energy * 100).round()}%',
                key: const Key('energy-value'),
                style: AppTypography.editorial(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(width: 12),
              Icon(_trendIcon(snapshot!.trend), size: 18),
              const SizedBox(width: 4),
              Text(_t.tr('trend_${snapshot.trend.name}')),
            ],
          ),
          if (snapshot.detectedFacesCount != null)
            Text(
              '${snapshot.detectedFacesCount} ${_t.tr('faces')}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
        ],
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(isDark)),
            boxShadow: AppColors.cardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _t.tr('pulse').toUpperCase(),
                style: AppTypography.eyebrow(isDark),
              ),
              const SizedBox(height: 12),
              if (snapshot != null && snapshot.pulse.isNotEmpty)
                PulseSparkline(
                  points: snapshot.pulse,
                  windowEnd: snapshot.emittedAt,
                  currentColor: light == null
                      ? accent
                      : trafficLightColor(light),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      _t.tr('pulse_empty'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.textSecondary(isDark),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_t.tr('privacy'), style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ],
    );
  }

  /// Texto del indicador: estado de conexión si no está abierta; si no, estado de la señal.
  String _statusLabel() {
    if (_connection != TelemetryConnectionState.open) {
      return _t.tr('connection_${_connection.name}');
    }
    return _t.tr(
      'signal_${(_snapshot?.signalStatus ?? TelemetrySignalStatus.noSignal).name}',
    );
  }

  /// Color del indicador de estado.
  Color _statusColor() {
    if (_connection != TelemetryConnectionState.open) {
      return AppColors.amberWarning;
    }
    switch (_snapshot?.signalStatus) {
      case TelemetrySignalStatus.live:
        return AppColors.emeraldSuccess;
      case TelemetrySignalStatus.stale:
        return AppColors.amberWarning;
      default:
        return AppColors.roseDanger;
    }
  }

  /// Icono de la tendencia de energía.
  IconData _trendIcon(EnergyTrend trend) {
    switch (trend) {
      case EnergyTrend.rising:
        return Icons.trending_up_rounded;
      case EnergyTrend.falling:
        return Icons.trending_down_rounded;
      case EnergyTrend.stable:
        return Icons.trending_flat_rounded;
    }
  }
}

/// Indicador compacto del estado de la conexión o de la señal.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color tone;

  const _StatusChip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
