import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/calendar_service.dart';
import '../providers/subscriptions_provider.dart';
import '../models/subscription_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  List<Calendar> _calendars = [];
  String? _selectedCalendarId;
  List<Event> _events = [];
  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _showAllEvents = false; // Nueva opción para mostrar todos los eventos

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() => _isLoading = true);

    final hasPerms = await _calendarService.hasPermissions();
    if (!hasPerms) {
      final granted = await _calendarService.requestPermissions();
      setState(() => _hasPermissions = granted);
      if (!granted) {
        setState(() => _isLoading = false);
        return;
      }
    } else {
      setState(() => _hasPermissions = true);
    }

    final calendars = await _calendarService.getCalendars();
    final defaultCalId = await _calendarService.getDefaultCalendarId();

    setState(() {
      _calendars = calendars;
      _selectedCalendarId = defaultCalId;
      _isLoading = false;
    });

    if (_selectedCalendarId != null) {
      await _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (_selectedCalendarId == null) return;

    setState(() => _isLoading = true);

    List<Event> events;
    
    if (_showAllEvents) {
      // Cargar TODOS los eventos sin filtro
      print('🔍 Cargando TODOS los eventos (sin filtro)');
      events = await _loadAllEvents();
    } else {
      // Cargar solo eventos de SubTrack (filtrados)
      print('🔍 Cargando eventos filtrados de SubTrack');
      events = await _calendarService.getSubscriptionEvents(_selectedCalendarId!);
    }

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<List<Event>> _loadAllEvents() async {
    try {
      final hasPerms = await _calendarService.hasPermissions();
      if (!hasPerms) return [];

      final now = DateTime.now();
      final start = tz.TZDateTime.from(now.subtract(const Duration(days: 90)), CalendarService.local);
      final end = tz.TZDateTime.from(now.add(const Duration(days: 365)), CalendarService.local);

      final result = await DeviceCalendarPlugin().retrieveEvents(
        _selectedCalendarId!,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );

      if (result.isSuccess && result.data != null) {
        print('📦 Total eventos sin filtro: ${result.data!.length}');
        return result.data!;
      }
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  Future<void> _syncWithSubscriptions() async {
    setState(() => _isLoading = true);

    try {
      final subscriptions = ref.read(subscriptionsProvider);
      int synced = 0;
      int errors = 0;

      for (final subscription in subscriptions) {
        if (subscription.reminderEnabled) {
          // Verificar si el evento existe
          bool eventExists = false;
          if (subscription.calendarEventId != null && subscription.calendarId != null) {
            eventExists = await _calendarService.eventExists(
              subscription.calendarEventId!,
              subscription.calendarId!,
            );
          }

          // Si no existe, crear uno nuevo
          if (!eventExists) {
            final calendarId = _selectedCalendarId ?? await _calendarService.getDefaultCalendarId();
            if (calendarId != null) {
              final eventId = await _calendarService.createReminder(
                subscription,
                calendarId: calendarId,
              );

              if (eventId != null) {
                subscription.calendarEventId = eventId;
                subscription.calendarId = calendarId;
                await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
                synced++;
              } else {
                errors++;
              }
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sincronización completa: $synced creados, $errors errores'),
            backgroundColor: errors > 0 ? Colors.orange : Colors.green,
          ),
        );
      }

      await _loadEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al sincronizar con el calendario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final activeReminders = subscriptions.where((s) => s.reminderEnabled).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        actions: [
          IconButton(
            icon: Icon(_showAllEvents ? Icons.filter_alt_off : Icons.filter_alt),
            tooltip: _showAllEvents ? 'Mostrar solo SubTrack' : 'Mostrar todos los eventos',
            color: _showAllEvents ? Colors.amber : null,
            onPressed: _isLoading ? null : () {
              setState(() {
                _showAllEvents = !_showAllEvents;
              });
              _loadEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar con suscripciones',
            onPressed: _isLoading ? null : _syncWithSubscriptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar eventos',
            onPressed: _isLoading ? null : _loadEvents,
          ),
        ],
      ),
      body: !_hasPermissions
          ? _buildNoPermissionsView()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildCalendarSelector(),
                    if (_showAllEvents) _buildAllEventsWarning(),
                    _buildStatsCard(activeReminders),
                    Expanded(child: _buildEventsList()),
                  ],
                ),
    );
  }

  Widget _buildAllEventsWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mostrando TODOS los eventos del calendario (${_events.length} eventos)',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPermissionsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Permisos de Calendario Necesarios',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'SubTrack necesita acceso al calendario para mostrar y gestionar tus recordatorios de suscripciones.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loadCalendars,
              icon: const Icon(Icons.lock_open),
              label: const Text('Otorgar Permisos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSelector() {
    if (_calendars.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendario',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCalendarId,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_month),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _calendars.map((calendar) {
              return DropdownMenuItem(
                value: calendar.id,
                child: Text(calendar.name ?? 'Sin nombre'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCalendarId = value;
              });
              _loadEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int activeReminders) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Recordatorios Activos',
              activeReminders.toString(),
              Icons.notifications_active,
              Colors.blue,
            ),
            _buildStatItem(
              'Eventos en Calendario',
              _events.length.toString(),
              Icons.event,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay eventos de recordatorios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Los recordatorios que crees aparecerán aquí',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: _syncWithSubscriptions,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar Ahora'),
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar eventos por fecha
    final sortedEvents = List<Event>.from(_events)
      ..sort((a, b) => (a.start ?? DateTime.now()).compareTo(b.start ?? DateTime.now()));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final start = event.start;
    final title = event.title ?? 'Sin título';
    final description = event.description ?? '';

    // Buscar la suscripción correspondiente
    final subscriptions = ref.read(subscriptionsProvider);
    final subscription = subscriptions.firstWhere(
      (s) => s.calendarEventId == event.eventId,
      orElse: () => subscriptions.firstWhere(
        (s) => title.contains(s.name),
        orElse: () => Subscription(
          id: '',
          name: '',
          price: 0,
          currency: '',
          category: '',
          colorValue: 0,
          billingDate: DateTime.now(),
          billingCycle: BillingCycle.monthly,
          createdAt: DateTime.now(),
        ),
      ),
    );

    final hasSubscription = subscription.id.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasSubscription
                ? Color(subscription.colorValue).withOpacity(0.2)
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event_note,
            color: hasSubscription
                ? Color(subscription.colorValue)
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (start != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(start),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSubscription)
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                tooltip: 'Ver suscripción',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit_subscription',
                    arguments: subscription,
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Eliminar recordatorio',
              color: Colors.red,
              onPressed: () => _deleteEvent(event, subscription),
            ),
          ],
        ),
        isThreeLine: description.isNotEmpty || start != null,
      ),
    );
  }

  Future<void> _deleteEvent(Event event, Subscription subscription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recordatorio'),
        content: Text(
          '¿Estás seguro de que deseas eliminar este recordatorio?\n\n"${event.title}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Eliminar del calendario
      if (_selectedCalendarId != null && event.eventId != null) {
        await _calendarService.deleteReminder(
          event.eventId!,
          calendarId: _selectedCalendarId,
        );

        // Si está vinculado a una suscripción, actualizar la suscripción
        if (subscription.id.isNotEmpty) {
          subscription.calendarEventId = null;
          subscription.calendarId = null;
          await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Recargar eventos
        await _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
