import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import '../services/calendar_service.dart';

/// Dialog para seleccionar un calendario
class CalendarSelectorDialog extends StatefulWidget {
  final String? currentCalendarId;

  const CalendarSelectorDialog({
    super.key,
    this.currentCalendarId,
  });

  @override
  State<CalendarSelectorDialog> createState() => _CalendarSelectorDialogState();
}

class _CalendarSelectorDialogState extends State<CalendarSelectorDialog> {
  final CalendarService _calendarService = CalendarService();
  List<Calendar> _calendars = [];
  String? _selectedCalendarId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedCalendarId = widget.currentCalendarId;
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verificar permisos
      final hasPerms = await _calendarService.hasPermissions();
      if (!hasPerms) {
        final granted = await _calendarService.requestPermissions();
        if (!granted) {
          setState(() {
            _error = 'Permisos de calendario denegados';
            _isLoading = false;
          });
          return;
        }
      }

      // Obtener calendarios
      final calendars = await _calendarService.getCalendars();
      
      if (calendars.isEmpty) {
        setState(() {
          _error = 'No se encontraron calendarios en tu dispositivo';
          _isLoading = false;
        });
        return;
      }

      // Si no hay calendario seleccionado, usar el predeterminado
      if (_selectedCalendarId == null) {
        final defaultCalId = await _calendarService.getDefaultCalendarId();
        _selectedCalendarId = defaultCalId ?? calendars.first.id;
      }

      setState(() {
        _calendars = calendars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar calendarios: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Seleccionar Calendario'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (!_isLoading && _calendars.isNotEmpty)
          FilledButton(
            onPressed: () {
              Navigator.pop(context, _selectedCalendarId);
            },
            child: const Text('Seleccionar'),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando calendarios...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadCalendars,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_calendars.isEmpty) {
      return SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron calendarios',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Asegúrate de tener la app de Calendario instalada',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selecciona el calendario donde quieres guardar tus recordatorios',
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Calendarios disponibles:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _calendars.length,
            itemBuilder: (context, index) {
              final calendar = _calendars[index];
              final isSelected = calendar.id == _selectedCalendarId;
              final isDefault = calendar.isDefault ?? false;
              final accountName = calendar.accountName ?? 'Sin cuenta';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: isSelected ? 3 : 1,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: RadioListTile<String>(
                  value: calendar.id!,
                  groupValue: _selectedCalendarId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCalendarId = value;
                    });
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          calendar.name ?? 'Sin nombre',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Text(
                            'Predeterminado',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              accountName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (calendar.color != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(calendar.color!),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Color del calendario',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Función auxiliar para mostrar el selector de calendario
Future<String?> showCalendarSelector(
  BuildContext context, {
  String? currentCalendarId,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => CalendarSelectorDialog(
      currentCalendarId: currentCalendarId,
    ),
  );
}
