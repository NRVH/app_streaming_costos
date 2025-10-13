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

          // Opciones adicionales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Personalización',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.palette),
                    title: const Text('Color dinámico'),
                    subtitle: const Text('Usa el color del fondo de pantalla (Android 12+)'),
                    value: themePrefs.useDynamicColor,
                    onChanged: (value) => themeNotifier.setDynamicColor(value),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.brightness_1),
                    title: const Text('Modo AMOLED'),
                    subtitle: const Text('Negro puro para pantallas OLED'),
                    value: themePrefs.useAmoledMode,
                    onChanged: (value) => themeNotifier.setAmoledMode(value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vista previa
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Vista Previa',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.subscriptions, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Suscripción de Ejemplo',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Así se verá tu app',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: const Text('\$9.99'),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tema actual: ${themePrefs.modeDescription}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
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
