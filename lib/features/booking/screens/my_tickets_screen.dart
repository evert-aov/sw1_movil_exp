import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../models/ticket_model.dart';
import '../services/booking_service.dart';
import '../widgets/ticket_qr.dart';
import 'checkout_screen.dart';

/// Historial propio con entradas anidadas, pagos pendientes y devoluciones (Sprint 2 • CU-06 / CU-08).
///
/// Alineado al sistema de diseño web con tarjetas estructuradas, distintivos semánticos
/// de estado y visualización rápida de códigos QR para el acceso a eventos.
class MyTicketsScreen extends StatefulWidget {
  final AppLocalizations? i18n;
  const MyTicketsScreen({super.key, this.i18n});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  AppLocalizations get i18n => widget.i18n ?? const AppLocalizations('es');

  final _service = BookingService();
  List<BookingModel> _bookings = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await _service.getMyTickets();
      if (mounted) setState(() => _bookings = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showTicket(TicketModel ticket) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                ticket.isUsed ? Icons.check_circle_outline : Icons.qr_code_2_rounded,
                color: ticket.isUsed ? AppColors.roseDanger : AppColors.primaryViolet,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                ticket.isUsed ? 'Entrada utilizada' : 'Entrada digital',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TicketQr(ticket: ticket),
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.tr('ticket_code_label'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    ticket.ticketCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (ticket.isUsed) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.roseDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      i18n.tr('ticket_used_note'),
                      style: const TextStyle(
                        color: AppColors.roseDanger,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx),
              child: Text(i18n.tr('btn_close')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refund(BookingModel booking) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(i18n.tr('btn_refund')),
        content: Text(i18n.tr('refund_confirm_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(i18n.tr('btn_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.roseDanger),
            child: Text(i18n.tr('btn_refund')),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _service.refund(booking.id);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted && _error == null) await _load();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Fecha por confirmar';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    Color bg;
    String label;

    switch (status.toUpperCase()) {
      case 'PAID':
        label = 'PAGADO';
        color = AppColors.emeraldSuccess;
        bg = isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight;
        break;
      case 'CONFIRMED':
        label = 'CONFIRMADO';
        color = AppColors.emeraldSuccess;
        bg = isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight;
        break;
      case 'PENDING':
        label = 'PENDIENTE';
        color = AppColors.amberWarning;
        bg = isDark ? AppColors.amberBgDark : AppColors.amberBgLight;
        break;
      case 'CANCELLED':
        label = 'CANCELADO';
        color = AppColors.roseDanger;
        bg = isDark ? const Color(0xFF331118) : const Color(0xFFFFF1F2);
        break;
      case 'EXPIRED':
        label = 'EXPIRADO';
        color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        break;
      case 'REFUNDED':
        label = 'REEMBOLSADO';
        color = const Color(0xFF3B82F6);
        bg = isDark ? const Color(0xFF0F223A) : const Color(0xFFEFF6FF);
        break;
      case 'PUBLISHED':
        label = 'PUBLICADO';
        color = const Color(0xFF3B82F6);
        bg = isDark ? const Color(0xFF0F223A) : const Color(0xFFEFF6FF);
        break;
      default:
        label = status.toUpperCase();
        color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        bg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primaryViolet,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Encabezado de página
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.tr('tickets_title'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    i18n.tr('tickets_subtitle'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: _busy ? null : _load,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: i18n.tr('btn_refresh'),
              ),
            ],
          ),

          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: AppColors.primaryViolet,
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.roseDanger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.roseDanger.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.roseDanger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.roseDanger,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Estado vacío
          if (!_busy && _error == null && _bookings.isEmpty) ...[
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryViolet.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      size: 48,
                      color: AppColors.primaryVioletLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    i18n.tr('tickets_empty_title'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i18n.tr('tickets_empty_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Lista de reservas
          const SizedBox(height: 16),
          for (final booking in _bookings) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera de la tarjeta
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryViolet.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.confirmation_number_rounded,
                                color: AppColors.primaryViolet,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 12,
                                        color: secondaryText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(booking.eventDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(booking.status, isDark),
                          ],
                        ),

                        // Badges secundarios de evento o devolución
                        if (booking.experienceStatus != null || booking.refundStatus != null) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (booking.experienceStatus != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Evento: ',
                                      style: TextStyle(fontSize: 11, color: secondaryText),
                                    ),
                                    _buildStatusBadge(booking.experienceStatus!, isDark),
                                  ],
                                ),
                              if (booking.refundStatus != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Devolución: ',
                                      style: TextStyle(fontSize: 11, color: secondaryText),
                                    ),
                                    _buildStatusBadge(booking.refundStatus!, isDark),
                                  ],
                                ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Fila de importe y cantidad
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${booking.quantity} ${booking.quantity == 1 ? 'entrada' : 'entradas'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${booking.currency} ${booking.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Barra inferior de acciones
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CheckoutScreen(bookingId: booking.id),
                                    ),
                                  );
                                  if (mounted) _load();
                                },
                                icon: const Icon(Icons.receipt_outlined, size: 16),
                                label: const Text('Ver detalle / pago'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            if (booking.canRefund) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _busy ? null : () => _refund(booking),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.roseDanger,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: const Text(
                                  'Devolución',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Botones de entradas QR individuales si ya fue pagado
                        if (booking.status == 'PAID' && booking.refundStatus == null && booking.tickets.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < booking.tickets.length; i++)
                                FilledButton.tonalIcon(
                                  onPressed: () => _showTicket(booking.tickets[i]),
                                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                                  label: Text(
                                    booking.tickets.length > 1
                                        ? 'Entrada ${i + 1} QR'
                                        : 'Mostrar Entrada QR',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
