import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/update_provider.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'calendar_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _formatLastChecked(DateTime lastChecked) {
    final now = DateTime.now();
    final difference = now.difference(lastChecked);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    final currentColorScheme = ref.watch(colorSchemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Apariencia
          const SectionHeader(title: 'Apariencia'),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Modo oscuro'),
            subtitle: Text(
              isDarkMode ? 'Tema oscuro activado' : 'Tema claro activado',
            ),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleThemeMode();
            },
          ),
          ListTile(
            leading: _buildColorPalettePreview(currentColorScheme, size: 40),
            title: const Text('Color de tema'),
            subtitle: Text(AppTheme.getColorSchemeName(currentColorScheme)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showColorSchemeDialog(context, ref, currentColorScheme),
          ),
          const Divider(),

          // Información
          const SectionHeader(title: 'Información'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versión'),
            subtitle: Text(AppConstants.appVersion),
          ),
          Consumer(
            builder: (context, ref, child) {
              final updateState = ref.watch(updateProvider);
              final isChecking = updateState.isChecking;

              return ListTile(
                leading: isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Badge(
                        isLabelVisible: updateState.hasUpdate,
                        backgroundColor: Colors.amber,
                        label: const Text('1'),
                        child: const Icon(Icons.system_update),
                      ),
                title: const Text('Buscar actualizaciones'),
                subtitle: updateState.hasUpdate
                    ? Text(
                        'Versión ${updateState.availableUpdate!.version} disponible',
                        style: const TextStyle(color: Colors.amber),
                      )
                    : updateState.lastChecked != null
                        ? Text('Última verificación: ${_formatLastChecked(updateState.lastChecked!)}')
                        : const Text('Verifica si hay nuevas versiones'),
                trailing: isChecking
                    ? null
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: isChecking
                    ? null
                    : () async {
                        await ref.read(updateProvider.notifier).checkForUpdates();
                        final state = ref.read(updateProvider);
                        
                        if (context.mounted) {
                          if (state.hasUpdate) {
                            final updateService = UpdateService();
                            final currentVersion = await updateService.getCurrentVersion();
                            showUpdateDialog(
                              context,
                              state.availableUpdate!,
                              currentVersion,
                            );
                          } else if (!state.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ya tienes la versión más reciente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Acerca de'),
            subtitle: const Text('Aplicación de gestión de suscripciones'),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(),

          // Recordatorios
          const SectionHeader(title: 'Recordatorios'),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Gestionar recordatorios'),
            subtitle: const Text('Ver y sincronizar eventos del calendario'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
          ),
          const Divider(),

          // Datos
          const SectionHeader(title: 'Datos'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Exportar datos'),
            subtitle: const Text('Guarda una copia de tus suscripciones'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función próximamente disponible'),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildColorPalettePreview(AppColorScheme scheme, {double size = 40}) {
    final palette = AppTheme.getPalette(scheme);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Color primario (círculo completo de fondo)
          Container(
            decoration: BoxDecoration(
              color: palette.primary,
              shape: BoxShape.circle,
            ),
          ),
          // Color secundario (mitad derecha)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: size / 2,
              decoration: BoxDecoration(
                color: palette.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size / 2),
                  bottomRight: Radius.circular(size / 2),
                ),
              ),
            ),
          ),
          // Color terciario (punto central)
          Center(
            child: Container(
              width: size / 3,
              height: size / 3,
              decoration: BoxDecoration(
                color: palette.tertiary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorSchemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme current,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona una paleta'),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppColorScheme.values.map((scheme) {
              final name = AppTheme.getColorSchemeName(scheme);
              final isSelected = scheme == current;
              
              return InkWell(
                onTap: () {
                  ref.read(colorSchemeProvider.notifier).setColorScheme(scheme);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                  ),
                  child: Row(
                    children: [
                      _buildColorPalettePreview(scheme, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
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
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.subscriptions,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Una aplicación simple y profesional para gestionar tus suscripciones de streaming y otros servicios.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Características:\n'
          '• Gestión de suscripciones\n'
          '• Recordatorios en calendario\n'
          '• Múltiples temas y colores\n'
          '• Resumen y estadísticas\n'
          '• Sin anuncios ni seguimiento',
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
