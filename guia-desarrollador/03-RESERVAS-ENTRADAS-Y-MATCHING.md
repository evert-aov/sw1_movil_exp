# Reservas, entradas, matching y avisos — sprint 2

[Índice](README.md) · [Reservas](../lib/features/booking/services/booking_service.dart) · [Checkout](../lib/features/booking/screens/checkout_screen.dart) · [Mis Entradas](../lib/features/booking/screens/my_tickets_screen.dart) · [Matching](../lib/features/matching/screens/matching_screen.dart) · [Avisos](../lib/features/notifications/notifications_screen.dart)

## CU-05 / HU-06, HU-07: Compra, retención y entradas digitales

* **Diseño moderno de Checkout (`CheckoutScreen`):**
  - Selector de cantidad de 1 a 20 entradas con control incremental (stepper) estilizado y previsualización de importe total en Bs.
  - Visualización del temporizador regresivo de retención de cupos (15 minutos) con advertencia visual antes de expirar.
  - Clave de idempotencia única reutilizable por operación para evitar cobros dobles en reintentos de conexión.
  - Apertura segura de Stripe Checkout con `url_launcher` restringida exclusivamente al host oficial `https://checkout.stripe.com`.
  - Reconciliación automática de estado financiero al regresar la aplicación al primer plano, más botón manual de comprobación.

* **Historial y pases digitales (`MyTicketsScreen`):**
  - Tarjetas agrupadas con distintivos semánticos de estado (`PAGADO`, `CONFIRMADO`, `PENDIENTE`, `CANCELADO`).
  - Diálogo de pase de acceso con código QR generado localmente mediante el paquete `qr` (sin servicios externos ni envío de datos personales) con margen de 4 módulos.
  - Muestra del código de validación alfanumérico monoespaciado para escaneo o comprobación manual en puerta por parte del anfitrión.
  - Flujo de solicitud de reembolso completo antes del inicio del evento para reservas con entradas no utilizadas.

## CU-06 / HU-08, HU-09: Grupos por afinidad y quórum

* **Pantalla de Matching grupal (`MatchingScreen`):**
  - Tarjeta de estado de grupo con indicador visual de quórum (`currentMembers / targetQuorum`) y barra de progreso animada.
  - Selector rápido de zonas sugeridas mediante chips táctiles (`Equipetrol`, `Centro`, `Urbarí`, `Las Palmas`, `Manzana 40`, `Urubó`, `Zona Norte`) que agilizan la postulación sin necesidad de escribir texto.
  - Selectores interactivos de fecha y hora (`DatePicker` + `TimePicker`) que convierten la hora local del dispositivo a formato ISO-8601 UTC para el servidor.
  - Espaciado ergonómico de 14px a 18px entre campos de formulario y botones de acción principal.
  - Actualización periódica cada 15 segundos mediante sondeo controlado (`Timer.periodic`) mientras la pantalla permanece abierta.
  - Acción de retiro voluntario de postulación con diálogo de confirmación que no afecta compras previas de entradas.

## Notificaciones y avisos de quórum

* **Bandeja persistente (`NotificationsScreen`):**
  - Consume el endpoint `GET /notifications` con soporte de paginación (`limit=50`).
  - Sondeo en segundo plano cada 30 segundos mientras la bandeja está abierta.
  - Marcado de lectura idempotente mediante `PATCH /notifications/{id}/read`.
  - Navegación directa al modal de la experiencia asociada desde el aviso recibido.

## Internacionalización completa (ES / EN)

Todas las pantallas de reservas, entradas, matching y notificaciones implementan el contrato `i18n`, traduciendo títulos, estados, botones de acción, etiquetas de formularios y mensajes de error de forma consistente entre Español e Inglés.

