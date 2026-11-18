import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/live_telemetry_model.dart';

/// Umbrales del semáforo sobre el índice de energía (iguales al backend).
const double greenThreshold = 0.65;
const double yellowThreshold = 0.40;

/// Ventana visible de la gráfica (60 s, igual que el backend).
const Duration pulseWindow = Duration(seconds: 60);

/// Proyecta los puntos de pulso a coordenadas de un lienzo de [size].
///
/// El borde derecho es [windowEnd]; se descartan los puntos fuera de los últimos 60 s.
List<Offset> projectPulse(
  List<PulsePoint> points,
  DateTime windowEnd,
  Size size,
) {
  final DateTime start = windowEnd.subtract(pulseWindow);
  final double windowMs = pulseWindow.inMilliseconds.toDouble();
  return points
      .where(
        (PulsePoint p) =>
            !p.recordedAt.isBefore(start) && !p.recordedAt.isAfter(windowEnd),
      )
      .map((PulsePoint p) {
        final double x =
            p.recordedAt.difference(start).inMilliseconds /
            windowMs *
            size.width;
        final double y = (1 - p.energyScore.clamp(0.0, 1.0)) * size.height;
        return Offset(x, y);
      })
      .toList(growable: false);
}

/// Gráfica de pulso de energía reducida para tablets y celulares (HU-17).
class PulseSparkline extends StatelessWidget {
  /// Puntos de energía en orden cronológico.
  final List<PulsePoint> points;

  /// Borde derecho de la ventana (instante de emisión).
  final DateTime windowEnd;

  /// Color del punto actual.
  final Color currentColor;

  /// Altura de la gráfica.
  final double height;

  /// Crea la gráfica.
  const PulseSparkline({
    super.key,
    required this.points,
    required this.windowEnd,
    required this.currentColor,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PulsePainter(
          points: points,
          windowEnd: windowEnd,
          currentColor: currentColor,
          gridColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final List<PulsePoint> points;
  final DateTime windowEnd;
  final Color currentColor;
  final Color gridColor;

  _PulsePainter({
    required this.points,
    required this.windowEnd,
    required this.currentColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double greenY = (1 - greenThreshold) * size.height;
    final double yellowY = (1 - yellowThreshold) * size.height;

    // Franjas de referencia del semáforo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, greenY),
      Paint()..color = AppColors.emeraldSuccess.withValues(alpha: 0.08),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, greenY, size.width, yellowY - greenY),
      Paint()..color = AppColors.amberWarning.withValues(alpha: 0.08),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, yellowY, size.width, size.height - yellowY),
      Paint()..color = AppColors.roseDanger.withValues(alpha: 0.08),
    );
    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, greenY), Offset(size.width, greenY), grid);
    canvas.drawLine(Offset(0, yellowY), Offset(size.width, yellowY), grid);

    final List<Offset> projected = projectPulse(points, windowEnd, size);
    if (projected.isEmpty) return;

    final Path line = Path()..moveTo(projected.first.dx, projected.first.dy);
    for (final Offset point in projected.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    final Path area = Path.from(line)
      ..lineTo(projected.last.dx, size.height)
      ..lineTo(projected.first.dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()..color = AppColors.primaryVioletLight.withValues(alpha: 0.14),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primaryVioletLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      projected.last,
      9,
      Paint()..color = currentColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(projected.last, 5, Paint()..color = currentColor);
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.windowEnd != windowEnd ||
        oldDelegate.currentColor != currentColor ||
        oldDelegate.gridColor != gridColor;
  }
}
