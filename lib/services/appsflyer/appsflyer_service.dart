import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AppsFlyerService {
  static final AppsFlyerService _instance = AppsFlyerService._internal();
  late AppsflyerSdk _appsflyerSdk;
  bool _isInitialized = false;

  // Singleton pattern
  factory AppsFlyerService() {
    return _instance;
  }

  AppsFlyerService._internal();

  Future<void> initAppsFlyer() async {
    if (_isInitialized) return;

    // Solicitar permiso de tracking en iOS
    if (Platform.isIOS) {
      final status = await _requestTrackingAuthorization();
      debugPrint('Estado de tracking: $status');
    }

    // TODO: Reemplazar con tus claves reales
    const String afDevKey = ""; // Reemplazar con tu Dev Key de AppsFlyer
    const String appId = ""; // Reemplazar con tu App ID (solo necesario para iOS)

    final AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: afDevKey,
      appId: Platform.isIOS ? appId : "",
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 60, // Aumentado a 60 segundos para dar tiempo a la respuesta ATT
      // appInviteOneLink: oneLinkID,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
    );

    _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

    try {
      await _appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );
      
      _isInitialized = true;
      debugPrint('AppsFlyer SDK inicializado correctamente');
    } catch (e) {
      debugPrint('Error al inicializar AppsFlyer SDK: $e');
    }
  }

  Future<String> _requestTrackingAuthorization() async {
    try {
      // Verificar el estado actual del tracking
      final TrackingStatus currentStatus = 
          await AppTrackingTransparency.trackingAuthorizationStatus;
      
      if (currentStatus == TrackingStatus.notDetermined) {
        // Esperar para mostrar el prompt en el momento adecuado
        await Future.delayed(const Duration(seconds: 1));
        
        // Mostrar el prompt de tracking
        final TrackingStatus status =
            await AppTrackingTransparency.requestTrackingAuthorization();
            
        return status.toString();
      }
      
      return currentStatus.toString();
    } catch (e) {
      debugPrint('Error al solicitar autorización de tracking: $e');
      return 'Error: $e';
    }
  }

  // Método para obtener la instancia del SDK si se necesita acceder directamente
  AppsflyerSdk get sdk {
    if (!_isInitialized) {
      debugPrint('Advertencia: AppsFlyer SDK no ha sido inicializado');
    }
    return _appsflyerSdk;
  }

  // Método para registrar eventos personalizados
  Future<bool?> logEvent(String eventName, Map<String, dynamic> eventValues) async {
    if (!_isInitialized) {
      debugPrint('Error: AppsFlyer SDK no ha sido inicializado');
      return false;
    }
    
    try {
      final result = await _appsflyerSdk.logEvent(eventName, eventValues);
      return result;
    } catch (e) {
      debugPrint('Error al registrar evento en AppsFlyer: $e');
      return false;
    }
  }
} 