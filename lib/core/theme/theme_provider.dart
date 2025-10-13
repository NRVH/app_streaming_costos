import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

/// Provider para el modo de tema (claro/oscuro)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

/// Notifier para gestionar el modo de tema
class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false) {
    _loadThemeMode();
  }

  static const String _boxName = 'settings';
  static const String _darkModeKey = 'isDarkMode';

  /// Carga el modo de tema desde el almacenamiento
  Future<void> _loadThemeMode() async {
    final box = await Hive.openBox(_boxName);
    state = box.get(_darkModeKey, defaultValue: false);
  }

  /// Cambia el modo de tema
  Future<void> toggleThemeMode() async {
    state = !state;
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, state);
  }

  /// Establece el modo de tema
  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, isDark);
  }
}

/// Provider para la paleta de colores
final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, AppColorScheme>((ref) {
  return ColorSchemeNotifier();
});

/// Notifier para gestionar la paleta de colores
class ColorSchemeNotifier extends StateNotifier<AppColorScheme> {
  ColorSchemeNotifier() : super(AppColorScheme.sakuraPink) {
    _loadColorScheme();
  }

  static const String _boxName = 'settings';
  static const String _colorSchemeKey = 'colorScheme';

  /// Carga la paleta de colores desde el almacenamiento
  Future<void> _loadColorScheme() async {
    final box = await Hive.openBox(_boxName);
    final index = box.get(_colorSchemeKey, defaultValue: 0);
    state = AppColorScheme.values[index];
  }

  /// Cambia la paleta de colores
  Future<void> setColorScheme(AppColorScheme colorScheme) async {
    state = colorScheme;
    final box = await Hive.openBox(_boxName);
    await box.put(_colorSchemeKey, colorScheme.index);
  }
}
