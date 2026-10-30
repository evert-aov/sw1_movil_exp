# Reservas, entradas, matching y avisos — sprint 2

[Índice](README.md) · [Reservas](../lib/features/booking/services/booking_service.dart) · [Matching](../lib/features/matching/services/matching_service.dart)

## CU-05: compra y entradas

Detalle abre CheckoutScreen. El asistente elige 1–20 entradas; la pantalla conserva una clave de operación durante reintentos. BookingRequestModel envía solo experience_id/quantity: el servidor calcula dinero y capacidad.

Stripe Checkout se abre con url_launcher en navegador externo, únicamente para https://checkout.stripe.com. Al regresar al primer plano se consulta el backend; también hay botón Actualizar estado. El retorno web usa FRONTEND_URL del backend y no crea una sesión web para el usuario móvil. La confirmación se demuestra en la app consultando la reserva.

La pestaña Entradas lista BookingModel con tickets anidados, estados económico/evento, moneda, fecha y devolución. Los fallos HTTP se muestran como errores. Cada QR se genera localmente con qr desde el payload firmado y margen de cuatro módulos; no contiene datos personales añadidos por el cliente.

Se permite solicitar devolución completa antes del evento y sin entradas utilizadas, según validación del servidor. pending no se muestra como dinero devuelto. El ingreso necesita autorización y conectividad del anfitrión; no se promete validación offline ni almacenamiento persistente offline de pases.

Después de cambiar pubspec.yaml ejecutar flutter pub get para preparar también los plugins nativos de url_launcher; el análisis estático no demuestra apertura de navegador en dispositivo.

## CU-06: matching y avisos

Detalle abre MatchingScreen para consultar grupo sin postular. POST /matching/apply envía disponibilidad/zona opcionales; intereses provienen del perfil. Los campos de disponibilidad usan hora local del dispositivo y se convierten a UTC.

GET /matching/group/{id} actualiza estado cada 15 segundos mientras la pantalla está abierta. Se diferencian interés, afinidad, cupos pagados y confirmación económica. Retirar postulación no cancela una compra. Las respuestas antiguas no sobrescriben una postulación nueva.

La pestaña Avisos consume GET /notifications, permite leer páginas anteriores, marcar mensajes mediante PATCH y abrir la experiencia. Recupera mensajes al entrar y consulta cada 30 segundos. No hay push con app cerrada.

## CU-07 y límites

La demanda de establecimientos solo se expone en web. El catálogo móvil envía X-Search-Session efímero para deduplicar búsquedas; el resultado se registra en el backend.

Las pruebas de contratos están en test/booking_contract_test.dart y test/auth_contract_test.dart. El análisis Dart se comprobó; el runner Flutter y la demostración en dispositivo siguen pendientes por las restricciones del entorno. Ver [operación](04-PRUEBAS-Y-OPERACION.md) y [avance](../../docs/AVANCE_SPRINT_2.md).
