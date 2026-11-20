import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
        final accent = AppColors.accent(isDark);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                ticket.isUsed ? Icons.check_circle_outline : Icons.qr_code_2_rounded,
                color: ticket.isUsed ? AppColors.dangerText(isDark) : accent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                ticket.isUsed ? 'Entrada utilizada' : 'Entrada digital',
                style: AppTypography.editorial(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(isDark),
                ),
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
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: TicketQr(ticket: ticket),
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.tr('ticket_code_label'),
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft(isDark),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(isDark)),
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
                      color: AppColors.dangerBg(isDark),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      i18n.tr('ticket_used_note'),
                      style: AppTypography.sans(
                        color: AppColors.dangerText(isDark),
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentSoft(isDark),
                foregroundColor: accent,
              ),
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
        color = AppColors.textSecondary(isDark);
        bg = AppColors.surfaceSoft(isDark);
        break;
      case 'REFUNDED':
        label = 'REEMBOLSADO';
        color = AppColors.infoBlue;
        bg = isDark ? AppColors.infoBgDark : AppColors.infoBgLight;
        break;
      case 'PUBLISHED':
        label = 'PUBLICADO';
        color = AppColors.infoBlue;
        bg = isDark ? AppColors.infoBgDark : AppColors.infoBgLight;
        break;
      default:
        label = status.toUpperCase();
        color = AppColors.textSecondary(isDark);
        bg = AppColors.surfaceSoft(isDark);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
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
            style: AppTypography.sans(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
    final primaryText = AppColors.textPrimary(isDark);
    final secondaryText = AppColors.textSecondary(isDark);
    final cardBg = AppColors.card(isDark);
    final borderColor = AppColors.border(isDark);
    final accent = AppColors.accent(isDark);

    return RefreshIndicator(
      onRefresh: _load,
      color: accent,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: [
          // Encabezado editorial de página
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.tr('tickets_title'),
                      style: AppTypography.editorial(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i18n.tr('tickets_subtitle'),
                      style: AppTypography.sans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _busy ? null : _load,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft(isDark),
                  foregroundColor: accent,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: i18n.tr('btn_refresh'),
              ),
            ],
          ),

          if (_busy) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: accent,
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 16),
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
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.dangerText(isDark),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTypography.sans(
                        color: AppColors.dangerText(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Estado vacío editorial
          if (!_busy && _error == null && _bookings.isEmpty) ...[
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft(isDark),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.confirmation_number_outlined,
                      size: 40,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    i18n.tr('tickets_empty_title'),
                    style: AppTypography.editorial(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i18n.tr('tickets_empty_subtitle'),
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Lista de reservas
          const SizedBox(height: 18),
          for (final booking in _bookings) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: AppColors.cardShadow(isDark),
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
                                color: AppColors.accentSoft(isDark),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                color: accent,
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
                                    style: AppTypography.editorial(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                                        style: AppTypography.sans(
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
                                      style: AppTypography.sans(fontSize: 11, color: secondaryText),
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
                                      style: AppTypography.sans(fontSize: 11, color: secondaryText),
                                    ),
                                    _buildStatusBadge(booking.refundStatus!, isDark),
                                  ],
                                ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Fila de importe y cantidad
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${booking.quantity} ${booking.quantity == 1 ? 'entrada' : 'entradas'}',
                              style: AppTypography.sans(
                                fontSize: 13,
                                color: secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${booking.currency} ${booking.total.toStringAsFixed(2)}',
                              style: AppTypography.editorial(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
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
                      color: AppColors.surfaceSoft(isDark),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
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
                                  backgroundColor: cardBg,
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
                                  foregroundColor: AppColors.dangerText(isDark),
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
                                  icon: Icon(Icons.qr_code_rounded, size: 16, color: accent),
                                  label: Text(
                                    booking.tickets.length > 1
                                        ? 'Entrada ${i + 1} QR'
                                        : 'Mostrar Entrada QR',
                                    style: AppTypography.sans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accentSoft(isDark),
                                    foregroundColor: accent,
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
