import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/live_telemetry_model.dart';

/// Devuelve el color de marca asociado a cada nivel del semáforo.
Color trafficLightColor(EnergyTrafficLight light) {
  switch (light) {
    case EnergyTrafficLight.green:
      return AppColors.emeraldSuccess;
    case EnergyTrafficLight.yellow:
      return AppColors.amberWarning;
    case EnergyTrafficLight.red:
      return AppColors.roseDanger;
  }
}

/// Semáforo de energía reducido para tablets y celulares (HU-17).
///
/// Enciende solo la luz activa y se atenúa cuando la señal no es en vivo, para que el
/// anfitrión no tome decisiones con datos desactualizados.
class TelemetryTrafficLight extends StatelessWidget {
  /// Color activo; null si aún no hay métricas.
  final EnergyTrafficLight? light;

  /// Indica si la señal es en vivo.
  final bool live;

  /// Diámetro de cada luz.
  final double lampSize;

  /// Crea el semáforo.
  const TelemetryTrafficLight({
    super.key,
    required this.light,
    this.live = true,
    this.lampSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: live ? 1 : 0.45,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(lampSize),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: EnergyTrafficLight.values.reversed.map((
            EnergyTrafficLight lamp,
          ) {
            final bool isOn = lamp == light;
            final Color color = trafficLightColor(lamp);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: AnimatedContainer(
                key: ValueKey<String>(
                  'lamp-${lamp.name}-${isOn ? 'on' : 'off'}',
                ),
                duration: const Duration(milliseconds: 500),
                width: lampSize,
                height: lampSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: isOn ? 1 : 0.18),
                  boxShadow: isOn
                      ? <BoxShadow>[
                          BoxShadow(
                            color: color.withValues(alpha: 0.55),
                            blurRadius: 22,
                            spreadRadius: 3,
                          ),
                        ]
                      : const <BoxShadow>[],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
