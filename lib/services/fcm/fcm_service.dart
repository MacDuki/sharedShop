import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Inicializa las notificaciones del usuario y se suscribe al tópico 'all'
  /// 
  /// Este método:
  /// - Obtiene el token APNS (iOS)
  /// - Solicita permisos para notificaciones
  /// - Obtiene el token del dispositivo
  /// - Suscribe al usuario al tópico 'all' para recibir notificaciones globales
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final fcmService = FcmService();
  /// await fcmService.initNotifications();
  /// ```
  Future<void> initNotifications() async {
    try {
      // Obtener token APNS para iOS
      await _firebaseMessaging.getAPNSToken();
      
      // Solicitar permisos para notificaciones
      await _firebaseMessaging.requestPermission();
      
      // Obtener token del dispositivo
      final String deviceToken = (await _firebaseMessaging.getToken())!;
      print('Device Token: $deviceToken');
      
      // Suscribirse al tópico 'all'
      await _firebaseMessaging.subscribeToTopic('all');
      print('Suscrito exitosamente al tópico: all');
      
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Cancela la suscripción al tópico 'all'
  /// 
  /// Útil cuando el usuario quiere dejar de recibir notificaciones globales
  Future<void> unsubscribeFromAll() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('all');
      print('Desuscrito exitosamente del tópico: all');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Obtiene el token del dispositivo actual
  /// 
  /// Retorna el token único del dispositivo para notificaciones push
  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }
} 