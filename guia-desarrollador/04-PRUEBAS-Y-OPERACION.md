# Pruebas y operación

[Índice](README.md) · [Prueba actual](../test/widget_test.dart)

Desde `experiencia_movil/`:

```sh
flutter analyze
flutter test
flutter devices
flutter run -d <dispositivo>
```

Además del widget raíz, auth_contract_test.dart comprueba perfil tras login, JWT de logout y fallo de revocación remota. booking_contract_test.dart verifica JSON/clave/Bearer, tickets anidados y rechazo de redirecciones ajenas a Stripe. Estas pruebas no se consideran ejecutadas mientras el runner esté bloqueado.

Al ampliar servicios, usar `http/testing.dart` para respuestas controladas y verificar URL, Bearer, JSON y errores. Añadir pruebas de modelos/DTO, estados de widgets, navegación autenticada y formulario de perfil. Para sprint 2 probar retorno pendiente del pago, tickets anidados/QR, reconexión y adhesión sin duplicados.

La integración final necesita emulador/dispositivo, API y PostgreSQL reales; una prueba HTTP simulada no valida red, checkout externo o permisos del servidor. El retorno del proveedor y la recepción del webhook se demuestran por separado.

## Limitaciones observadas

En el entorno de revisión, Flutter intentó escribir telemetría fuera del workspace. Con `--suppress-analytics` la prueba avanzó, pero no pudo abrir el socket local requerido por el runner. `dart --disable-analytics analyze` informó “No issues found!”, aunque terminó con error de telemetría. No contar estos comandos como suite completamente aprobada ni atribuir el bloqueo a un widget.

Se añadió [analyze_stdio.py](../scripts/analyze_stdio.py), que usa el analizador del SDK por entrada/salida estándar y una caché temporal sin cambiar HOME ni preferencias del usuario:

```sh
python scripts/analyze_stdio.py --dart-sdk /ruta/al/sdk/dart
```

Se comprobó con un error de tipos temporal que el analizador realmente detecta diagnósticos, y el análisis final terminó sin diagnósticos. Esto valida análisis estático, no ejecución de widgets ni integración de red. El script requiere dartaotruntime y analysis_server_aot.dart.snapshot de ese SDK.

## Diagnóstico

- Emulador Android: host `10.0.2.2`; dispositivo físico: IP de red o adb reverse con URL localhost explícita.
- Falta Bearer/401: revisar token en memoria y contrato login → perfil.
- API inaccesible: comprobar PostgreSQL y puerto 8000 desde el host, y luego conectividad del dispositivo.
- Entradas/grupos vacíos: distinguir una respuesta válida sin elementos del error de red o del 404 de grupo aún no creado.
- Formato inesperado: verificar reserva con tickets anidados, UUID y campos del backend.

No cambiar a datos ficticios para disimular un fallo de integración. Documentar límites del entorno y resultados reales.
