# Arquitectura y configuración

[Índice](README.md) · [Arranque](../lib/main.dart) · [Endpoints](../lib/core/constants/api_constants.dart)

`ExperienciaApp` contiene estado de tema/idioma y sesión. Sin usuario muestra LoginScreen; autenticado muestra MainNavigationScreen con Descubrir, Perfil, Entradas y Avisos. Detalle abre checkout y matching para su experiencia.

`lib/core/` contiene HTTP, constantes, localización y tema. `features/` agrupa modelos, servicios y pantallas por dominio. Inyectar transporte en servicios para probarlos sin dispositivo; no ejecutar HTTP desde widgets compartidos.

## URL de API

ApiConstants utiliza `API_BASE_URL` si se inyecta. Si no, Android nativo usa `http://10.0.2.2:8000/api`; otras plataformas usan `http://localhost:8000/api`.

```sh
# Emulador Android con backend en el host
flutter run -d <dispositivo>

# Dispositivo físico en la misma red
flutter run -d <dispositivo> --dart-define=API_BASE_URL=http://<IP_DEL_HOST>:8000/api

# USB con adb reverse: hay que reemplazar también la URL por localhost
adb reverse tcp:8000 tcp:8000
flutter run -d <dispositivo> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

`10.0.2.2` corresponde al emulador; no asumir que identifica al equipo desde un teléfono físico. Para Flutter web, revisar también CORS. Preparar el backend en puerto 8000 y comprobar PostgreSQL antes de atribuir fallos al móvil.

No incorporar claves Stripe ni DB_PASS a `--dart-define`: estos valores se distribuyen con la app. Solo configurar la URL pública de la API y valores públicos del cliente.
