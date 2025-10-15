import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_preferences.dart' as model;
import '../providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePrefs = ref.watch(themePreferencesProvider);
    final themeNotifier = ref.read(themePreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apariencia'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selector de modo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.brightness_6,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Modo de Tema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThemeModeOption(
                    context,
                    themePrefs,
                    themeNotifier,
                    model.ThemeMode.system,
                    Icons.settings_suggest,
                    'Según el sistema',
                    'Usa el tema configurado en tu dispositivo',
                  ),
                  _buildThemeModeOption(
                    context,
                    themePrefs,
                    themeNotifier,
                    model.ThemeMode.light,
                    Icons.light_mode,
                    'Claro',
                    'Siempre usa el tema claro',
                  ),
                  _buildThemeModeOption(
                    context,
                    themePrefs,
                    themeNotifier,
                    model.ThemeMode.dark,
                    Icons.dark_mode,
                    'Oscuro',
                    'Siempre usa el tema oscuro',
                  ),
                  _buildThemeModeOption(
                    context,
                    themePrefs,
                    themeNotifier,
                    model.ThemeMode.scheduled,
                    Icons.schedule,
                    'Programado',
                    'Cambia automáticamente según el horario',
                  ),
                  _buildThemeModeOption(
                    context,
                    themePrefs,
                    themeNotifier,
                    model.ThemeMode.auto,
                    Icons.brightness_auto,
                    'Automático',
                    'Tema oscuro de 6:00 PM a 6:00 AM',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Configuración de horario (solo si está en modo programado)
          if (themePrefs.mode == model.ThemeMode.scheduled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Horario Programado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.nightlight),
                      title: const Text('Tema oscuro desde'),
                      subtitle: Text(themePrefs.darkStartTimeString),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(
                        context,
                        themeNotifier,
                        true,
                        themePrefs.darkStartHour,
                        themePrefs.darkStartMinute,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.wb_sunny),
                      title: const Text('Tema claro desde'),
                      subtitle: Text(themePrefs.darkEndTimeString),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(
                        context,
                        themeNotifier,
                        false,
                        themePrefs.darkEndHour,
                        themePrefs.darkEndMinute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Selector de color
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Esquema de Color',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el color principal de la aplicación',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid de opciones de color
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.sakuraPink,
                        'Rosa Sakura',
                        const Color(0xFFFFB3D9),
                        const Color(0xFFFF6B9D),
                        const Color(0xFFFFF0F5),
                      ),
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.oceanBlue,
                        'Azul Océano',
                        const Color(0xFF006494),
                        const Color(0xFF0582CA),
                        const Color(0xFF00A6FB),
                      ),
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.forestGreen,
                        'Verde Bosque',
                        const Color(0xFF2D6A4F),
                        const Color(0xFF40916C),
                        const Color(0xFF52B788),
                      ),
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.sunsetOrange,
                        'Naranja Atardecer',
                        const Color(0xFFFF6D00),
                        const Color(0xFFFF9E00),
                        const Color(0xFFFFBC42),
                      ),
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.lavenderDream,
                        'Lavanda Sueño',
                        const Color(0xFF7209B7),
                        const Color(0xFF9D4EDD),
                        const Color(0xFFC77DFF),
                      ),
                      _buildColorOption(
                        context,
                        themePrefs,
                        themeNotifier,
                        model.AppColorScheme.mintFresh,
                        'Menta Fresca',
                        const Color(0xFF06FFA5),
                        const Color(0xFF00D9A3),
                        const Color(0xFF4DFFC3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Color dinámico
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Personalización Avanzada',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.wallpaper),
                    title: const Text('Color dinámico'),
                    subtitle: const Text('Usa el color del fondo de pantalla\n(Android 12+ con Material You)'),
                    value: themePrefs.useDynamicColor,
                    onChanged: (value) => themeNotifier.setDynamicColor(value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (themePrefs.useDynamicColor)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El color dinámico anula el esquema seleccionado arriba',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    model.ThemePreferences prefs,
    ThemePreferencesNotifier notifier,
    model.ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = prefs.mode == mode;

    return InkWell(
      onTap: () => notifier.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    model.ThemePreferences prefs,
    ThemePreferencesNotifier notifier,
    model.AppColorScheme colorScheme,
    String name,
    Color color1,
    Color color2,
    Color color3,
  ) {
    final isSelected = prefs.colorScheme == colorScheme;

    return InkWell(
      onTap: () => notifier.setColorScheme(colorScheme),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tres círculos de colores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color1,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color2,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color3,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    ThemePreferencesNotifier notifier,
    bool isStartTime,
    int initialHour,
    int initialMinute,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      if (isStartTime) {
        await notifier.setDarkStartTime(time);
      } else {
        await notifier.setDarkEndTime(time);
      }
    }
  }
}