# EXPERIENCIA — Aplicación Móvil y Multiplataforma (Flutter)

> Documentación vigente: [guía del desarrollador](guia-desarrollador/README.md). CU-01 reúne registro y sesión; perfil es CU-02. El logout solicita revocación remota; el recorrido de reservas/matching del cliente sigue pendiente.

Aplicación cliente desarrollada en **Flutter con Dart**, orientada a los **asistentes** para la exploración interactiva de eventos y actividades, seguimiento de quórum en tiempo real, gestión de perfil y consumo de servicios remotos de la plataforma **EXPERIENCIA**.

Soporta ejecución multiplataforma nativa (**Android**, **Linux Desktop**, **iOS**, **macOS**, **Windows** y **Web**) adaptando sus interfaces tanto a pantallas móviles compactas como a monitores de escritorio.

---

## 🚀 Flujo de Navegación y Arquitectura (Sprint 1)

El sistema implementa un flujo de navegación estándar de software con barrera de autenticación (*Authentication Gateway*):

### 1. Pantalla Inicial de Acceso (`LoginScreen` • CU-01 / CU-02)
* **Puerta de entrada de la aplicación:** Se muestra como primera pantalla independiente cuando no existe una sesión autenticada activa.
* **Control segmentado:** Permite alternar entre **Iniciar sesión** (CU-02) y **Crear cuenta** (CU-01).
* **Diseño adaptativo:**
  * En pantallas de escritorio / tablet (anchura $\ge 880$px) presenta un panel lateral *Hero Branding* con los pilares del proyecto (Matching Grupal, Visión en RAM GDPR, Reserva Protegida).
  * En dispositivos móviles ofrece un formulario vertical optimizado.
* **Barra superior dedicada:** Incluye selector de idioma (**ES / EN**) y alternancia entre **Tema Claro** y **Tema Oscuro** sin mostrar pestañas de navegación interna.

### 2. Panel Principal del Asistente (`MainNavigationScreen`)
Accesible inmediatamente tras iniciar sesión o registrarse. Cuenta con una barra de navegación inferior (`NavigationBar`) con dos módulos principales:

1. **Descubrir (`CatalogScreen` • CU-04 / CU-05 / HU-05):**
   * Catálogo de experiencias conectado en vivo al backend.
   * Filtrado dinámico por categorías oficiales (`/api/categories`), modalidad (`Presencial`, `Virtual`, `Híbrida`) y búsqueda en tiempo real por título y descripción.
   * Visualización del progreso de **Quórum Mínimo** y hoja de detalles emergente (*BottomSheet* modal adaptativo).
2. **Mi Perfil (`ProfileScreen` • CU-03 / HU-03):**
   * Consulta y actualización de datos personales, teléfono, biografía y etiquetas de intereses temáticos.
   * Botón de **Cerrar sesión** que revoca el token JWT y regresa automáticamente al usuario a la pantalla inicial de Login.

---

## 🌐 Conexión con el Backend (`experiencia_back`)

La aplicación se comunica con la API RESTful desarrollada en **FastAPI (Python 3.14)** y base de datos **PostgreSQL**, utilizando resolución dinámica de hosts según el entorno:

* **Linux Desktop / macOS / Windows / Web:** `http://localhost:8000/api`
* **Android Emulator:** `http://10.0.2.2:8000/api`
* **Inyección personalizada por compilación:** `--dart-define=API_BASE_URL=https://tu-servidor/api`

### Endpoints integrados:
| Método | Endpoint | Caso de Uso | Descripción |
|---|---|---|---|
| `POST` | `/api/auth/login` | CU-02 / HU-02 | Autenticación con JWT Bearer |
| `POST` | `/api/auth/register` | CU-01 / HU-01 | Alta de asistentes con inicio de sesión automático |
| `POST` | `/api/auth/logout` | CU-02 | Revocación de sesión en servidor y limpieza local |
| `GET` | `/api/users/me` | CU-03 / HU-03 | Consulta de datos del perfil autenticado |
| `PUT` | `/api/users/me` | CU-03 / HU-03 | Actualización de perfil con validación estricta DTO |
| `GET` | `/api/experiences/catalog` | CU-05 / HU-05 | Catálogo paginado con filtros de modalidad y categoría |
| `GET` | `/api/experiences/{id}` | CU-05 / HU-05 | Detalle completo de una experiencia |
| `GET` | `/api/categories` | CU-04 / CU-05 | Categorías temáticas dinámicas para chips de filtrado |

---

## 🛠️ Estructura del Código (Feature-First)

```text
lib/
├── core/
│   ├── constants/       # ApiConstants (rutas de API y resolución de hosts)
│   ├── localization/    # Internacionalización ES/EN (AppLocalizations)
│   ├── network/         # HttpClient (transporte HTTP desacoplado con JWT Bearer)
│   └── theme/           # AppColors, AppTheme y controladores de tema
├── features/
│   ├── auth/            # Modelos (UserModel, AuthCredentials), pantallas (Login, Profile) y AuthService
│   ├── booking/         # Modelos de reserva y stubs de contrato (Sprint 2)
│   ├── experience/      # Catálogo, tarjetas de quórum, filtros y ExperienceService
│   └── matching/        # Modelos y contratos de matching grupal
└── main.dart            # Punto de entrada, enrutamiento condicional y tema global
```

---

## 💻 Instrucciones de Ejecución

### 1. Prerrequisitos
* Tener el backend `experiencia_back` en ejecución en el puerto `8000`.
* Flutter SDK (3.x o superior) instalado y configurado en el sistema.

### 2. Ejecutar en Linux Desktop
```bash
flutter run -d linux
```

### 3. Ejecutar en dispositivo móvil Android
```bash
# Si utilizas un celular físico vía USB (habilita puente de puertos para localhost):
adb reverse tcp:8000 tcp:8000
flutter run -d <ID_DEL_DISPOSITIVO>
```

### 4. Credenciales de demostración (Seeder del backend)
* **Correo:** `host@experiencia.com`
* **Contraseña:** `Password123!`
*(O puedes registrar una nueva cuenta directamente desde la pantalla de creación de cuenta).*

---

## 🧪 Pruebas Automatizadas y Calidad de Código

Para verificar la integridad estática y las pruebas unitarias:

```bash
flutter analyze
flutter test
```

## Seguridad en CI

El workflow ejecuta Trivy `v0.70.0` sobre el sistema de archivos para detectar vulnerabilidades y secretos. La acción está fijada a `aquasecurity/trivy-action@ed142fd0673e97e23eac54620cfb913e5ce36c25` (`v0.36.0`), usa permisos de solo lectura, no conserva credenciales de checkout y tiene un límite de ejecución.

El escaneo bloquea el CI ante cualquier secreto o vulnerabilidad `HIGH`/`CRITICAL`. Los niveles `MEDIUM`, `LOW` y `UNKNOWN` se publican como advertencias. Si Trivy no se ejecuta, falla o produce JSON inválido, el reporte indica `not_verified` o `failed` según la evidencia disponible y el control bloquea el CI. El parser valida el sobre JSON de Trivy, acepta `ArtifactType: filesystem` y `ArtifactType: repository`, y admite `Results: null` como resultado vacío válido. Trivy puede asignar `repository` automáticamente cuando escanea un checkout con metadatos Git.

El JSON original de Trivy y el reporte JSON sanitizado se escriben en el directorio temporal del runner; el original se elimina al terminar, y solo el reporte sanitizado se publica como artefacto de Actions durante 14 días. El reporte `security-report/v1` usa el contrato común (`service`, `version`, `phase`, `status`, `code`, `cause_status`, `evidence`, `possible_causes`, `recommended_actions`) e incluye `evidence.output_validation`. El resumen y el artefacto contienen estado, conteos y metadatos validados de vulnerabilidades. Para secretos incluyen identificadores de regla y rutas relativas validados, agrupados por par con su conteo y limitados a 20 entradas; las rutas inseguras se redactan y `secret_findings_truncated` indica si hubo más. Nunca incluyen valores detectados ni datos de líneas o coincidencias.

Las reglas del reporte se verifican con la biblioteca estándar de Python:

```bash
python3 -m unittest discover -s scripts/ci -v
```
