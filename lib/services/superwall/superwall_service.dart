import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class SuperwallService {
  void configure() {
    final apiKey = Platform.isIOS ? "pk_6a9ebab72a3633c6d4953f0767c5eeed1b36be5bac35ddf1" : ""; // Reemplaza con tu API Key de Superwall para IOS y Android
    Superwall.configure(apiKey);
  }

  /// Verifica si el usuario tiene acceso premium activo
  /// 
  /// Este método consulta los entitlements (derechos) del usuario desde Superwall
  /// y determina si tiene alguna suscripción o compra premium activa.
  /// 
  /// Retorna [true] si el usuario tiene al menos un entitlement activo,
  /// [false] en caso contrario.
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// final isPremium = await superwallService.checkPremium();
  /// if (isPremium) {
  ///   // Mostrar contenido premium
  /// } else {
  ///   // Mostrar paywall o contenido limitado
  /// }
  /// ```
  Future<bool> checkPremium() async {
    final entitlements = await Superwall.shared.getEntitlements();
    bool isActive = entitlements.active.isNotEmpty;
    return isActive;
  }
  
  /// Muestra una paywall utilizando el placement especificado
  /// [placementId] - El ID del placement (por defecto 'campaign_trigger')
  /// [feature] - Callback opcional que se ejecuta cuando el usuario tiene acceso a la función premium
  void showPaywall({String placementId = 'campaign_trigger', VoidCallback? feature}) {
    Superwall.shared.registerPlacement(placementId, feature: feature ?? () {
      // Acceso a función premium - implementar lógica específica aquí
    });
  }
}