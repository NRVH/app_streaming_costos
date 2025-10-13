import 'package:flutter/material.dart';

/// Clase para definir una paleta de colores con 3 tonos armónicos
class ColorPalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final String name;

  const ColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.name,
  });
}

/// Paletas de colores disponibles en la app
enum AppColorScheme {
  sakuraPink,
  oceanBlue,
  forestGreen,
  sunsetOrange,
  lavenderDream,
  mintFresh,
}

/// Configuración de temas de la aplicación
class AppTheme {
  // Prevenir instanciación
  AppTheme._();

  /// Paletas de colores profesionales con 3 tonos armónicos
  static const Map<AppColorScheme, ColorPalette> colorPalettes = {
    AppColorScheme.sakuraPink: ColorPalette(
      name: 'Sakura Pink',
      primary: Color(0xFFFFB3D9),    // Rosa suave
      secondary: Color(0xFFFF6B9D),  // Rosa medio
      tertiary: Color(0xFFFFF0F5),   // Rosa muy claro
    ),
    AppColorScheme.oceanBlue: ColorPalette(
      name: 'Ocean Blue',
      primary: Color(0xFF006494),    // Azul océano
      secondary: Color(0xFF0582CA),  // Azul cielo
      tertiary: Color(0xFF00A6FB),   // Azul claro
    ),
    AppColorScheme.forestGreen: ColorPalette(
      name: 'Forest Green',
      primary: Color(0xFF2D6A4F),    // Verde bosque
      secondary: Color(0xFF40916C),  // Verde medio
      tertiary: Color(0xFF52B788),   // Verde claro
    ),
    AppColorScheme.sunsetOrange: ColorPalette(
      name: 'Sunset Orange',
      primary: Color(0xFFFF6D00),    // Naranja intenso
      secondary: Color(0xFFFF9E00),  // Naranja medio
      tertiary: Color(0xFFFFBC42),   // Amarillo anaranjado
    ),
    AppColorScheme.lavenderDream: ColorPalette(
      name: 'Lavender Dream',
      primary: Color(0xFF7209B7),    // Púrpura intenso
      secondary: Color(0xFF9D4EDD),  // Lavanda medio
      tertiary: Color(0xFFC77DFF),   // Lavanda claro
    ),
    AppColorScheme.mintFresh: ColorPalette(
      name: 'Mint Fresh',
      primary: Color(0xFF06FFA5),    // Menta brillante
      secondary: Color(0xFF00D9A3),  // Verde agua
      tertiary: Color(0xFF4DFFC3),   // Menta claro
    ),
  };

  /// Obtiene la paleta completa según la selección
  static ColorPalette getPalette(AppColorScheme colorScheme) {
    return colorPalettes[colorScheme]!;
  }

  /// Genera el tema claro
  static ThemeData getLightTheme({
    AppColorScheme colorScheme = AppColorScheme.sakuraPink,
    bool useAmoled = false,
    bool useDynamicColor = false,
  }) {
    final palette = getPalette(colorScheme);
    final colorSchemeData = ColorScheme.fromSeed(
      seedColor: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.tertiary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeData,
      brightness: Brightness.light,
      
      // Tipografía
      textTheme: _buildTextTheme(colorSchemeData.onBackground),
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorSchemeData.surface,
        foregroundColor: colorSchemeData.onSurface,
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: colorSchemeData.outlineVariant,
      ),
    );
  }

  /// Genera el tema oscuro
  static ThemeData getDarkTheme({
    AppColorScheme colorScheme = AppColorScheme.sakuraPink,
    bool useAmoled = false,
    bool useDynamicColor = false,
  }) {
    final palette = getPalette(colorScheme);
    
    // Si es modo AMOLED, usar negro puro
    final backgroundColor = useAmoled ? Colors.black : null;
    final surfaceColor = useAmoled ? const Color(0xFF0A0A0A) : null;
    
    final colorSchemeData = ColorScheme.fromSeed(
      seedColor: palette.primary,
      secondary: palette.secondary,
      tertiary: palette.tertiary,
      brightness: Brightness.dark,
      surface: surfaceColor,
      background: backgroundColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeData,
      brightness: Brightness.dark,
      
      // Tipografía
      textTheme: _buildTextTheme(colorSchemeData.onBackground),
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorSchemeData.surface,
        foregroundColor: colorSchemeData.onSurface,
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: colorSchemeData.outlineVariant,
      ),
    );
  }

  /// Construye la tipografía personalizada
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  /// Nombre legible de la paleta de colores
  static String getColorSchemeName(AppColorScheme colorScheme) {
    return colorPalettes[colorScheme]!.name;
  }
}
