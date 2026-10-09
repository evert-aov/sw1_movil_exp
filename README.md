# EXPERIENCIA — Aplicación Móvil (Flutter)

Aplicación móvil desarrollada en **Flutter 3.44+ con Dart 3.12+**, orientada a los **asistentes** para exploración de experiencias, emparejamiento grupal (matching), reserva de cupos y acceso mediante entradas digitales con **códigos QR**.

---

## 🏛️ Arquitectura del Proyecto

El código fuente en `lib/` está diseñado bajo un patrón **Feature-First / Clean Architecture**:

```text
lib/
├── core/                                 # Configuración global y cliente de red
│   ├── constants/api_constants.dart      # URLs y endpoints del Backend
│   ├── network/http_client.dart          # Cliente HTTP desacoplado (firmas)
│   └── theme/app_theme.dart              # Estilos y tema visual Material 3
│
├── features/                             # Módulos de funcionalidad por caso de uso
│   ├── auth/                             # Autenticación y Perfil (CU-01, CU-02)
│   │   ├── models/user_model.dart        # Modelo de usuario
│   │   ├── services/auth_service.dart    # Métodos de login, registro y perfil
│   │   └── screens/                      # LoginScreen, RegisterScreen, ProfileScreen
│   │
│   ├── experience/                       # Catálogo y Exploración (CU-04)
│   │   ├── models/experience_model.dart  # Modelo de experiencia
│   │   ├── services/experience_service.dart # Filtros por geolocalización y fecha
│   │   └── screens/                      # CatalogScreen, ExperienceDetailScreen
│   │
│   ├── booking/                          # Reservas y Entradas QR (CU-05, CU-12)
│   │   ├── models/ticket_model.dart      # Modelo de ticket de entrada
│   │   ├── services/booking_service.dart # Pasarela de pago y consulta de cupos
│   │   └── screens/                      # CheckoutScreen, MyTicketsScreen
│   │
│   └── matching/                         # Matching Grupal Dinámico (CU-07)
│       ├── models/matching_model.dart    # Modelo de quórum y grupo
│       ├── services/matching_service.dart # Postulación a matching
│       └── screens/                      # MatchingScreen
│
└── main.dart                             # Navegación principal con NavigationBar
```

---

## 📱 Pantallas y Flujo de Navegación

La aplicación cuenta con una barra de navegación inferior (`NavigationBar`) que permite acceder a:

1. **Discover (`CatalogScreen`)**: Exploración de experiencias presenciales y virtuales con filtros por categoría y ubicación.
2. **Matching (`MatchingScreen`)**: Visualización de eventos en fase de postulación grupal para completar el quórum mínimo.
3. **My Tickets (`MyTicketsScreen`)**: Billetera de entradas activas y pasadas con visualización de código QR para control de acceso en puerta.
4. **Profile (`ProfileScreen`)**: Gestión de datos personales, avatar e intereses temáticos.

---

## 🚀 Puesta en Marcha

### 1. Requisitos Previos
- Flutter SDK 3.44+
- Dart SDK 3.12+
- Emulador de Android, Simulador de iOS o dispositivo físico conectado

### 2. Instalación de Dependencias
```bash
flutter pub get
```

### 3. Análisis de Código Estático
```bash
flutter analyze
```

### 4. Ejecutar la Aplicación
```bash
# Ejecutar en el dispositivo/emulador conectado
flutter run
```
