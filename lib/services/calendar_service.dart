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
      final hasPerms = await hasPermissions();
      if (!hasPerms) {
        final granted = await requestPermissions();
        if (!granted) return null;
      }

      final calId = calendarId ?? await getDefaultCalendarId();
      if (calId == null) return null;

      final nextBillingDate = subscription.getNextBillingDate();
      final reminderDate = nextBillingDate.subtract(
        Duration(days: subscription.reminderDaysBefore),
      );

      final event = Event(
        calId,
        title: 'Pago de ${subscription.name}',
        description: 'Recordatorio de pago de suscripción\n'
            'Monto: ${subscription.currency} ${subscription.price.toStringAsFixed(2)}\n'
            'Fecha de cobro: ${_formatDate(nextBillingDate)}',
        start: tz.TZDateTime.from(reminderDate, local),
        end: tz.TZDateTime.from(
          reminderDate.add(const Duration(hours: 1)),
          local,
        ),
        allDay: false,
      );

      // Agregar alarma
      event.reminders = [
        Reminder(minutes: 0), // Alarma al momento del evento
      ];

      final result = await _calendarPlugin.createOrUpdateEvent(event);
      
      if (result?.isSuccess == true && result?.data != null) {
        return result!.data;
      }
      
      return null;
    } catch (e) {
      return null;
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

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}
