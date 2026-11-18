# Monitor en vivo para tablets y celulares (CU-09 / HU-17)

[Índice](README.md) · [Pantalla](../lib/features/live/screens/live_monitor_screen.dart) · [Servicio](../lib/features/live/services/live_telemetry_service.dart) · [Pruebas](../test/live_monitor_test.dart)

> **HU-17 — Dashboard en vivo con indicadores discretos.** Widget de telemetría en vivo reducido para que el anfitrión o DJ vea la energía del público de un vistazo.

## Acceso sin cuenta de asistente

La app solo admite cuentas ATTENDEE, así que el anfitrión no inicia sesión:

1. En la consola web (`/live/:id/console`) pulsa **Vincular tablet o celular** y obtiene un código de 6 caracteres.
2. En la pantalla de login de la app toca el icono de monitor (barra superior) e ingresa el código.
3. La app canjea el código en `POST /live/telemetry/monitor/redeem` y recibe un token de monitor de solo lectura (8 h) que solo abre el WebSocket de esa sesión.

El token de monitor se guarda solo en memoria de la pantalla; no reemplaza ni modifica la sesión de asistente de `HttpClient`.

## Archivos

| Archivo | Responsabilidad |
| --- | --- |
| `lib/features/live/models/live_telemetry_model.dart` | Instantánea, puntos de pulso, enums y vinculación |
| `lib/features/live/services/live_telemetry_service.dart` | Canje del código y `watch()` del WebSocket con reconexión exponencial, latido y corte ante 4401/4403/4404 |
| `lib/features/live/screens/live_monitor_screen.dart` | Ingreso de código y vista del monitor |
| `lib/features/live/widgets/telemetry_traffic_light.dart` | Semáforo horizontal; atenuado si la señal no es en vivo |
| `lib/features/live/widgets/pulse_sparkline.dart` | Pulso de 60 s con `CustomPainter` |
| `lib/features/live/live_monitor_strings.dart` | Textos ES/EN propios del módulo |

Dependencia agregada: `web_socket_channel`.

## Probar en un celular físico

El celular debe llegar al backend. Si el router aísla los dispositivos del WiFi, hay dos opciones:

```sh
# Opción A: túnel por USB (no depende del WiFi)
adb reverse tcp:8000 tcp:8000
flutter run -d <dispositivo> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api

# Opción B: misma red (por ejemplo, internet compartido desde el celular a la PC)
flutter run -d <dispositivo> --dart-define=API_BASE_URL=http://<IP_DE_LA_PC>:8000/api
```

En Xiaomi hay que activar **Instalar vía USB** en las opciones de desarrollador y aceptar la instalación en pantalla.

## Pruebas

```sh
flutter test test/live_monitor_test.dart
```

Son 10 pruebas: interpretación de la instantánea, canje sin tocar la sesión de asistente, URL con token, flujo de eventos, rechazo 4403, espera de reconexión, proyección del pulso y flujo de pantalla (vincular, ver semáforo, desvincular, código inválido).
