# Guía del desarrollador — Flutter y cliente del asistente

La aplicación móvil de EXPERIENCIA organiza código por funcionalidades. Registro/sesión, perfil, catálogo, reservas, checkout, entradas, matching y avisos consumen FastAPI. La guía sigue el formato por capítulos de `parcial_1` y distingue implementación de validación real en dispositivo.

| Capítulo | Contenido |
| --- | --- |
| [00 — Arquitectura y configuración](00-ARQUITECTURA-Y-CONFIGURACION.md) | SDK, arranque, URLs por plataforma |
| [01 — Sesión y cliente HTTP](01-SESION-Y-CLIENTE-HTTP.md) | Token, modelos y errores |
| [02 — Catálogo y perfil](02-CATALOGO-Y-PERFIL.md) | Vista 'Para ti', nube de temas estándar, filtros y conteo exacto |
| [03 — Reservas, entradas y matching](03-RESERVAS-ENTRADAS-Y-MATCHING.md) | Checkout moderno, pases QR, matching con chips de zona y avisos |
| [04 — Pruebas y operación](04-PRUEBAS-Y-OPERACION.md) | Suite automatizada de 17 pruebas aprobadas y diagnóstico |
| [05 — Directorios y flujos](05-MAPA-DE-DIRECTORIOS-Y-FLUJOS.md) | Mapa de responsabilidades |

Desde `experiencia_movil/`:

```sh
flutter --version
flutter pub get
flutter run
```

[pubspec.yaml](../pubspec.yaml) exige Dart `^3.12.2`; utilizar un Flutter que lo incluya. El backend usa Python 3.14.6/PostgreSQL y el cliente web Angular 22. Flutter no accede a PostgreSQL ni al `.env` del servidor.

Ver [backend](../../experiencia_back/guia-desarrollador/README.md), [web](../../experiencia_front/guia-desarrollador/README.md) y [acuerdos del equipo](../../docs/GUIAS_DESARROLLADORES.md).

La app requiere ATTENDEE asignado explícitamente. HOST/ADMIN sin ese rol utilizan la web; el login móvil dedicado y la actualización del perfil aplican esta regla. Ver [contrato de roles](../../docs/REGLAS_Y_VISTAS_POR_ROL.md).
