import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  AppProvider() {
    _loadThemePreference();
  }

  // Cargar la preferencia de tema guardada
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      notifyListeners();
    } catch (e) {
      // Si hay un error, usar tema oscuro por defecto
      _isDarkMode = true;
    }
  }

  // Cambiar el tema
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // Guardar la preferencia
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // Manejo de error silencioso
    }
  }

  // Establecer tema específico
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();

      // Guardar la preferencia
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', _isDarkMode);
      } catch (e) {
        // Manejo de error silencioso
      }
    }
  }
}
