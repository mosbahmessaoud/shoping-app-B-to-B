import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeMode = await _themeService.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _themeService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : _themeMode == ThemeMode.dark 
            ? ThemeMode.system 
            : ThemeMode.light;
    
    await setThemeMode(newTheme);
  }
}