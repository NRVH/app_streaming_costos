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
    // Contar cuántos eventos están vinculados correctamente
    final subscriptions = ref.read(subscriptionsProvider);
    int syncedCount = 0;
    for (final sub in subscriptions) {
      if (sub.reminderEnabled && sub.calendarEventId != null) {
        syncedCount++;
      }
    }
    
    final bool needsSync = activeReminders > _events.length || syncedCount < activeReminders;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Recordatorios\nActivos',
                  activeReminders.toString(),
                  Icons.notifications_active,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Eventos\nSincronizados',
                  syncedCount.toString(),
                  Icons.sync,
                  Colors.purple,
                ),
                _buildStatItem(
                  'En\nCalendario',
                  _events.length.toString(),
                  Icons.event,
                  Colors.green,
                ),
              ],
            ),
            if (needsSync) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Algunos recordatorios necesitan sincronización',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _syncWithSubscriptions,
                      child: const Text('Sincronizar'),
                    ),
                  ],
                ),
              ),
            ],
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
      final subscriptions = ref.read(subscriptionsProvider);
      final activeReminders = subscriptions.where((s) => s.reminderEnabled).length;
      
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
                _showAllEvents 
                    ? 'No hay eventos en este calendario'
                    : 'No hay eventos de SubTrack',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _showAllEvents
                    ? 'Este calendario no tiene eventos en el rango de fechas consultado'
                    : activeReminders > 0
                        ? 'Tienes $activeReminders recordatorio(s) activo(s) que no aparecen en el calendario.\n\n¿Quieres sincronizarlos?'
                        : 'Crea una suscripción con recordatorio activado\ny aparecerá aquí automáticamente',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!_showAllEvents && activeReminders > 0) ...[
                FilledButton.icon(
                  onPressed: _syncWithSubscriptions,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sincronizar Ahora'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllEvents = !_showAllEvents;
                  });
                  _loadEvents();
                },
                icon: Icon(_showAllEvents ? Icons.filter_alt : Icons.filter_alt_off),
                label: Text(_showAllEvents ? 'Mostrar solo SubTrack' : 'Ver todos los eventos'),
              ),
            ],
          ),
        ),
      );
    }

    // Si está mostrando todos los eventos, usar vista plana
    if (_showAllEvents) {
      return _buildFlatEventsList();
    }

    // Vista agrupada por suscripción
    return _buildGroupedEventsList();
  }

  Widget _buildFlatEventsList() {
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

  Widget _buildGroupedEventsList() {
    final subscriptions = ref.read(subscriptionsProvider);
    
    // Agrupar eventos por suscripción
    Map<String, List<Event>> grouped = {};
    
    for (final event in _events) {
      final title = event.title ?? '';
      
      // Buscar la suscripción correspondiente
      Subscription? matchedSub;
      for (final sub in subscriptions) {
        if (sub.calendarEventId == event.eventId ||
            title.toLowerCase().contains(sub.name.toLowerCase()) ||
            title.contains(sub.name)) {
          matchedSub = sub;
          break;
        }
      }
      
      final key = matchedSub?.id ?? 'unknown_${title.hashCode}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(event);
    }

    // Convertir a lista y ordenar por cantidad de eventos
    final groupList = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupList.length,
      itemBuilder: (context, index) {
        final entry = groupList[index];
        final subId = entry.key;
        final events = entry.value;
        
        // Buscar suscripción
        final subscription = subscriptions.firstWhere(
          (s) => s.id == subId,
          orElse: () => Subscription(
            id: '',
            name: events.first.title ?? 'Desconocido',
            price: 0,
            currency: '',
            category: '',
            colorValue: Colors.grey.value,
            billingDate: DateTime.now(),
            billingCycle: BillingCycle.monthly,
            createdAt: DateTime.now(),
          ),
        );

        return _buildGroupedCard(subscription, events);
      },
    );
  }

  Widget _buildGroupedCard(Subscription subscription, List<Event> events) {
    // Ordenar eventos por fecha
    events.sort((a, b) => (a.start ?? DateTime.now()).compareTo(b.start ?? DateTime.now()));
    
    final hasSubscription = subscription.id.isNotEmpty;
    final color = hasSubscription ? Color(subscription.colorValue) : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            Icons.subscriptions,
            color: color,
          ),
        ),
        title: Text(
          subscription.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${events.length} recordatorio${events.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (hasSubscription)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  '${events.length}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'delete_all') {
                    _deleteAllEventsForSubscription(subscription, events);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar todos (${events.length})',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        children: events.map((event) => _buildCompactEventCard(event, subscription)).toList(),
      ),
    );
  }

  Widget _buildCompactEventCard(Event event, Subscription subscription) {
    final start = event.start;
    final title = event.title ?? 'Sin título';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        Icons.event_note,
        size: 20,
        color: subscription.id.isNotEmpty
            ? Color(subscription.colorValue).withOpacity(0.7)
            : Colors.grey,
      ),
      title: start != null
          ? Text(
              DateFormat('dd MMM yyyy').format(start),
              style: const TextStyle(fontSize: 14),
            )
          : null,
      subtitle: event.allDay == true
          ? const Text('Todo el día', style: TextStyle(fontSize: 11))
          : start != null
              ? Text(
                  DateFormat('HH:mm').format(start),
                  style: const TextStyle(fontSize: 11),
                )
              : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        tooltip: 'Eliminar',
        color: Colors.red,
        onPressed: () => _deleteEvent(event, subscription),
      ),
    );
  }

  Future<void> _deleteAllEventsForSubscription(Subscription subscription, List<Event> events) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Todos los Recordatorios'),
        content: Text(
          '¿Estás seguro de que deseas eliminar TODOS los ${events.length} recordatorios de "${subscription.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar Todos'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      int deleted = 0;
      int errors = 0;

      for (final event in events) {
        if (_selectedCalendarId != null && event.eventId != null) {
          try {
            await _calendarService.deleteReminder(
              event.eventId!,
              calendarId: _selectedCalendarId,
            );
            deleted++;
          } catch (e) {
            errors++;
          }
        }
      }

      // Actualizar la suscripción si estaba vinculada
      if (subscription.id.isNotEmpty) {
        subscription.calendarEventId = null;
        subscription.calendarId = null;
        await ref.read(subscriptionsProvider.notifier).updateSubscription(subscription);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deleted recordatorios eliminados' + (errors > 0 ? ', $errors errores' : '')),
            backgroundColor: errors > 0 ? Colors.orange : Colors.green,
          ),
        );
      }

      // Recargar eventos
      await _loadEvents();
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

  Widget _buildEventCard(Event event) {
    final start = event.start;
    final title = event.title ?? 'Sin título';
    final description = event.description ?? '';

    // Buscar la suscripción correspondiente
    final subscriptions = ref.read(subscriptionsProvider);
    final subscription = subscriptions.firstWhere(
      (s) => s.calendarEventId == event.eventId,
      orElse: () => subscriptions.firstWhere(
        (s) => title.toLowerCase().contains(s.name.toLowerCase()) ||
               title.contains(s.name),
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
    final isSubTrackEvent = description.toLowerCase().contains('subtrack') ||
                           title.contains('💳') ||
                           title.contains('💰');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasSubscription ? 2 : 1,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasSubscription
                ? Color(subscription.colorValue).withOpacity(0.2)
                : isSubTrackEvent
                    ? Colors.purple.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: hasSubscription
                ? Border.all(color: Color(subscription.colorValue), width: 2)
                : null,
          ),
          child: Icon(
            hasSubscription ? Icons.subscriptions : Icons.event_note,
            color: hasSubscription
                ? Color(subscription.colorValue)
                : isSubTrackEvent
                    ? Colors.purple
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (hasSubscription)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 10, color: Colors.green),
                    SizedBox(width: 2),
                    Text(
                      'Vinculado',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (start != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(start),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (hasSubscription) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (description.isNotEmpty && !_showAllEvents) ...[
              const SizedBox(height: 4),
              Text(
                description.split('\n').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSubscription)
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Editar suscripción',
                onPressed: () {
                  // Aquí deberías navegar a la pantalla de edición
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Y luego abrir la edición
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Eliminar recordatorio',
              color: Colors.red,
              onPressed: () => _deleteEvent(event, subscription),
            ),
          ],
        ),
        isThreeLine: true,
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
