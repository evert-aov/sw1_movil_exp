import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/ticket_model.dart';
import '../services/booking_service.dart';
import '../widgets/ticket_qr.dart';
import 'checkout_screen.dart';

/// Historial propio con entradas anidadas, pagos pendientes y devoluciones.
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});
  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
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
      builder: (_) => AlertDialog(
        title: Text(ticket.isUsed ? 'Entrada utilizada' : 'Entrada digital'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TicketQr(ticket: ticket),
              SelectableText(ticket.ticketCode),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _refund(BookingModel booking) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devolución completa'),
        content: const Text(
          '¿Solicitar la devolución? Las entradas dejarán de ser válidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Solicitar'),
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

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Mis reservas y entradas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        TextButton(
          onPressed: _busy ? null : _load,
          child: const Text('Actualizar'),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (!_busy && _error == null && _bookings.isEmpty)
          const Text('Todavía no tienes reservas.'),
        for (final booking in _bookings)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                    Text('${booking.status} · ${booking.quantity} entrada(s)'),
                    if (booking.experienceStatus != null) Text('Evento: ${booking.experienceStatus}'),
                  Text(
                    '${booking.currency} ${booking.total.toStringAsFixed(2)}',
                  ),
                  if (booking.eventDate != null)
                    Text('${booking.eventDate!.toLocal()}'),
                  if (booking.refundStatus != null)
                    Text('Devolución: ${booking.refundStatus}'),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CheckoutScreen(bookingId: booking.id),
                        ),
                      );
                      if (mounted) _load();
                    },
                    child: const Text('Ver reserva y pago'),
                  ),
                  if (booking.status == 'PAID' && booking.refundStatus == null)
                    for (var i = 0; i < booking.tickets.length; i++)
                      OutlinedButton(
                        onPressed: () => _showTicket(booking.tickets[i]),
                        child: Text('Entrada ${i + 1} · Mostrar QR'),
                      ),
                  if (booking.canRefund)
                    TextButton(
                      onPressed: _busy ? null : () => _refund(booking),
                      child: const Text('Solicitar devolución'),
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
