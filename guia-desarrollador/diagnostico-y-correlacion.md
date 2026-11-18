# Diagnóstico y correlación de solicitudes

Las tres aplicaciones comparten `X-Request-ID` para localizar una operación entre Flutter, Angular y FastAPI sin incorporar una plataforma de trazabilidad. Cada cliente envía un UUID v4; si el servidor devuelve `request_id`, ese valor identifica la operación observada y, si no, Flutter usa el encabezado de respuesta como alternativa.

## Contrato común

| Campo | Convención | Compatibilidad |
| --- | --- | --- |
| `X-Request-ID` | UUID v4 en solicitud y respuesta | El cliente genera uno cuando no recibe un UUID v4 válido del llamador. |
| `code` | Código estable y extensible con forma `CATEGORIA.DESCRIPTOR`, por ejemplo `COMMON.VALIDATION_ERROR` o `DEPENDENCY.UNAVAILABLE` | Flutter expone códigos válidos como dato opcional; los desconocidos no alteran el manejo del error. |
| `request_id` | UUID v4 asociado al error del servidor | Se prefiere un UUID v4 válido del cuerpo y luego se usa `X-Request-ID` de respuesta como alternativa. |
| Mensaje y estado | Mensaje legible y estado HTTP actuales | `ApiException.message`, `statusCode` y `toString()` conservan su comportamiento. |

Los cambios de diagnóstico son aditivos: no reemplazan mensajes, autenticación Bearer ni contratos de servicio existentes. No se deben incluir tokens, credenciales, trazas internas ni datos personales en respuestas o reportes.

Los reportes `diagnostic-report/v1` usan los campos comunes `service`, `version`, `phase`, `status`, `code`, `cause_status`, `evidence`, `possible_causes` y `recommended_actions`. Los estados son `passed`, `failed`, `not_verified` o `not_applicable`; una publicación exitosa del artefacto APK no implica instalación, arranque ni readiness. El workflow de CI marca runtime como no verificado/no aplicable y deja el smoke test de dispositivo para un release autorizado.

## Diagnóstico seguro

1. Reproduce el fallo en un entorno local o de pruebas y conserva el estado HTTP, el código si existe y el `request_id`.
2. Busca ese identificador en los registros del backend; comprueba primero la evidencia observada y separa las causas hipotéticas.
3. Contrasta fase y versión del servicio con el contrato usado por el cliente antes de atribuir una causa.
4. No publiques capturas o registros con JWT, secretos, cuerpos sensibles ni trazas internas.

Para comprobar Flutter desde la raíz del repositorio móvil, usa los comandos existentes:

```sh
fvm flutter analyze
fvm flutter test
```

Un código desconocido, una respuesta antigua sin metadatos o un cuerpo malformado debe seguir produciendo un error HTTP seguro, no una excepción secundaria durante su interpretación.

## Fases reportadas por CI

El workflow emite líneas JSON `diagnostic-report/v1` al final, incluso si una etapa falla o se omite. Cada reporte incluye servicio (`experiencia_movil`), versión (commit), fase y estado; las fallas incluyen un código estable y clasifican la causa como hipótesis salvo que exista evidencia suficiente para confirmarla. La evidencia contiene solo estados de pasos, nunca la URL de API ni secretos.

| Fase | Qué significa en este workflow | Qué no demuestra |
| --- | --- | --- |
| `preparation` | Checkout, Java, Flutter, dependencias, análisis, pruebas y prueba negativa del verificador de artefactos | No implica que el APK se haya construido. |
| `build` | Resultado de generar el APK release | No implica que el APK se haya instalado. |
| `publication` | Validación SHA-256 del APK y resultado de subir el APK junto con su checksum | No es publicación en una tienda ni prueba de funcionamiento. |
| `startup` | `not_verified`: el workflow no instala ni abre la app | No debe interpretarse como éxito. |
| `readiness` | `not_applicable`: el workflow no inicia la app ni prueba dependencias | No acredita disponibilidad del backend. |
| `postdeploy` | `not_applicable`: el workflow no distribuye la app | No acredita el despliegue ni el estado de una versión liberada. |

Después de una liberación autorizada por separado, hace falta una comprobación manual en dispositivo de instalación y arranque, acceso a la API configurada y un flujo básico de login. Registrar su resultado aparte; un artifact subido correctamente nunca reemplaza esa evidencia.

## Verificación del artifact APK

El workflow conserva `app-release.apk` y `app-release.apk.sha256` por 14 días. Después de descargar ambos archivos en el mismo directorio, verifica la integridad con:

```sh
sha256sum --check app-release.apk.sha256
```

El CI genera el checksum después del build y prueba que el verificador rechaza archivos ausentes, vacíos y contenido alterado. Este control detecta corrupción del artifact; no demuestra que la aplicación arranque ni que el backend esté disponible.
