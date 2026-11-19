import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Fuente del token de notificaciones push del dispositivo (HU-18).
///
/// Se abstrae para poder sustituirla en las pruebas sin Firebase.
abstract class PushTokenProvider {
  /// Pide permiso de notificaciones y devuelve el token del dispositivo, o null si no hay push.
  Future<String?> obtainToken();

  /// Emite un token nuevo cuando Firebase lo renueva.
  Stream<String> get onTokenRefresh;
}

/// Token de Firebase Cloud Messaging del celular vinculado como monitor (HU-18).
///
/// Solo funciona en Android con `google-services.json` incluido en la compilación. En web,
/// escritorio o sin configuración de Firebase devuelve null y la app sigue sin push: las
/// alertas del Asistente MC siguen llegando por WebSocket mientras el monitor está abierto.
class FirebasePushTokenProvider implements PushTokenProvider {
  bool? _available;

  /// Inicializa Firebase una sola vez si la plataforma lo admite.
  Future<bool> _ensureInitialized() async {
    if (_available != null) return _available!;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return _available = false;
    }
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      return _available = true;
    } catch (error) {
      debugPrint(
        'Firebase no disponible, el monitor funciona sin push: $error',
      );
      return _available = false;
    }
  }

  @override
  Future<String?> obtainToken() async {
    if (!await _ensureInitialized()) return null;
    try {
      final NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return null;
      }
      // El backend envía con la API HTTP v1 de FCM, que usa tokens de registro. La API nueva
      // (register/onRegistered) entrega el FID de otro modo de envío; se migrará cuando el
      // backend lo adopte.
      // ignore: deprecated_member_use
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('No se pudo obtener el token push: $error');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh async* {
    if (await _ensureInitialized()) {
      // ignore: deprecated_member_use
      yield* FirebaseMessaging.instance.onTokenRefresh;
    }
  }
}
