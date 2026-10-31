/// Diccionario centralizado de internacionalización (Español e Inglés).
///
/// Cumple con el principio de responsabilidad única proveyendo textos traducidos
/// libres de emojis para todas las vistas multiplataforma del asistente.
class AppLocalizations {
  /// Código de idioma activo ('es' o 'en').
  final String languageCode;

  /// Crea una instancia del servicio de localización para el [languageCode] dado.
  const AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'advanced_filters': 'Fechas y cercanía',
      'date_from': 'Desde (Bolivia)',
      'date_to': 'Hasta (Bolivia)',
      'latitude': 'Latitud',
      'longitude': 'Longitud',
      'radius_km': 'Radio (km)',
      'only_available': 'Solo con cupos disponibles',
      'clear_filters': 'Limpiar',
      'apply_filters': 'Aplicar',
      'invalid_filters': 'Revisa fechas, coordenadas y radio.',
      'app_title': 'EXPERIENCIA',
      'app_subtitle': 'Experiencias que responden • Descubre y Conecta',
      'hero_tagline':
          'EXPERIENCIAS QUE RESPONDEN · DESCUBRIR · CONECTAR · OPTIMIZAR',
      'hero_title':
          'Conecta experiencias,\noptimiza audiencias\nen tiempo real',
      'hero_description':
          'Una plataforma inteligente para descubrir momentos únicos y conectar con grupos afines, resguardando siempre tu privacidad.',
      'feature_1_title': 'Matching Grupal Dinámico',
      'feature_1_desc': 'Alcanza el quórum mínimo viable automáticamente',
      'feature_2_title': 'Visión Efímera en RAM',
      'feature_2_desc': 'Cero almacenamiento biométrico bajo GDPR',
      'feature_3_title': 'Reserva Protegida',
      'feature_3_desc': 'Confirmación transparente al completar el cupo mínimo',
      'nav_discover': 'Descubrir',
      'nav_profile': 'Mi Perfil',
      'nav_tickets': 'Entradas',
      'nav_notifications': 'Avisos',
      'welcome_badge': 'BIENVENIDO A EXPERIENCIA',
      'login_header': 'Accede a tu cuenta.',
      'register_header': 'Crea tu acceso.',
      'auth_subtitle':
          'Únete como asistente para explorar y reservar experiencias en cualquier dispositivo.',
      'tab_login': 'Iniciar sesión',
      'tab_register': 'Crear cuenta',
      'label_fullname': 'Nombre completo',
      'hint_fullname': 'Tu nombre y apellido',
      'label_firstname': 'Nombre',
      'hint_firstname': 'Ingresa tu nombre',
      'label_lastname': 'Apellido',
      'hint_lastname': 'Ingresa tu apellido',
      'label_email': 'Correo electrónico',
      'hint_email': 'nombre@correo.com',
      'label_password': 'Contraseña',
      'hint_password': 'Mínimo 8 caracteres',
      'show_password': 'Mostrar',
      'hide_password': 'Ocultar',
      'attendee_role_title': 'Quiero ser Asistente',
      'attendee_role_desc': 'Descubrir y reservar',
      'btn_login': 'Iniciar sesión',
      'btn_register': 'Crear mi cuenta',
      'terms_footer':
          'Al continuar aceptas nuestros Términos de uso y Política de privacidad.',
      'validation_error':
          'Por favor completa un correo válido y una contraseña de al menos 6 caracteres.',
      'validation_register_error':
          'Por favor ingresa tu nombre completo, correo válido y contraseña.',
      'api_error_prefix': 'No se pudo conectar con el servidor API:',
      'btn_retry': 'Reintentar conexión',
      'search_hint': 'Buscar eventos, talleres, catas, zonas...',
      'quorum_banner_text':
          'Quórum Mínimo: Tu reserva activa el evento cuando se alcanza la meta de asistentes.',
      'quorum_dialog_title': '¿Cómo funciona el Quórum?',
      'quorum_dialog_intro':
          'EXPERIENCIA garantiza que ningún evento se cancele de imprevisto:',
      'quorum_dialog_p1':
          'Cada actividad tiene un Quórum Mínimo de asistentes necesarios para que el evento se confirme.',
      'quorum_dialog_p2':
          'Las reservas suman al indicador de la barra en tiempo real. Al llegar a la meta, el evento queda CONFIRMADO.',
      'quorum_dialog_p3':
          'Si la fecha límite llega sin alcanzar el quórum, tu reserva queda protegida al 100% sin cargos.',
      'btn_understood': 'Entendido',
      'mod_all': 'Todos',
      'mod_in_person': 'Presencial',
      'mod_virtual': 'Virtual',
      'mod_hybrid': 'Híbrido',
      'cat_all': 'Todos',
      'for_you': 'Para ti',
      'for_you_subtitle': 'Experiencias seleccionadas según tus intereses',
      'for_you_banner_prefix': 'Mostrando experiencias según tus preferencias',
      'no_for_you_events_subtitle':
          'No hay experiencias activas que coincidan con tus preferencias actuales. Puedes explorar todas las categorías o agregar más intereses en tu perfil.',
      'available_events': 'Experiencias Disponibles',
      'cat_gastronomy': 'Gastronomía',
      'cat_art': 'Arte y Pintura',
      'cat_music': 'Música y Conciertos',
      'cat_workshops': 'Talleres y Educación',
      'cat_networking': 'Networking y Negocios',
      'cat_wellness': 'Bienestar y Outdoors',
      'topic_coffee': 'Café de especialidad',
      'topic_tasting': 'Cata y Maridaje',
      'topic_electronic': 'DJ y Electrónica',
      'topic_tech': 'Tecnología y Software',
      'topic_design': 'Diseño UI/UX',
      'topic_photo': 'Fotografía',
      'topic_yoga': 'Yoga y Mindfulness',
      'no_events_title': 'No hay experiencias disponibles',
      'no_events_subtitle':
          'El catálogo está vacío o no existen resultados para los filtros aplicados.',
      'status_confirmed': 'Confirmado por Quórum',
      'status_pending_slots': 'Faltan cupos para quórum:',
      'min_goal': 'Meta mín',
      'max_cap': 'Aforo máx',
      'people': 'personas',
      'slots': 'cupos',
      'price_per_person': 'Cupo por asistente',
      'btn_view_detail': 'Ver Detalle',
      'btn_matching_search': 'Buscar grupo por afinidad',
      'btn_book_tickets': 'Reservar entradas',
      'matching_title': 'Grupo por afinidad',
      'matching_banner_desc':
          'La postulación reúne asistentes afines para alcanzar el quórum. Cuando el grupo se complete, cada miembro reserva y paga sus entradas.',
      'matching_your_group': 'Tu grupo asignado',
      'matching_forming_group': 'Grupo en formación',
      'matching_members_label': 'Interesados en el grupo',
      'matching_leave_btn': 'Retirar postulación',
      'matching_no_group_yet':
          'Todavía no participas de un grupo. Postúlate indicando tu disponibilidad horaria.',
      'matching_form_kicker': 'POSTULARME AL GRUPO',
      'matching_from_label': 'Disponible desde (hora local)',
      'matching_to_label': 'Disponible hasta (hora local)',
      'matching_zone_label': 'Zona preferida (opcional)',
      'matching_apply_btn': 'Postularme al grupo',
      'matching_refresh_btn': 'Actualizar estado del grupo',
      'matching_direct_checkout_btn': 'Reservar entradas directamente',
      'matching_leave_confirm_title': '¿Retirar postulación?',
      'matching_leave_confirm_desc':
          'Dejarás de formar parte del grupo de afinidad para esta experiencia.',
      'btn_cancel': 'Cancelar',
      'btn_withdraw': 'Retirar',
      'notif_title': 'Avisos',
      'btn_refresh': 'Actualizar',
      'notif_empty': 'No hay avisos en esta página.',
      'notif_view_exp': 'Ver experiencia',
      'notif_mark_read': 'Marcar leído',
      'notif_previous': 'Anteriores',
      'notif_older': 'Más antiguos',
      'notif_offline_error': 'Sin conexión. Reintentaremos recuperar los avisos.',
      'tickets_title': 'Mis reservas',
      'tickets_subtitle': 'Historial de compras y entradas digitales',
      'tickets_empty_title': 'Todavía no tienes reservas',
      'tickets_empty_subtitle': 'Explora el catálogo y reserva tus próximas experiencias.',
      'refund_confirm_desc':
          '¿Deseas solicitar el reembolso completo? Las entradas emitidas se anularán de inmediato.',
      'ticket_used_note': 'Esta entrada ya fue registrada en puerta',
      'ticket_code_label': 'Código de validación:',
      'tickets_empty': 'Aún no tienes entradas reservadas.',
      'checkout_title': 'Confirmar Reserva',
      'btn_close': 'Cerrar',
      'btn_refund': 'Solicitar devolución',
      'about_event': 'Sobre esta experiencia',
      'exact_address': 'Dirección del encuentro',
      'price_currency': 'Bs.',
      'quorum_confirmed_desc':
          'Este evento ya alcanzó el mínimo de asistentes requerido y se realizará con total certeza.',
      'quorum_pending_desc':
          'Tu participación ayudará a alcanzar la meta mínima para activar esta experiencia.',
      'profile_title': 'Mi Perfil de Asistente',
      'label_city': 'Ciudad',
      'hint_city': 'Ingresa tu ciudad',
      'label_zone': 'Barrio / Zona',
      'hint_zone': 'Ingresa tu barrio o zona',
      'label_phone': 'Teléfono',
      'hint_phone': 'Ingresa tu número de teléfono',
      'label_bio': 'Biografía',
      'hint_bio': 'Cuéntale a la comunidad un poco sobre ti...',
      'active': 'activos',
      'interests_title': 'Intereses y preferencias',
      'interests_subtitle':
          'Toca los temas predeterminados para agregarlos o quitarlos al instante y optimizar tus afinidades en el matching.',
      'interests_empty':
          'Aún no has seleccionado intereses. Toca los temas de abajo para comenzar.',
      'interests_popular': 'Temas recomendados para matching:',
      'interests_custom_title': '¿Otro tema específico? (Opcional)',
      'hint_add_interest': 'Escribe un interés y presiona el botón agregar',
      'hint_add_custom_interest': 'Ej. Cocina fusión, Fotografía nocturna...',
      'matching_suggested_zones': 'Zonas sugeridas:',
      'btn_save_changes': 'Guardar cambios',
      'profile_saved_toast': 'Perfil actualizado en el servidor correctamente.',
      'theme_dark': 'Modo Oscuro',
      'theme_light': 'Modo Claro',
      'btn_logout': 'Cerrar sesión',
    },
    'en': {
      'advanced_filters': 'Dates and nearby search',
      'date_from': 'From (Bolivia)',
      'date_to': 'Until (Bolivia)',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'radius_km': 'Radius (km)',
      'only_available': 'Available slots only',
      'clear_filters': 'Clear',
      'apply_filters': 'Apply',
      'invalid_filters': 'Check dates, coordinates and radius.',
      'app_title': 'EXPERIENCIA',
      'app_subtitle': 'Responsive Experiences • Discover & Connect',
      'hero_tagline': 'RESPONSIVE EXPERIENCES · DISCOVER · CONNECT · OPTIMIZE',
      'hero_title': 'Connect experiences,\noptimize audiences\nin real time',
      'hero_description':
          'An intelligent platform to discover unique moments and connect with like-minded groups while strictly protecting your privacy.',
      'feature_1_title': 'Dynamic Group Matching',
      'feature_1_desc': 'Reach the minimum viable quorum automatically',
      'feature_2_title': 'Ephemeral RAM Vision',
      'feature_2_desc': 'Zero biometric storage under GDPR compliance',
      'feature_3_title': 'Protected Booking',
      'feature_3_desc': 'Transparent confirmation once minimum quorum is met',
      'nav_discover': 'Discover',
      'nav_profile': 'Profile',
      'nav_tickets': 'Tickets',
      'nav_notifications': 'Alerts',
      'welcome_badge': 'WELCOME TO EXPERIENCIA',
      'login_header': 'Sign in to your account.',
      'register_header': 'Create your access.',
      'auth_subtitle':
          'Join as an attendee to explore and book experiences across any device.',
      'tab_login': 'Sign In',
      'tab_register': 'Create Account',
      'label_fullname': 'Full Name',
      'hint_fullname': 'Your first and last name',
      'label_firstname': 'First Name',
      'hint_firstname': 'Enter your first name',
      'label_lastname': 'Last Name',
      'hint_lastname': 'Enter your last name',
      'label_email': 'Email Address',
      'hint_email': 'name@email.com',
      'label_password': 'Password',
      'hint_password': 'Minimum 8 characters',
      'show_password': 'Show',
      'hide_password': 'Hide',
      'attendee_role_title': 'I want to be an Attendee',
      'attendee_role_desc': 'Discover and book',
      'btn_login': 'Sign In',
      'btn_register': 'Create My Account',
      'terms_footer':
          'By continuing, you agree to our Terms of Use and Privacy Policy.',
      'validation_error':
          'Please enter a valid email and a password of at least 6 characters.',
      'validation_register_error':
          'Please enter your full name, a valid email, and password.',
      'api_error_prefix': 'Could not connect to the API server:',
      'btn_retry': 'Retry connection',
      'search_hint': 'Search events, workshops, tastings, zones...',
      'quorum_banner_text':
          'Minimum Quorum: Your booking activates the event once the attendee goal is reached.',
      'quorum_dialog_title': 'How Does Quorum Work?',
      'quorum_dialog_intro':
          'EXPERIENCIA ensures no event is unexpectedly cancelled:',
      'quorum_dialog_p1':
          'Each activity has a Minimum Quorum of attendees required for the host to confirm the event.',
      'quorum_dialog_p2':
          'Bookings add to the live progress bar. Once the goal is reached, the event is CONFIRMED.',
      'quorum_dialog_p3':
          'If the deadline arrives without reaching quorum, your reservation is 100% protected with zero charges.',
      'btn_understood': 'Got It',
      'mod_all': 'All',
      'mod_in_person': 'In-Person',
      'mod_virtual': 'Virtual',
      'mod_hybrid': 'Hybrid',
      'cat_all': 'All',
      'for_you': 'For You',
      'for_you_subtitle': 'Experiences tailored to your preferences',
      'for_you_banner_prefix': 'Showing experiences tailored to your preferences',
      'no_for_you_events_subtitle':
          'No active experiences match your current preferences. You can explore all categories or add more interests in your profile.',
      'available_events': 'Available Experiences',
      'cat_gastronomy': 'Gastronomy',
      'cat_art': 'Art & Painting',
      'cat_music': 'Music & Concerts',
      'cat_workshops': 'Workshops & Education',
      'cat_networking': 'Networking & Business',
      'cat_wellness': 'Wellness & Outdoors',
      'topic_coffee': 'Specialty Coffee',
      'topic_tasting': 'Tasting & Pairing',
      'topic_electronic': 'DJ & Electronic',
      'topic_tech': 'Technology & Software',
      'topic_design': 'UI/UX Design',
      'topic_photo': 'Photography',
      'topic_yoga': 'Yoga & Mindfulness',
      'no_events_title': 'No experiences available',
      'no_events_subtitle':
          'The catalog is empty or no results match the selected filters.',
      'status_confirmed': 'Confirmed by Quorum',
      'status_pending_slots': 'Slots needed for quorum:',
      'min_goal': 'Min goal',
      'max_cap': 'Max cap',
      'people': 'people',
      'slots': 'slots',
      'price_per_person': 'Price per attendee',
      'btn_view_detail': 'View Details',
      'btn_matching_search': 'Find affinity group',
      'btn_book_tickets': 'Book tickets',
      'matching_title': 'Affinity Group',
      'matching_banner_desc':
          'Postulation brings together kindred attendees to reach quorum. When the group completes, each member books and pays for their tickets.',
      'matching_your_group': 'Your assigned group',
      'matching_forming_group': 'Group forming',
      'matching_members_label': 'Interested attendees',
      'matching_leave_btn': 'Withdraw postulation',
      'matching_no_group_yet':
          'You are not in a group yet. Apply by indicating your time availability.',
      'matching_form_kicker': 'APPLY TO GROUP',
      'matching_from_label': 'Available from (local time)',
      'matching_to_label': 'Available until (local time)',
      'matching_zone_label': 'Preferred zone (optional)',
      'matching_apply_btn': 'Apply to group',
      'matching_refresh_btn': 'Refresh group status',
      'matching_direct_checkout_btn': 'Book tickets directly',
      'matching_leave_confirm_title': 'Withdraw postulation?',
      'matching_leave_confirm_desc':
          'You will leave the affinity group for this experience.',
      'btn_cancel': 'Cancel',
      'btn_withdraw': 'Withdraw',
      'notif_title': 'Alerts',
      'btn_refresh': 'Refresh',
      'notif_empty': 'No alerts on this page.',
      'notif_view_exp': 'View experience',
      'notif_mark_read': 'Mark as read',
      'notif_previous': 'Previous',
      'notif_older': 'Older',
      'notif_offline_error': 'Offline. We will retry fetching notices.',
      'tickets_title': 'My Bookings',
      'tickets_subtitle': 'Purchase history and digital tickets',
      'tickets_empty_title': 'No bookings yet',
      'tickets_empty_subtitle': 'Explore the catalog and book your next experiences.',
      'refund_confirm_desc':
          'Do you want to request a full refund? Issued tickets will be voided immediately.',
      'ticket_used_note': 'This ticket was already used at entry',
      'ticket_code_label': 'Validation code:',
      'tickets_empty': 'No tickets booked yet.',
      'checkout_title': 'Confirm Booking',
      'btn_close': 'Close',
      'btn_refund': 'Request refund',
      'about_event': 'About this experience',
      'exact_address': 'Venue Address',
      'price_currency': 'Bs.',
      'quorum_confirmed_desc':
          'This event has already reached the minimum required attendees and is guaranteed to take place.',
      'quorum_pending_desc':
          'Your participation will help reach the minimum goal to activate this experience.',
      'profile_title': 'Attendee Profile',
      'label_city': 'City',
      'hint_city': 'Enter your city',
      'label_zone': 'Neighborhood / Zone',
      'hint_zone': 'Enter your neighborhood or zone',
      'label_phone': 'Phone',
      'hint_phone': 'Enter your phone number',
      'label_bio': 'Biography',
      'hint_bio': 'Tell the community a little about yourself...',
      'active': 'active',
      'interests_title': 'Interests & Preferences',
      'interests_subtitle':
          'Tap default topics to instantly add or remove them and optimize your affinity matching.',
      'interests_empty':
          'No interests selected yet. Tap the topics below to get started.',
      'interests_popular': 'Recommended topics for matching:',
      'interests_custom_title': 'Other specific topic? (Optional)',
      'hint_add_interest': 'Type an interest and press the add button',
      'hint_add_custom_interest': 'E.g. Fusion cuisine, Night photography...',
      'matching_suggested_zones': 'Suggested zones:',
      'btn_save_changes': 'Save Changes',
      'profile_saved_toast': 'Profile updated on the server successfully.',
      'theme_dark': 'Dark Mode',
      'theme_light': 'Light Mode',
      'btn_logout': 'Sign Out',
    },
  };

  /// Obtiene la cadena traducida asociada a la clave [key] según el [languageCode] actual.
  String tr(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['es']?[key] ??
        key;
  }

  /// Traduce la etiqueta de categoría general o temática manteniendo compatibilidad con la API en inglés y español.
  String translateCategory(String rawCategory) {
    final lower = rawCategory.trim().toLowerCase();
    if (lower == 'todos' || lower == 'all') {
      return tr('cat_all');
    }
    if (lower == 'para ti' || lower == 'for you') {
      return tr('for_you');
    }
    if (lower.contains('gastronom') || lower == 'gastronomy') {
      return tr('cat_gastronomy');
    }
    if (lower.contains('arte') || lower.contains('art')) {
      return tr('cat_art');
    }
    if (lower.contains('música') || lower.contains('musica') || lower.contains('music')) {
      return tr('cat_music');
    }
    if (lower.contains('taller') ||
        lower.contains('workshop') ||
        lower.contains('educaci') ||
        lower.contains('education')) {
      return tr('cat_workshops');
    }
    if (lower.contains('networking') ||
        lower.contains('negocio') ||
        lower.contains('business')) {
      return tr('cat_networking');
    }
    if (lower.contains('bienestar') ||
        lower.contains('wellness') ||
        lower.contains('outdoor')) {
      return tr('cat_wellness');
    }
    if (lower.contains('café') || lower.contains('cafe') || lower.contains('coffee')) {
      return tr('topic_coffee');
    }
    if (lower.contains('maridaje') || lower.contains('tasting') || lower.contains('cata')) {
      return tr('topic_tasting');
    }
    if (lower.contains('dj') || lower.contains('electr')) {
      return tr('topic_electronic');
    }
    if (lower.contains('tecnolog') ||
        lower.contains('software') ||
        lower.contains('tech')) {
      return tr('topic_tech');
    }
    if (lower.contains('diseño') || lower.contains('design') || lower.contains('ui/ux')) {
      return tr('topic_design');
    }
    if (lower.contains('fotograf') || lower.contains('photo')) {
      return tr('topic_photo');
    }
    if (lower.contains('yoga') || lower.contains('mindfulness')) {
      return tr('topic_yoga');
    }
    return rawCategory;
  }
}
