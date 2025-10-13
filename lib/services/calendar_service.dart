import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription_model.dart';

/// Servicio para gestionar recordatorios en el calendario del dispositivo
class CalendarService {
  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();
  
  static final tz.Location local = tz.getLocation('America/Mexico_City');

  /// Solicita permisos para acceder al calendario
  Future<bool> requestPermissions() async {
    try {
      final permissionsGranted = await _calendarPlugin.requestPermissions();
      return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Verifica si tiene permisos para acceder al calendario
  Future<bool> hasPermissions() async {
    try {
      final permissionsGranted = await _calendarPlugin.hasPermissions();
      return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los calendarios disponibles
  Future<List<Calendar>> getCalendars() async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        final granted = await requestPermissions();
        if (!granted) return [];
      }

      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        return calendarsResult.data!
            .where((cal) => cal.isReadOnly == false)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene el calendario predeterminado
  Future<String?> getDefaultCalendarId() async {
    final calendars = await getCalendars();
    if (calendars.isEmpty) return null;
    
    // Buscar el calendario predeterminado o usar el primero
    final defaultCalendar = calendars.firstWhere(
      (cal) => cal.isDefault ?? false,
      orElse: () => calendars.first,
    );
    
    return defaultCalendar.id;
  }

  /// Crea un recordatorio para una suscripción
  Future<String?> createReminder(
    Subscription subscription, {
    String? calendarId,
  }) async {
    try {
      print('📅 [CREATE] Iniciando creación de recordatorio para: ${subscription.name}');
      
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        print('⚠️ [CREATE] Sin permisos, solicitando...');
        final granted = await requestPermissions();
        if (!granted) {
          print('❌ [CREATE] Permisos denegados');
          return null;
        }
      }

      final calId = calendarId ?? await getDefaultCalendarId();
      if (calId == null) {
        print('❌ [CREATE] No se encontró calendario');
        return null;
      }
      
      print('📅 [CREATE] Usando calendario ID: $calId');

      final nextBillingDate = subscription.getNextBillingDate();
      final reminderDate = nextBillingDate.subtract(
        Duration(days: subscription.reminderDaysBefore),
      );
      
      print('📅 [CREATE] Fecha de recordatorio: $reminderDate');
      print('📅 [CREATE] Fecha de cobro: $nextBillingDate');

      final event = Event(
        calId,
        title: '💳 Pago ${subscription.name}',
        description: '🔔 Recordatorio SubTrack\n'
            '💰 Monto: ${subscription.currency} ${subscription.price.toStringAsFixed(2)}\n'
            '📅 Fecha de cobro: ${_formatDate(nextBillingDate)}\n'
            '🔄 Ciclo: ${_getBillingCycleName(subscription.billingCycle)}\n'
            '\n⚠️ Este recordatorio fue creado automáticamente por SubTrack',
        start: tz.TZDateTime.from(reminderDate, local),
        end: tz.TZDateTime.from(
          reminderDate.add(const Duration(hours: 1)),
          local,
        ),
        allDay: false,
      );

      // Agregar alarmas múltiples para asegurar notificación
      event.reminders = [
        Reminder(minutes: 0), // Al momento del evento
        Reminder(minutes: 60), // 1 hora antes
      ];

      print('📅 [CREATE] Creando evento en calendario...');
      final result = await _calendarPlugin.createOrUpdateEvent(event);
      
      if (result?.isSuccess == true && result?.data != null) {
        print('✅ [CREATE] Evento creado exitosamente! ID: ${result!.data}');
        return result.data;
      } else {
        print('❌ [CREATE] Fallo al crear evento');
      }
      
      return null;
    } catch (e) {
      print('❌ [CREATE] Error: $e');
      return null;
    }
  }
  
  /// Obtiene el nombre del ciclo de facturación
  String _getBillingCycleName(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 'Mensual';
      case BillingCycle.quarterly:
        return 'Trimestral';
      case BillingCycle.semiannual:
        return 'Semestral';
      case BillingCycle.annual:
        return 'Anual';
    }
  }

  /// Actualiza un recordatorio existente
  Future<bool> updateReminder(
    Subscription subscription,
    String eventId, {
    String? calendarId,
  }) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return false;

      final calId = calendarId ?? await getDefaultCalendarId();
      if (calId == null) return false;

      // Eliminar el evento anterior
      await deleteReminder(eventId, calendarId: calId);

      // Crear uno nuevo
      final newEventId = await createReminder(
        subscription,
        calendarId: calId,
      );

      return newEventId != null;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un recordatorio
  Future<bool> deleteReminder(
    String eventId, {
    String? calendarId,
  }) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return false;

      final calId = calendarId ?? await getDefaultCalendarId();
      if (calId == null) return false;

      final result = await _calendarPlugin.deleteEvent(calId, eventId);
      return result?.isSuccess ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un evento específico
  Future<Event?> getEvent(String eventId, String calendarId) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) return null;

      final result = await _calendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          eventIds: [eventId],
        ),
      );

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        return result.data!.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todos los eventos de recordatorios de suscripciones
  Future<List<Event>> getSubscriptionEvents(String calendarId) async {
    try {
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        print('❌ No hay permisos de calendario');
        return [];
      }

      final now = DateTime.now();
      final start = tz.TZDateTime.from(now.subtract(const Duration(days: 90)), local);
      final end = tz.TZDateTime.from(now.add(const Duration(days: 365)), local);

      print('📅 Buscando eventos en calendario: $calendarId');
      print('📅 Rango: $start → $end');

      final result = await _calendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );

      if (result.isSuccess && result.data != null) {
        print('📦 Total eventos encontrados: ${result.data!.length}');
        
        // Mostrar todos los eventos para debug
        for (var event in result.data!) {
          print('  📌 "${event.title}" (${event.start})');
        }
        
        // Filtrar eventos de SubTrack con múltiples criterios
        final filtered = result.data!
            .where((event) {
              final title = event.title?.toLowerCase() ?? '';
              final description = event.description?.toLowerCase() ?? '';
              
              // Buscar múltiples indicadores de eventos de SubTrack
              final matches = 
                     // Por emoji en el título
                     title.contains('💳') ||
                     title.contains('💰') ||
                     // Por texto en título
                     title.contains('pago') ||
                     title.contains('suscripción') ||
                     title.contains('suscripcion') ||
                     // Por descripción
                     description.contains('subtrack') ||
                     description.contains('recordatorio subtrack') ||
                     description.contains('suscripción') ||
                     description.contains('suscripcion') ||
                     // Por patrón de fecha de cobro
                     description.contains('fecha de cobro') ||
                     description.contains('ciclo:');
              
              if (matches) {
                print('  ✅ "${event.title}" → Coincide con filtro');
              }
              
              return matches;
            })
            .toList();
        
        print('✅ Eventos filtrados para SubTrack: ${filtered.length}');
        return filtered;
      }
      
      print('❌ No se pudieron obtener eventos');
      return [];
    } catch (e) {
      print('❌ Error al obtener eventos: $e');
      return [];
    }
  }

  /// Verifica si un evento existe
  Future<bool> eventExists(String eventId, String calendarId) async {
    final event = await getEvent(eventId, calendarId);
    return event != null;
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
