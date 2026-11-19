/// Textos del Monitor de Telemetría en Vivo (HU-17) en Español e Inglés.
///
/// Se mantienen en un diccionario propio del módulo para no alterar el diccionario
/// central compartido por los demás módulos de la app.
class LiveMonitorStrings {
  /// Código de idioma activo ('es' o 'en').
  final String languageCode;

  /// Crea los textos para el [languageCode] dado.
  const LiveMonitorStrings(this.languageCode);

  static const Map<String, Map<String, String>> _values = {
    'es': {
      'entry': 'Monitor en vivo',
      'title': 'Monitor en vivo',
      'pair_title': 'Vincula este dispositivo',
      'pair_description':
          'En la consola web del anfitrión pulsa "Vincular tablet o celular" e ingresa aquí el código de 6 caracteres.',
      'code_label': 'Código',
      'pair_button': 'Vincular',
      'pairing': 'Vinculando...',
      'code_invalid': 'El código debe tener 6 caracteres.',
      'unpair': 'Desvincular',
      'light_green': 'Energía alta',
      'light_yellow': 'Energía media',
      'light_red': 'Energía baja',
      'light_none': 'Sin datos',
      'trend_rising': 'Subiendo',
      'trend_stable': 'Estable',
      'trend_falling': 'Bajando',
      'signal_live': 'En vivo',
      'signal_stale': 'Señal con retraso',
      'signal_noSignal': 'Sin señal',
      'connection_connecting': 'Conectando',
      'connection_reconnecting': 'Reconectando',
      'faces': 'rostros',
      'pulse': 'Pulso de energía · últimos 60 s',
      'pulse_empty': 'El pulso aparecerá cuando lleguen métricas.',
      'denied':
          'La vinculación ya no es válida. Genera un código nuevo en la consola web.',
      'privacy': 'Solo promedios anónimos. No se guardan imágenes ni rostros.',
      'mc_alert_title': 'La atención está bajando',
      'mc_manual_title': 'Dinámica sugerida',
      'mc_low_for': 'Atención baja durante',
      'mc_minutes': 'min',
      'mc_action_audienceQuestion': 'Lanzar pregunta',
      'mc_action_activeBreak': 'Iniciar pausa activa',
      'mc_action_shortBreak': 'Iniciar pausa',
      'mc_another': 'Otra idea',
      'mc_dismiss': 'Descartar',
      'mc_request': 'Necesito una dinámica',
      'mc_break_running': 'Pausa en curso',
      'mc_break_ends': 'El público regresa en',
      'mc_applied': 'Dinámica aplicada',
      'mc_expired': 'La atención se recuperó',
      'mc_error': 'No se pudo responder la alerta.',
    },
    'en': {
      'entry': 'Live monitor',
      'title': 'Live monitor',
      'pair_title': 'Pair this device',
      'pair_description':
          'In the host web console tap "Pair tablet or phone" and enter the 6-character code here.',
      'code_label': 'Code',
      'pair_button': 'Pair',
      'pairing': 'Pairing...',
      'code_invalid': 'The code must have 6 characters.',
      'unpair': 'Unpair',
      'light_green': 'High energy',
      'light_yellow': 'Medium energy',
      'light_red': 'Low energy',
      'light_none': 'No data',
      'trend_rising': 'Rising',
      'trend_stable': 'Steady',
      'trend_falling': 'Falling',
      'signal_live': 'Live',
      'signal_stale': 'Delayed signal',
      'signal_noSignal': 'No signal',
      'connection_connecting': 'Connecting',
      'connection_reconnecting': 'Reconnecting',
      'faces': 'faces',
      'pulse': 'Energy pulse · last 60 s',
      'pulse_empty': 'The pulse will appear once metrics arrive.',
      'denied':
          'This pairing is no longer valid. Generate a new code in the web console.',
      'privacy': 'Anonymous averages only. No images or faces are stored.',
      'mc_alert_title': 'Attention is dropping',
      'mc_manual_title': 'Suggested dynamic',
      'mc_low_for': 'Low attention for',
      'mc_minutes': 'min',
      'mc_action_audienceQuestion': 'Launch question',
      'mc_action_activeBreak': 'Start active break',
      'mc_action_shortBreak': 'Start break',
      'mc_another': 'Another idea',
      'mc_dismiss': 'Dismiss',
      'mc_request': 'I need a dynamic',
      'mc_break_running': 'Break in progress',
      'mc_break_ends': 'Audience returns in',
      'mc_applied': 'Dynamic applied',
      'mc_expired': 'Attention recovered',
      'mc_error': 'The alert could not be answered.',
    },
  };

  /// Devuelve el texto de [key] en el idioma activo, con respaldo en español.
  String tr(String key) {
    return _values[languageCode]?[key] ?? _values['es']?[key] ?? key;
  }
}
