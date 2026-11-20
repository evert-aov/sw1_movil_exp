import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../experience/services/experience_service.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';
import '../services/booking_service.dart';
import 'my_tickets_screen.dart';

/// Pantalla de reserva y pago alineada al sistema de diseño web (Sprint 2 • CU-06 / CU-07).
///
/// Gestiona la selección de cupos, generación de retención con idempotencia,
/// apertura segura de Stripe Checkout y reconciliación de estado tras el pago.
class CheckoutScreen extends StatefulWidget {
  final String? experienceId;
  final String? bookingId;
  final String? initialTitle;
  final double? initialPrice;
  final AppLocalizations? i18n;

  const CheckoutScreen({
    super.key,
    this.experienceId,
    this.bookingId,
    this.initialTitle,
    this.initialPrice,
    this.i18n,
  }) : assert(experienceId != null || bookingId != null);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  AppLocalizations get i18n => widget.i18n ?? const AppLocalizations('es');

  final _service = BookingService();
  final _experienceService = ExperienceService();
  final _key = BookingService.newKey();
  BookingModel? _booking;
  bool _busy = false;
  String? _error;
  int _quantity = 1;
  String? _experienceTitle;
  double? _unitPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _experienceTitle = widget.initialTitle;
    _unitPrice = widget.initialPrice;

    if (widget.bookingId != null) {
      _run(() async {
        _booking = await _service.getBooking(widget.bookingId!);
      });
    } else if (widget.experienceId != null &&
        (_experienceTitle == null || _unitPrice == null)) {
      _loadExperienceInfo();
    }
  }

  void _loadExperienceInfo() {
    if (widget.experienceId == null) return;
    _experienceService.getExperienceById(widget.experienceId!).then((exp) {
      if (mounted && exp != null) {
        setState(() {
          _experienceTitle ??= exp.title;
          _unitPrice ??= exp.price;
        });
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _booking != null && !_busy) {
      _refresh();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reserve() => _run(() async {
    _booking = await _service.createBooking(
      BookingRequestModel(
        experienceId: widget.experienceId!,
        quantity: _quantity,
      ),
      _key,
    );
  });

  Future<void> _refresh() => _run(() async {
    _booking = await _service.reconcile(_booking!.id);
  });

  Future<void> _pay() => _run(() async {
    final target = await _service.checkout(_booking!.id);
    if (!await launchUrl(target, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el navegador de pago.');
    }
  });

  Future<void> _confirmAndCancel(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar reserva?'),
        content: const Text(
          'Se liberarán tus cupos retenidos para que otros usuarios puedan reservarlos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mantener'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.roseDanger),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _run(() async {
        _booking = await _service.cancel(booking.id);
      });
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Fecha por confirmar';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }

  String _formatTimeOnly(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$min:$s';
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

  Widget _buildRow(String label, Widget trailing, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.sans(
            fontSize: 13,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        trailing,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.textPrimary(isDark);
    final secondaryText = AppColors.textSecondary(isDark);
    final cardBg = AppColors.card(isDark);
    final borderColor = AppColors.border(isDark);
    final accent = AppColors.accent(isDark);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reserva y pago',
          style: AppTypography.editorial(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_busy)
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: accent,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              children: [
                // Banner de error si ocurre alguno
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.roseDanger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.dangerText(isDark),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _error = null),
                        ),
                      ],
                    ),
                  ),

                // FASE 1: Selección de cantidad de entradas
                if (booking == null && widget.experienceId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft(isDark),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                color: accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _experienceTitle ?? 'Selección de entradas',
                                    style: AppTypography.editorial(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Elige la cantidad de cupos para tu orden.',
                                    style: AppTypography.sans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: borderColor, height: 32),
                        Text(
                          'CANTIDAD DE ENTRADAS',
                          style: AppTypography.eyebrow(isDark),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft(isDark),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton.filledTonal(
                                onPressed: _busy || _quantity <= 1
                                    ? null
                                    : () => setState(() => _quantity--),
                                icon: const Icon(Icons.remove_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: cardBg,
                                  foregroundColor: primaryText,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$_quantity',
                                    style: AppTypography.editorial(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  Text(
                                    _quantity == 1 ? 'entrada' : 'entradas',
                                    style: AppTypography.sans(
                                      fontSize: 12,
                                      color: secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton.filledTonal(
                                onPressed: _busy || _quantity >= 20
                                    ? null
                                    : () => setState(() => _quantity++),
                                icon: const Icon(Icons.add_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: cardBg,
                                  foregroundColor: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_unitPrice != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total estimado',
                                      style: AppTypography.sans(
                                        fontSize: 12,
                                        color: secondaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Bs. ${(_unitPrice! * _quantity).toStringAsFixed(2)}',
                                      style: AppTypography.editorial(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Bs. ${_unitPrice!.toStringAsFixed(2)} c/u',
                                  style: AppTypography.sans(
                                    fontSize: 12,
                                    color: secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _reserve,
                            icon: const Icon(Icons.lock_clock_outlined, size: 20),
                            label: Text(
                              'Reservar $_quantity ${_quantity == 1 ? 'entrada' : 'entradas'}',
                              style: AppTypography.sans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tarjeta informativa de retención
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Retención temporal de cupos',
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Al reservar, tus cupos quedan retenidos exclusivamente para ti durante 15 minutos mientras completas el pago seguro en Stripe.',
                                style: AppTypography.sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryText,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // FASE 2: Reserva activa
                if (booking != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft(isDark),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                color: accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.title,
                                    style: AppTypography.editorial(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: secondaryText,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          _formatDateTime(booking.eventDate),
                                          style: AppTypography.sans(
                                            fontSize: 12.5,
                                            color: secondaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: borderColor, height: 28),
                        _buildRow('Estado de la reserva', _buildStatusBadge(booking.status, isDark), isDark),
                        if (booking.experienceStatus != null) ...[
                          const SizedBox(height: 12),
                          _buildRow('Estado del evento', _buildStatusBadge(booking.experienceStatus!, isDark), isDark),
                        ],
                        if (booking.refundStatus != null) ...[
                          const SizedBox(height: 12),
                          _buildRow('Reembolso', _buildStatusBadge(booking.refundStatus!, isDark), isDark),
                        ],
                        const SizedBox(height: 12),
                        _buildRow(
                          'Entradas reservadas',
                          Text(
                            '${booking.quantity} ${booking.quantity == 1 ? 'entrada' : 'entradas'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                              fontSize: 13,
                            ),
                          ),
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildRow(
                          'ID de reserva',
                          Text(
                            booking.id.length > 8
                                ? booking.id.substring(0, 8).toUpperCase()
                                : booking.id.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Banner contextual según el estado
                  if (booking.status == 'PAID')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.emeraldBgDark : AppColors.emeraldBgLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.emeraldSuccess.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.emeraldSuccess,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '¡Pago completado con éxito!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tus entradas digitales han sido emitidas y están listas para ingresar.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          if (booking.experienceStatus != null &&
                              booking.experienceStatus != 'CONFIRMED') ...[
                            const SizedBox(height: 6),
                            Text(
                              'El evento está pendiente de alcanzar el quórum mínimo requerido.',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => Scaffold(
                                    body: SafeArea(child: MyTicketsScreen(i18n: i18n)),
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.qr_code_rounded, size: 18),
                              label: const Text('Ver mis entradas'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.emeraldSuccess,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (booking.status == 'PENDING')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.amberBgDark : AppColors.amberBgLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.amberWarning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: AppColors.amberWarning,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Retención temporal activa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            booking.expiresAt != null
                                ? 'Retención garantizada hasta las ${_formatTimeOnly(booking.expiresAt)} del ${_formatDateTime(booking.expiresAt)}. Completa el pago antes de que expire.'
                                : 'Completa el pago antes de que expire la retención temporal.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Al volver de Stripe, la aplicación actualizará el estado automáticamente.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                                  : AppColors.lightTextSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Esta reserva se encuentra cerrada o expirada.',
                              style: TextStyle(fontSize: 12.5, color: secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 3. Tarjeta de resumen de orden y pago
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: AppColors.cardShadow(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 20,
                              color: accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resumen de la orden',
                              style: AppTypography.editorial(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: borderColor, height: 24),
                        Text(
                          'Total a pagar',
                          style: AppTypography.sans(fontSize: 12, color: secondaryText),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${booking.currency} ',
                              style: AppTypography.sans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                            Text(
                              booking.total.toStringAsFixed(2),
                              style: AppTypography.editorial(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Comisión de plataforma e impuestos incluidos.',
                          style: AppTypography.sans(fontSize: 11.5, color: secondaryText),
                        ),
                        const SizedBox(height: 16),
                        // Distintivo de seguridad
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: AppColors.emeraldSuccess,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pago 100% seguro y encriptado',
                                      style: AppTypography.sans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Procesado a través de Stripe con cifrado SSL bancario.',
                                      style: AppTypography.sans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (booking.canPay) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _busy ? null : _pay,
                              icon: const Icon(Icons.credit_card_rounded, size: 20),
                              label: Text(
                                'Pagar con Stripe',
                                style: AppTypography.sans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _refresh,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Actualizar estado'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                        ),
                        if (booking.status == 'PENDING') ...[
                          const SizedBox(height: 6),
                          Center(
                            child: TextButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _confirmAndCancel(booking),
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.dangerText(isDark),
                              ),
                              label: Text(
                                'Cancelar reserva',
                                style: AppTypography.sans(
                                  color: AppColors.dangerText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // FASE 3: Fallo de carga al consultar por bookingId
                if (booking == null && widget.bookingId != null && !_busy) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.sync_problem_rounded,
                          size: 48,
                          color: AppColors.amberWarning,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No pudimos cargar la reserva',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verifica tu conexión o reintenta la consulta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: secondaryText),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _run(() async {
                            _booking = await _service.getBooking(widget.bookingId!);
                          }),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
