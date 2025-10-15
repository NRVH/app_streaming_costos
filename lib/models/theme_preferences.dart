import 'package:hive/hive.dart';

part 'theme_preferences.g.dart';

/// Modos de tema disponibles
@HiveType(typeId: 3)
enum ThemeMode {
  @HiveField(0)
  light,      // Siempre claro
  
  @HiveField(1)
  dark,       // Siempre oscuro
  
  @HiveField(2)
  system,     // Según el sistema
  
  @HiveField(3)
  scheduled,  // Programado por horario
  
  @HiveField(4)
  auto,       // Auto según hora del día (amanecer/atardecer)
}

/// Esquemas de color disponibles
@HiveType(typeId: 5)
enum AppColorScheme {
  @HiveField(0)
  sakuraPink,
  
  @HiveField(1)
  oceanBlue,
  
  @HiveField(2)
  forestGreen,
  
  @HiveField(3)
  sunsetOrange,
  
  @HiveField(4)
  lavenderDream,
  
  @HiveField(5)
  mintFresh,
}

/// Preferencias de tema de la aplicación
@HiveType(typeId: 4)
class ThemePreferences extends HiveObject {
  @HiveField(0)
  ThemeMode mode;

  /// Hora de inicio del tema oscuro (formato 24h)
  @HiveField(1)
  int darkStartHour;

  @HiveField(2)
  int darkStartMinute;

  /// Hora de fin del tema oscuro (formato 24h)
  @HiveField(3)
  int darkEndHour;

  @HiveField(4)
  int darkEndMinute;

  /// Esquema de color seleccionado
  @HiveField(5)
  AppColorScheme colorScheme;

  /// Usar color dinámico del sistema (Material You en Android 12+)
  @HiveField(6)
  bool useDynamicColor;

  ThemePreferences({
    this.mode = ThemeMode.system,
    this.darkStartHour = 20,
    this.darkStartMinute = 0,
    this.darkEndHour = 7,
    this.darkEndMinute = 0,
    this.colorScheme = AppColorScheme.sakuraPink,
    this.useDynamicColor = false,
  });

  /// Determina si debe usar tema oscuro según las preferencias actuales
  bool shouldUseDarkMode(DateTime now) {
    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        // Se maneja en el widget principal con MediaQuery
        return false;
      case ThemeMode.scheduled:
        return _isWithinDarkSchedule(now);
      case ThemeMode.auto:
        return _isNightTime(now);
    }
  }

  /// Verifica si la hora actual está dentro del horario programado para tema oscuro
  bool _isWithinDarkSchedule(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = darkStartHour * 60 + darkStartMinute;
    final endMinutes = darkEndHour * 60 + darkEndMinute;

    if (startMinutes < endMinutes) {
      // Horario normal: ej. 8:00 AM a 8:00 PM
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Horario nocturno: ej. 8:00 PM a 7:00 AM (cruza medianoche)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  /// Determina si es de noche basado en la hora del día
  /// Aproximación simple: 6:00 PM - 6:00 AM
  bool _isNightTime(DateTime now) {
    final hour = now.hour;
    return hour >= 18 || hour < 6;
  }

  /// Formatea el horario de inicio como string
  String get darkStartTimeString {
    return '${darkStartHour.toString().padLeft(2, '0')}:${darkStartMinute.toString().padLeft(2, '0')}';
  }

  /// Formatea el horario de fin como string
  String get darkEndTimeString {
    return '${darkEndHour.toString().padLeft(2, '0')}:${darkEndMinute.toString().padLeft(2, '0')}';
  }

  /// Descripción del modo actual
  String get modeDescription {
    switch (mode) {
      case ThemeMode.light:
        return 'Siempre claro';
      case ThemeMode.dark:
        return 'Siempre oscuro';
      case ThemeMode.system:
        return 'Según el sistema';
      case ThemeMode.scheduled:
        return 'Programado ($darkStartTimeString - $darkEndTimeString)';
      case ThemeMode.auto:
        return 'Automático (6:00 PM - 6:00 AM)';
    }
  }

  ThemePreferences copyWith({
    ThemeMode? mode,
    int? darkStartHour,
    int? darkStartMinute,
    int? darkEndHour,
    int? darkEndMinute,
    AppColorScheme? colorScheme,
    bool? useDynamicColor,
  }) {
    return ThemePreferences(
      mode: mode ?? this.mode,
      darkStartHour: darkStartHour ?? this.darkStartHour,
      darkStartMinute: darkStartMinute ?? this.darkStartMinute,
      darkEndHour: darkEndHour ?? this.darkEndHour,
      darkEndMinute: darkEndMinute ?? this.darkEndMinute,
      colorScheme: colorScheme ?? this.colorScheme,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
  
  /// Nombres legibles de esquemas de color
  String getColorSchemeName() {
    switch (colorScheme) {
      case AppColorScheme.sakuraPink:
        return 'Rosa Sakura';
      case AppColorScheme.oceanBlue:
        return 'Azul Océano';
      case AppColorScheme.forestGreen:
        return 'Verde Bosque';
      case AppColorScheme.sunsetOrange:
        return 'Naranja Atardecer';
      case AppColorScheme.lavenderDream:
        return 'Lavanda Sueño';
      case AppColorScheme.mintFresh:
        return 'Menta Fresca';
    }
  }
}
