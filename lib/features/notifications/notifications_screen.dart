import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/network/http_client.dart';
import '../experience/screens/experience_detail_screen.dart';
import '../experience/services/experience_service.dart';

/// Bandeja persistente: recupera mensajes al abrirla y consulta cada 30 segundos.
class NotificationsScreen extends StatefulWidget {
  final AppLocalizations i18n;
  const NotificationsScreen({super.key, required this.i18n});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _client = HttpClient();
  List<Map<String, dynamic>> _items = [];
  String? _error;
  bool _busy = false;
  int _offset = 0;
  Timer? _timer;

  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load()); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final rows = await _client.get('/notifications', queryParameters: {'limit': '50', 'offset': '$_offset'}) as List<dynamic>;
      if (mounted) setState(() { _items = rows.cast<Map<String, dynamic>>(); _error = null; });
    } catch (_) { if (mounted) setState(() => _error = 'Sin conexión. Reintentaremos recuperar los avisos.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _read(Map<String, dynamic> item) async {
    try { await _client.patch('/notifications/${item['id']}/read', {}); await _load(); }
    catch (_) { if (mounted) setState(() => _error = 'No se pudo marcar el aviso.'); }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    try {
      final experience = await ExperienceService().getExperienceById(item['experience_id'] as String);
      if (!mounted || experience == null) return;
      await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ExperienceDetailScreen(experience: experience, i18n: widget.i18n)));
    } catch (_) { if (mounted) setState(() => _error = 'No se pudo abrir la experiencia.'); }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(onRefresh: _load, child: ListView(
    padding: const EdgeInsets.all(20), children: [
      Text('Avisos', style: Theme.of(context).textTheme.headlineSmall),
      TextButton(onPressed: _busy ? null : _load, child: const Text('Actualizar')),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      if (!_busy && _error == null && _items.isEmpty) const Text('No hay avisos en esta página.'),
      for (final item in _items) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['message'] as String),
          Text('${DateTime.parse(item['created_at'] as String).toLocal()}'),
          TextButton(onPressed: () => _open(item), child: const Text('Ver experiencia')),
          if (item['read_at'] == null) TextButton(onPressed: () => _read(item), child: const Text('Marcar leído')),
        ],
      ))),
      Row(children: [
        TextButton(onPressed: _offset == 0 || _busy ? null : () { _offset -= 50; _load(); }, child: const Text('Anteriores')),
        TextButton(onPressed: _items.length < 50 || _busy ? null : () { _offset += 50; _load(); }, child: const Text('Más antiguos')),
      ]),
    ],
  ));
}
