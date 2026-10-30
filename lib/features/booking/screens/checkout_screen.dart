import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';
import '../services/booking_service.dart';
import 'my_tickets_screen.dart';

/// Crea una retención y abre Stripe; el retorno siempre consulta el estado al servidor.
class CheckoutScreen extends StatefulWidget {
  final String? experienceId;
  final String? bookingId;
  const CheckoutScreen({super.key, this.experienceId, this.bookingId})
    : assert(experienceId != null || bookingId != null);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  final _service = BookingService();
  final _key = BookingService.newKey();
  BookingModel? _booking;
  bool _busy = false;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.bookingId != null) {
      _run(() async {
        _booking = await _service.getBooking(widget.bookingId!);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva y pago')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (booking == null && widget.experienceId != null) ...[
            const Text(
              'Selecciona la cantidad de entradas. El servidor calculará el importe y comprobará los cupos.',
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _busy || _quantity <= 1
                      ? null
                      : () => setState(() => _quantity--),
                  icon: const Icon(Icons.remove),
                ),
                Text('$_quantity'),
                IconButton(
                  onPressed: _busy || _quantity >= 20
                      ? null
                      : () => setState(() => _quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            FilledButton(
              onPressed: _busy ? null : _reserve,
              child: const Text('Reservar cupos'),
            ),
          ],
          if (booking != null) ...[
            Text(
              booking.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          Text('${booking.quantity} entrada(s) · ${booking.status}'),
          if (booking.experienceStatus != null) Text('Estado del evento: ${booking.experienceStatus}'),
            Text('${booking.currency} ${booking.total.toStringAsFixed(2)}'),
            if (booking.eventDate != null)
              Text('Evento: ${booking.eventDate!.toLocal()}'),
            if (booking.refundStatus != null)
              Text('Devolución: ${booking.refundStatus}'),
            if (booking.canPay)
              FilledButton(
                onPressed: _busy ? null : _pay,
                child: const Text('Pagar con Stripe'),
              ),
            if (booking.status == 'PENDING') ...[
              Text(
                'Retención hasta ${booking.expiresAt?.toLocal()}. Al volver del navegador, actualiza el estado del pago.',
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        _booking = await _service.cancel(booking.id);
                      }),
                child: const Text('Cancelar reserva'),
              ),
            ],
            OutlinedButton(
              onPressed: _busy ? null : _refresh,
              child: const Text('Actualizar estado'),
            ),
            if (booking.status == 'PAID')
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      body: SafeArea(child: MyTicketsScreen()),
                    ),
                  ),
                ),
                child: const Text('Ver mis entradas'),
              ),
          ],
          if (_booking == null && widget.bookingId != null && !_busy)
            OutlinedButton(
              onPressed: () => _run(() async {
                _booking = await _service.getBooking(widget.bookingId!);
              }),
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
  }
}
