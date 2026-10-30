import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/http_client.dart';
import '../../booking/screens/checkout_screen.dart';
import '../models/matching_model.dart';
import '../services/matching_service.dart';

class MatchingScreen extends StatefulWidget {
  final String experienceId;
  const MatchingScreen({super.key, required this.experienceId});
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final _service = MatchingService();
  final _from = TextEditingController(), _to = TextEditingController(), _zone = TextEditingController();
  MatchingModel? _group;
  String? _error;
  bool _busy = false;
  Timer? _timer;
  int _sequence = 0;

  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load()); }
  @override
  void dispose() { _timer?.cancel(); _from.dispose(); _to.dispose(); _zone.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (_busy) return;
    final request = ++_sequence;
    try {
      final group = await _service.getMatchingStatus(widget.experienceId);
      if (mounted && request == _sequence) setState(() { _group = group; _error = null; });
    } on ApiException catch (error) {
      if (mounted && request == _sequence && error.statusCode != 404) setState(() => _error = error.message);
    } catch (error) { if (mounted && request == _sequence) setState(() => _error = error.toString()); }
  }

  Future<void> _apply() async {
    if (_busy) return;
    ++_sequence;
    final from = DateTime.tryParse(_from.text), to = DateTime.tryParse(_to.text);
    if ((_from.text.isNotEmpty || _to.text.isNotEmpty) && (from == null || to == null || !from.isBefore(to))) {
      setState(() => _error = 'Completa un rango válido de disponibilidad.'); return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final group = await _service.applyToMatchingGroup(widget.experienceId, from: from, to: to, zone: _zone.text);
      if (mounted) setState(() => _group = group);
    } catch (error) { if (mounted) setState(() => _error = error.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _leave() async {
    if (_busy) return;
    ++_sequence;
    setState(() => _busy = true);
    try { await _service.leave(widget.experienceId); if (mounted) setState(() => _group = null); }
    catch (error) { if (mounted) setState(() => _error = error.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Grupo por afinidad')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('La postulación expresa interés. Reserva y paga por separado para confirmar tus entradas.'),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (_group != null) ...[
        Text('${_group!.currentMembers} de ${_group!.targetQuorum} personas interesadas · ${_group!.status}'),
        Text('Fecha límite: ${_group!.deadline.toLocal()}'),
        if (_group!.currentMembers > 1) Text('Afinidad: ${(_group!.affinityScore * 100).toStringAsFixed(0)}%'),
        Text('${_group!.paidSlots} cupos confirmados. ${_group!.experienceConfirmed ? "Evento confirmado." : "Pendiente de quórum pagado."}'),
      ] else const Text('Todavía no participas de un grupo.'),
      if (_group?.hasJoined == true)
        TextButton(onPressed: _busy ? null : _leave, child: const Text('Retirar postulación'))
      else ...[
        TextField(controller: _from, decoration: const InputDecoration(labelText: 'Disponible desde (hora local)', hintText: '2030-01-01T18:00')),
        TextField(controller: _to, decoration: const InputDecoration(labelText: 'Disponible hasta (hora local)', hintText: '2030-01-01T22:00')),
        TextField(controller: _zone, decoration: const InputDecoration(labelText: 'Zona preferida (opcional)')),
        FilledButton(onPressed: _busy || _group?.status == 'EXPIRED' ? null : _apply, child: const Text('Postularme')),
      ],
      OutlinedButton(onPressed: _busy ? null : _load, child: const Text('Actualizar grupo')),
      FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(experienceId: widget.experienceId))), child: const Text('Reservar entradas')),
    ]),
  );
}
