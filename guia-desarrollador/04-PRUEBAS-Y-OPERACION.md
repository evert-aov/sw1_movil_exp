# Pruebas y operación

[Índice](README.md) · [Pruebas](../test/)

## Ejecución de pruebas y análisis estático

Desde la raíz de `experiencia_movil/`:

```sh
# Análisis estático de tipos y reglas de estilo (0 advertencias)
flutter analyze

# Suite completa de pruebas automatizadas (17 pruebas aprobadas)
flutter test
```

## Cobertura de la suite automatizada (17/17 tests aprobados)

La suite de pruebas automatizadas cubre tanto contratos HTTP como interfaces de usuario con widgets interactivos:

| Archivo de prueba | Casos de uso | Comportamiento verificado |
| --- | --- | --- |
| `test/auth_contract_test.dart` | CU-01 / CU-02 | Comprueba carga de perfil tras login, exclusión de roles sin `ATTENDEE`, logout con envío de JWT y limpieza de sesión en memoria. |
| `test/booking_contract_test.dart` | CU-05 | Valida estructura JSON de reserva, clave de idempotencia, cabecera Bearer, modelo de tickets anidados y rechazo de dominios ajenos a Stripe. |
| `test/checkout_screen_test.dart` | CU-05 | Prueba el stepper de selección de entradas, cálculo reactivo de importes, temporizador de retención y estado de la pasarela. |
| `test/matching_screen_test.dart` | CU-06 | Verifica el banner de afinidad, espaciado de campos, botones de acción y autocompletado de zona mediante chips táctiles sin escribir texto. |
| `test/profile_screen_test.dart` | CU-02 | Evalúa la nube de temas e intereses estándar (`FilterChip`), comprobando que se seleccionan o retiran con un solo toque sin teclear. |
| `test/localization_and_count_test.dart` | Core / i18n | Valida la paridad de diccionarios ES/EN, la traducción automática de categorías vía `translateCategory()` y el conteo exacto de la vista 'Para ti'. |
| `test/widget_test.dart` | Core | Verifica el arranque e inicialización sin errores del widget raíz `ExperienciaApp` en modo multiplataforma. |

## Diagnóstico y despliegue

- **Emulador Android:** El host se referencia como `http://10.0.2.2:8000/api`.
- **Dispositivo físico vía Wi-Fi:** Usar `--dart-define=API_BASE_URL=http://<IP_LOCAL>:8000/api`.
- **Dispositivo físico vía USB:** Aplicar `adb reverse tcp:8000 tcp:8000` y `--dart-define=API_BASE_URL=http://127.0.0.1:8000/api`.
- **Falta Bearer o 401 Unauthorized:** Comprobar existencia del token JWT en caché y validar que el usuario cuente con rol `ATTENDEE`.
- **Diferenciación de errores:** Distinguir respuestas vacías válidas (`[]`) de errores de conectividad o código `404` (grupo aún no formado).

