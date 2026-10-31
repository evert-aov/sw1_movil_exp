# Catálogo y perfil

[Índice](README.md) · [Servicio](../lib/features/experience/services/experience_service.dart) · [Filtros](../lib/features/experience/models/experience_filter_model.dart) · [Catálogo](../lib/features/experience/screens/catalog_screen.dart) · [Perfil](../lib/features/auth/screens/profile_screen.dart)

## CU-04 / HU-05: Catálogo y exploración personalizada

CU-04/HU-05 consulta categorías y catálogo real del servidor. `ExperienceFilterModel` incluye texto, categoría, modalidad/zona, fechas, latitud/longitud/radio, disponibilidad y página. `ExperienceService` envía `page_size=12` y conserva `total` y `total_pages`; la pantalla dispone de controles de paginación.

* **Pestaña 'Para ti' / 'For You' por defecto:** Cuando el asistente tiene intereses configurados en su perfil, el catálogo selecciona automáticamente la categoría `'Para ti'`, filtrando las experiencias coincidentes por palabras clave y categorías afines. Un banner superior destaca las preferencias aplicadas.
* **Cálculo preciso de resultados:** En la vista `'Para ti'`, el contador de cabecera refleja estrictamente las experiencias filtradas (`resultCount = isForYou ? _experiences.length : _service.totalResults`), evitando mostrar el total global del servidor cuando la vista personalizada contiene menos elementos.
* **Diseño responsivo multi-columna:** El catálogo detecta el ancho de pantalla (`LayoutBuilder`). En anchos $\ge 720\text{px}$ (tablets y pantallas amplias) organiza las tarjetas en cuadrícula de dos columnas mediante `Wrap`; en dispositivos móviles estándar se ordenan en lista vertical.
* **Filtros avanzados ergonómicos:** El diálogo *Fechas y cercanía* organiza los selectores de fecha en una fila horizontal con espaciado vertical de 14px entre latitud, longitud, radio (km) y el conmutador de cupos. Las fechas se normalizan a la zona horaria de Bolivia (UTC-04:00).
* **Búsqueda con rebote:** La entrada de texto aplica `Timer` de 400ms para evitar sobrecarga de peticiones. Cambiar filtros o términos reinicia la paginación a la página uno.

`ExperienceModel` computa `heldSlots` al calcular cupos y utiliza el mínimo viable para la barra de quórum. La tarjeta y el modal de detalle (`ExperienceDetailScreen`) enlazan directamente con la reserva (`CheckoutScreen`) y el emparejamiento grupal (`MatchingScreen`).

## CU-02 / HU-03: Perfil y preferencias estandarizadas

`ProfileScreen` gestiona los datos personales, avatar por URL e intereses temáticos sincronizados con `AuthService`:

* **Nube de temas por defecto con un solo toque:** Presenta un conjunto de temas predeterminados compatibles con el backend (`Gastronomía`, `Café de especialidad`, `Cata y Maridaje`, `Arte y Pintura`, `Música y Conciertos`, `Música en vivo`, `DJ y Electrónica`, `Talleres y Educación`, `Tecnología y Software`, `Networking y Negocios`, `Bienestar y Outdoors`, `Yoga y Mindfulness`, `Diseño UI/UX`, `Fotografía`).
* **Interacción sin teclado:** Cada tema se renderiza como `FilterChip` interactivo. Al tocarlo se agrega o retira al instante con retroalimentación visual e indicador de activos, garantizando un vocabulario unificado que optimiza la afinidad de Jaccard en el algoritmo de matching.
* **Entrada personalizada opcional:** Se ofrece un campo secundario para agregar temas libres adicionales que no figuren en la lista predeterminada.
* **Soporte bilingüe integral:** Mediante `i18n.translateCategory()`, todos los temas, categorías y opciones se muestran fluidamente en Español o Inglés según el idioma activo.

