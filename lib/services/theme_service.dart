import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  static ThemeService? _instance;
  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  ThemeService._() {
    _loadTheme();
  }

  // Kaydedilmiş tema tercihini yükle
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }

      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan tema kullan
      _themeMode = ThemeMode.system;
    }
  }

  // Tema değiştir ve kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // Sistem temasını kontrol et
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  // Tema mod ismini getir
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'theme_light';
      case ThemeMode.dark:
        return 'theme_dark';
      case ThemeMode.system:
        return 'theme_system';
    }
  }
}
