# Sesión y cliente HTTP

[Índice](README.md) · [AuthService](../lib/features/auth/services/auth_service.dart) · [Transporte](../lib/core/network/http_client.dart)

CU-01 incluye registro, login y logout. HttpClient encapsula JSON, parámetros y Bearer; su token permanece en memoria y no persiste al cerrar el proceso. ApiException mantiene mensaje y estado HTTP.

POST /auth/mobile/login exige ATTENDEE asignado y devuelve metadatos del token, no un User completo. AuthService consulta /users/me para recuperar nombre, ID y preferencias, en lugar de crear un usuario parcial a partir del email del token. Registro encadena login y propaga errores; no abre una sesión ficticia si falla.

logout() devuelve Future<bool>: solicita /auth/logout con el JWT activo y después limpia token/usuario en finally. El resultado indica si obtuvo confirmación remota. MainNavigationScreen espera el cierre; ProfileScreen no lo ejecuta por segunda vez. Un fallo de red no demuestra revocación del token en servidor.

isAuthenticated exige usuario, token y ATTENDEE explícito. UserModel conserva todos los roles y copyWith no los elimina. HOST/ADMIN sin ATTENDEE no pueden entrar. Se vuelve a consultar el perfil al regresar a primer plano; si se retiró ATTENDEE se limpia la sesión y se vuelve al acceso. Todavía no existe almacenamiento seguro persistente ni recuperación completa de sesión/refresh. Estos flujos no se presentan como implementados.

Los servicios admiten inyección de HttpClient/http.Client para pruebas. Perfil es CU-02; UserModel.toUpdateJson() conserva únicamente campos de ProfileUpdateDTO. La autorización de recursos permanece en FastAPI.
