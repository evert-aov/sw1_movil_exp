import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import '../models/ticket_model.dart';

/// QR calculado localmente: el payload de entrada nunca sale a un servicio de imágenes.
class TicketQr extends StatelessWidget {
  final TicketModel ticket;
  const TicketQr({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode.fromData(
        data: ticket.qrPayload,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      ),
    );
    return Semantics(
      label: 'Código QR de la entrada ${ticket.ticketCode}',
      child: SizedBox.square(
        dimension: 300,
        child: CustomPaint(painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage image;
  _QrPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    const quiet = 4;
    final unit = size.shortestSide / (image.moduleCount + quiet * 2);
    final ink = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (image.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              (col + quiet) * unit,
              (row + quiet) * unit,
              unit,
              unit,
            ),
            ink,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
