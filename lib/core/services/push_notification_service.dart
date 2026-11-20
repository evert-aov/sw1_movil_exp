import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Manejador de mensajes push en segundo plano (Android / iOS).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Ya inicializado o plataforma sin Firebase nativo
  }
}

/// Servicio multiplataforma de notificaciones push con Firebase Cloud Messaging (HU-18).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const MethodChannel _nativeChannel = MethodChannel(
    'com.experiencia.experiencia_movil/notifications',
  );

  String? _fcmToken;
  String? _lastJwtToken;
  bool _initialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Inicializa Firebase y solicita permiso de notificaciones en Android/iOS.
  Future<void> initialize() async {
    if (_initialized || !_isMobilePlatform) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final String title =
            message.notification?.title ??
            message.data['title']?.toString() ??
            'EXPERIENCIA';
        final String body =
            message.notification?.body ??
            message.data['body']?.toString() ??
            '';
        if (body.isEmpty && message.notification == null) return;
        if (defaultTargetPlatform == TargetPlatform.android) {
          _nativeChannel
              .invokeMethod<void>('showLocalNotification', <String, String>{
                'title': title,
                'body': body,
              })
              .catchError((Object e) {
                debugPrint('No se pudo mostrar notificación local: $e');
              });
        }
      });

      _fcmToken = await messaging.getToken();
      messaging.onTokenRefresh.listen((String newToken) {
        _fcmToken = newToken;
        final String? jwt = _lastJwtToken;
        if (jwt != null && jwt.isNotEmpty) {
          registerForAuthenticatedUser(jwtToken: jwt);
        }
      });
      _initialized = true;
    } catch (e) {
      debugPrint('PushNotificationService init skipped: $e');
    }
  }

  /// Registra el token FCM del usuario autenticado para recibir push de reservas y eventos.
  Future<void> registerForAuthenticatedUser({required String jwtToken}) async {
    if (jwtToken.isNotEmpty) {
      _lastJwtToken = jwtToken;
    }
    if (!_initialized) await initialize();
    final token = _fcmToken;
    if (token == null || token.isEmpty || jwtToken.isEmpty) return;

    final uri = Uri.parse('${ApiConstants.baseUrl}/notifications/push-device');
    try {
      await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(<String, dynamic>{
          'fcm_token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );
    } catch (e) {
      debugPrint('No se pudo registrar el push del usuario: $e');
    }
  }

  /// Registra el token FCM del celular vinculado al monitor en vivo del backend.
  Future<void> registerForMonitorSession({
    required String monitorToken,
    String language = 'es',
  }) async {
    if (!_initialized) await initialize();
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse('${ApiConstants.baseUrl}/live/mc/monitor/push-device');
    try {
      await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $monitorToken',
        },
        body: jsonEncode(<String, dynamic>{
          'fcm_token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          'language': language == 'en' ? 'en' : 'es',
        }),
      );
    } catch (e) {
      debugPrint('No se pudo registrar el dispositivo push: $e');
    }
  }
}
