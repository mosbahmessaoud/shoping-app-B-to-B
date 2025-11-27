import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await _themeService.getThemeMode();
    setState(() => _themeMode = theme);
  }

  Future<void> _toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : _themeMode == ThemeMode.dark 
            ? ThemeMode.system 
            : ThemeMode.light;
    
    await _themeService.setThemeMode(newTheme);
    setState(() => _themeMode = newTheme);
  }

  IconData _getIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_getIcon()),
      onPressed: _toggleTheme,
      tooltip: _themeMode == ThemeMode.light 
          ? 'Mode Clair' 
          : _themeMode == ThemeMode.dark 
              ? 'Mode Sombre' 
              : 'Mode Système',
    );
  }
}