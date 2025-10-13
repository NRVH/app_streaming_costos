import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/theme_preferences.dart' as model;

/// Provider para las preferencias de tema
final themePreferencesProvider = StateNotifierProvider<ThemePreferencesNotifier, model.ThemePreferences>((ref) {
  return ThemePreferencesNotifier();
});

/// Provider para el brightness actual (claro u oscuro)
final currentBrightnessProvider = StateProvider<Brightness>((ref) {
  final prefs = ref.watch(themePreferencesProvider);
  final now = DateTime.now();
  
  if (prefs.mode == model.ThemeMode.system) {
    // Se determinará en el widget usando MediaQuery
    return Brightness.light;
  }
  
  return prefs.shouldUseDarkMode(now) ? Brightness.dark : Brightness.light;
});

class ThemePreferencesNotifier extends StateNotifier<model.ThemePreferences> {
  static const String _boxName = 'theme_preferences';
  Timer? _scheduleTimer;

  ThemePreferencesNotifier() : super(model.ThemePreferences()) {
    _loadPreferences();
    _startScheduleTimer();
  }

  /// Carga las preferencias guardadas
  Future<void> _loadPreferences() async {
    try {
      final box = await Hive.openBox<model.ThemePreferences>(_boxName);
      
      if (box.isNotEmpty) {
        final saved = box.getAt(0);
        if (saved != null) {
          state = saved;
        }
      }
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  /// Guarda las preferencias
  Future<void> _savePreferences() async {
    try {
      final box = await Hive.openBox<model.ThemePreferences>(_boxName);
      
      if (box.isEmpty) {
        await box.add(state);
      } else {
        await box.putAt(0, state);
      }
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  /// Inicia un timer para verificar cambios de horario programado
  void _startScheduleTimer() {
    _scheduleTimer?.cancel();
    
    if (state.mode == model.ThemeMode.scheduled || state.mode == model.ThemeMode.auto) {
      // Verificar cada minuto si hay cambio
      _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        // Notificar cambio para re-evaluar el tema
        state = state.copyWith();
      });
    }
  }

  /// Cambia el modo de tema
  Future<void> setThemeMode(model.ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _savePreferences();
    _startScheduleTimer();
  }

  /// Establece el horario de inicio del tema oscuro
  Future<void> setDarkStartTime(TimeOfDay time) async {
    state = state.copyWith(
      darkStartHour: time.hour,
      darkStartMinute: time.minute,
    );
    await _savePreferences();
  }

  /// Establece el horario de fin del tema oscuro
  Future<void> setDarkEndTime(TimeOfDay time) async {
    state = state.copyWith(
      darkEndHour: time.hour,
      darkEndMinute: time.minute,
    );
    await _savePreferences();
  }

  /// Activa/desactiva el color dinámico
  Future<void> setDynamicColor(bool enabled) async {
    state = state.copyWith(useDynamicColor: enabled);
    await _savePreferences();
  }

  /// Activa/desactiva el modo AMOLED (negro puro)
  Future<void> setAmoledMode(bool enabled) async {
    state = state.copyWith(useAmoledMode: enabled);
    await _savePreferences();
  }

  /// Establece un color primario personalizado
  Future<void> setPrimaryColor(Color? color) async {
    state = state.copyWith(primaryColorValue: color?.value);
    await _savePreferences();
  }

  /// Obtiene el brightness actual considerando el modo seleccionado
  Brightness getCurrentBrightness(Brightness systemBrightness) {
    final now = DateTime.now();
    
    switch (state.mode) {
      case model.ThemeMode.light:
        return Brightness.light;
      case model.ThemeMode.dark:
        return Brightness.dark;
      case model.ThemeMode.system:
        return systemBrightness;
      case model.ThemeMode.scheduled:
      case model.ThemeMode.auto:
        return state.shouldUseDarkMode(now) ? Brightness.dark : Brightness.light;
    }
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }
}
