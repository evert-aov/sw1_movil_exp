# Catálogo y perfil

[Índice](README.md) · [Servicio](../lib/features/experience/services/experience_service.dart) · [Filtros](../lib/features/experience/models/experience_filter_model.dart)

CU-04/HU-05 consulta categorías y catálogo real. ExperienceFilterModel incluye texto, categoría, modalidad/zona, fechas, latitud/longitud/radio, disponibilidad y página. ExperienceService envía page_size=12 y conserva total/total_pages; la pantalla tiene controles de paginación.

El diálogo Fechas y cercanía valida rango de fechas, coordenadas completas y radio. Los días se traducen a límites de calendario en Bolivia (UTC-04:00), independientemente de la zona del dispositivo. No se confunde zona textual con distancia GPS.

La búsqueda se retrasa brevemente para no consultar por cada pulsación. La pantalla descarta resultados antiguos al cambiar de consulta; el servicio preserva metadatos de la solicitud más reciente. Cambiar filtros vuelve a página uno.

ExperienceModel incluye heldSlots al calcular disponibilidad y usa el mínimo viable para progreso de quórum. Los pendientes no se presentan como cupos pagados. Detalle se abre como hoja modal y conecta con checkout y matching.

CU-02/Perfil permite editar datos, avatar por URL e intereses. Tema e idioma provienen de los controladores de core/; agregar traducciones ES/EN para nuevas acciones. Los errores de categorías se propagan a la pantalla en lugar de simular ausencia de categorías.

La integración PostgreSQL real y las pruebas Flutter siguen condicionadas por el entorno. El backend registra búsquedas efectivas; ExperienceService envía una sesión efímera para deduplicación, sin emitir registros desde cada widget.
