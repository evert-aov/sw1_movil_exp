# EXPERIENCIA — Aplicación Móvil y Multiplataforma (Flutter)

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
