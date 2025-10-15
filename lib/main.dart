import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar timezone
  tz.initializeTimeZones();
  
  // Inicializar base de datos
  await DatabaseService.init();
  
  // Configurar orientación (solo portrait para móvil)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePrefs = ref.watch(themePreferencesProvider);
    final themeNotifier = ref.read(themePreferencesProvider.notifier);
    
    // Obtener el brightness del sistema
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final currentBrightness = themeNotifier.getCurrentBrightness(systemBrightness);
    
    // Convertir el enum de theme_preferences al enum de app_theme
    final appColorScheme = _convertToAppColorScheme(themePrefs.colorScheme);

    return MaterialApp(
      title: 'Mis Suscripciones',
      debugShowCheckedModeBanner: false,
      
      // Temas
      theme: AppTheme.getLightTheme(
        colorScheme: appColorScheme,
        useDynamicColor: themePrefs.useDynamicColor,
      ),
      darkTheme: AppTheme.getDarkTheme(
        colorScheme: appColorScheme,
        useDynamicColor: themePrefs.useDynamicColor,
      ),
      themeMode: currentBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light,
      
      // Pantalla principal
      home: const MainNavigationScreen(),
    );
  }
  
  /// Convierte el enum de theme_preferences al enum de app_theme
  AppColorScheme _convertToAppColorScheme(dynamic colorScheme) {
    // Mapear por nombre ya que son enums diferentes
    final name = colorScheme.toString().split('.').last;
    switch (name) {
      case 'sakuraPink':
        return AppColorScheme.sakuraPink;
      case 'oceanBlue':
        return AppColorScheme.oceanBlue;
      case 'forestGreen':
        return AppColorScheme.forestGreen;
      case 'sunsetOrange':
        return AppColorScheme.sunsetOrange;
      case 'lavenderDream':
        return AppColorScheme.lavenderDream;
      case 'mintFresh':
        return AppColorScheme.mintFresh;
      default:
        return AppColorScheme.sakuraPink;
    }
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
