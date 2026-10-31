import 'package:flutter_test/flutter_test.dart';
import 'package:experiencia_movil/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations translation integrity (ES / EN)', () {
    test('Translates categories and for_you correctly in Spanish', () {
      const i18nEs = AppLocalizations('es');
      expect(i18nEs.translateCategory('Para ti'), 'Para ti');
      expect(i18nEs.translateCategory('Todos'), 'Todos');
      expect(i18nEs.translateCategory('Gastronomía'), 'Gastronomía');
      expect(i18nEs.translateCategory('Arte y Pintura'), 'Arte y Pintura');
      expect(i18nEs.translateCategory('Música y Conciertos'), 'Música y Conciertos');
      expect(i18nEs.tr('nav_tickets'), 'Entradas');
      expect(i18nEs.tr('nav_notifications'), 'Avisos');
      expect(i18nEs.tr('available_events'), 'Experiencias Disponibles');
      expect(
        i18nEs.tr('for_you_banner_prefix'),
        'Mostrando experiencias según tus preferencias',
      );
    });

    test('Translates categories and for_you correctly in English', () {
      const i18nEn = AppLocalizations('en');
      expect(i18nEn.translateCategory('Para ti'), 'For You');
      expect(i18nEn.translateCategory('Todos'), 'All');
      expect(i18nEn.translateCategory('Gastronomía'), 'Gastronomy');
      expect(i18nEn.translateCategory('Arte y Pintura'), 'Art & Painting');
      expect(i18nEn.translateCategory('Música y Conciertos'), 'Music & Concerts');
      expect(i18nEn.tr('nav_tickets'), 'Tickets');
      expect(i18nEn.tr('nav_notifications'), 'Alerts');
      expect(i18nEn.tr('available_events'), 'Available Experiences');
      expect(
        i18nEn.tr('for_you_banner_prefix'),
        'Showing experiences tailored to your preferences',
      );
    });

    test('Matching and tickets keys exist and differ between languages', () {
      const es = AppLocalizations('es');
      const en = AppLocalizations('en');

      expect(es.tr('matching_title'), 'Grupo por afinidad');
      expect(en.tr('matching_title'), 'Affinity Group');

      expect(es.tr('matching_apply_btn'), 'Postularme al grupo');
      expect(en.tr('matching_apply_btn'), 'Apply to group');

      expect(es.tr('tickets_title'), 'Mis reservas');
      expect(en.tr('tickets_title'), 'My Bookings');
    });
  });
}
