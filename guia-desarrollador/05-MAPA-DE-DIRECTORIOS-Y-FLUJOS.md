# Directorios y flujos

[Índice](README.md)

| Ruta bajo `lib/` | Responsabilidad |
| --- | --- |
| `main.dart` | Tema/idioma, acceso y navegación actual |
| `core/constants/` | API_BASE_URL y endpoints |
| `core/network/` | Transporte HTTP y token Bearer |
| `core/localization/` | Diccionarios ES/EN y controlador de idioma |
| `core/theme/` | Colores, temas y estado de preferencia |
| `features/auth/models/` | Usuario y credenciales |
| `features/auth/services/` | Registro/login/perfil/logout local |
| `features/auth/screens/` | Acceso y edición de perfil |
| `features/experience/` | Modelos, filtros, servicio, tarjetas, catálogo y detalle |
| `features/booking/` | Reserva, checkout externo, historial, devolución y QR local |
| `features/matching/` | Postulación, disponibilidad y estado sin mutaciones al consultar |
| `features/notifications/` | Bandeja persistente y recuperación de avisos |

```mermaid
flowchart LR
    A[Sin sesión] --> B[Login o registro]
    B --> C[Token y perfil]
    C --> D[Navegación autenticada]
    D --> E[Catálogo y detalle]
    D --> F[Perfil]
    F --> G[Logout local actual]
    G --> A
```

```mermaid
sequenceDiagram
    participant W as Pantalla Flutter
    participant S as Servicio del dominio
    participant H as HttpClient
    participant A as FastAPI
    W->>S: Acción con modelo
    S->>H: Método y payload
    H->>A: JSON y Bearer
    A-->>H: Respuesta o error
    H-->>S: Datos decodificados
    S-->>W: Modelo o ApiException
```

Extender una funcionalidad desde su modelo y contrato HTTP; añadir después servicio, estado/pantalla, navegación, traducciones y pruebas. Mantener la autoridad financiera en la API y el transporte común en core/network.
