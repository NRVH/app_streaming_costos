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
      print('🔐 Solicitando permisos de calendario...');
      final permissionsGranted = await _calendarPlugin.requestPermissions();
      final result = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
      print('   Resultado: $result');
      if (!result) {
        print('   ❌ Permisos denegados');
      }
      return result;
    } catch (e) {
      print('❌ Error al solicitar permisos: $e');
      return false;
    }
  }

  /// Verifica si tiene permisos para acceder al calendario
  Future<bool> hasPermissions() async {
    try {
      final permissionsGranted = await _calendarPlugin.hasPermissions();
      final result = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
      return result;
    } catch (e) {
      print('❌ Error al verificar permisos: $e');
      return false;
    }
  }

  /// Obtiene los calendarios disponibles
  Future<List<Calendar>> getCalendars() async {
    try {
      print('');
      print('═══════════════════════════════════════');
      print('📅 DIAGNÓSTICO DE CALENDARIOS');
      print('═══════════════════════════════════════');
      
      // Verificar permisos
      print('🔐 Paso 1: Verificando permisos...');
      final hasPerms = await hasPermissions();
      print('   Permisos existentes: $hasPerms');
      
      if (!hasPerms) {
        print('⚠️  Sin permisos, solicitando...');
        final granted = await requestPermissions();
        print('   Permisos otorgados: $granted');
        if (!granted) {
          print('❌ PERMISOS DENEGADOS');
          print('═══════════════════════════════════════');
          return [];
        }
      }

      // Recuperar calendarios
      print('');
      print('📋 Paso 2: Recuperando calendarios del sistema...');
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      
      print('   isSuccess: ${calendarsResult.isSuccess}');
      print('   hasData: ${calendarsResult.data != null}');
      
      if (!calendarsResult.isSuccess) {
        print('❌ ERROR: retrieveCalendars falló');
        print('═══════════════════════════════════════');
        return [];
      }
      
      if (calendarsResult.data == null) {
        print('❌ ERROR: No hay data en el resultado');
        print('═══════════════════════════════════════');
        return [];
      }

      final allCalendars = calendarsResult.data!;
      print('   Total calendarios encontrados: ${allCalendars.length}');
      
      if (allCalendars.isEmpty) {
        print('');
        print('⚠️  NO HAY CALENDARIOS EN EL SISTEMA');
        print('   Posibles causas:');
        print('   1. No hay cuentas sincronizadas');
        print('   2. Las cuentas no tienen calendarios');
        print('   3. Los calendarios están ocultos');
        print('═══════════════════════════════════════');
        return [];
      }

      // Detalles de cada calendario
      print('');
      print('📊 Paso 3: Analizando calendarios...');
      for (int i = 0; i < allCalendars.length; i++) {
        final cal = allCalendars[i];
        print('');
        print('   Calendario #${i + 1}:');
        print('   - ID: ${cal.id}');
        print('   - Nombre: ${cal.name}');
        print('   - Cuenta: ${cal.accountName}');
        print('   - Tipo: ${cal.accountType}');
        print('   - Solo lectura: ${cal.isReadOnly}');
        print('   - Predeterminado: ${cal.isDefault}');
        print('   - Color: ${cal.color}');
      }

      // Filtrar calendarios editables
      final editableCalendars = allCalendars
          .where((cal) => cal.isReadOnly == false)
          .toList();
      
      print('');
      print('✅ Calendarios editables: ${editableCalendars.length}');
      
      if (editableCalendars.isEmpty) {
        print('');
        print('⚠️  TODOS LOS CALENDARIOS SON DE SOLO LECTURA');
        print('   Posibles causas:');
        print('   1. Cuentas sin permisos de escritura');
        print('   2. Calendarios compartidos (solo lectura)');
        print('   3. Calendarios de suscripción (solo lectura)');
      }
      
      print('═══════════════════════════════════════');
      return editableCalendars;
    } catch (e, stackTrace) {
      print('');
      print('❌ EXCEPCIÓN EN getCalendars():');
      print('   Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      print('═══════════════════════════════════════');
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
      var reminderDate = nextBillingDate.subtract(
        Duration(days: subscription.reminderDaysBefore),
      );
      
      // Si tiene hora específica configurada, usarla
      if (!subscription.reminderAllDay && subscription.reminderHour != null) {
        reminderDate = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          subscription.reminderHour!,
          subscription.reminderMinute ?? 0,
        );
      }
      
      print('📅 [CREATE] Fecha de recordatorio: $reminderDate');
      print('📅 [CREATE] Fecha de cobro: $nextBillingDate');
      print('📅 [CREATE] Todo el día: ${subscription.reminderAllDay}');

      // Para eventos de todo el día, usar medianoche en hora local
      DateTime eventStart;
      DateTime eventEnd;
      
      if (subscription.reminderAllDay) {
        // Todo el día: usar fecha sin hora (medianoche)
        eventStart = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);
        eventEnd = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 23, 59);
      } else {
        // Hora específica: usar la hora configurada
        eventStart = reminderDate;
        eventEnd = reminderDate.add(const Duration(hours: 1));
      }

      print('📅 [CREATE] Event start: $eventStart');
      print('📅 [CREATE] Event end: $eventEnd');

      final event = Event(
        calId,
        title: '💳 Pago ${subscription.name}',
        description: '🔔 Recordatorio SubTrack\n'
            '💰 Monto: ${subscription.currency} ${subscription.price.toStringAsFixed(2)}\n'
            '📅 Fecha de cobro: ${_formatDate(nextBillingDate)}\n'
            '🔄 Ciclo: ${_getBillingCycleName(subscription.billingCycle)}\n'
            '\n⚠️ Este recordatorio fue creado automáticamente por SubTrack',
        start: tz.TZDateTime.from(eventStart, local),
        end: tz.TZDateTime.from(eventEnd, local),
        allDay: subscription.reminderAllDay,
      );

      // Agregar RECURRENCIA MENSUAL (cada mes en el mismo día)
      // Calcular total de ocurrencias basado en fecha de fin
      int totalOccurrences;
      if (subscription.subscriptionEndDate != null) {
        // Calcular meses entre ahora y fecha de fin
        final now = DateTime.now();
        final endDate = subscription.subscriptionEndDate!;
        final monthsDiff = (endDate.year - now.year) * 12 + (endDate.month - now.month);
        totalOccurrences = monthsDiff > 0 ? monthsDiff + 1 : 1;
        print('📅 [CREATE] Creando $totalOccurrences recordatorios hasta ${_formatDate(endDate)}');
      } else {
        // Sin fecha de fin = indefinido (hasta 5 años por seguridad)
        totalOccurrences = 60; // Máximo 5 años
        print('📅 [CREATE] Creando $totalOccurrences recordatorios (indefinido, máx 5 años)');
      }
      
      event.recurrenceRule = RecurrenceRule(
        RecurrenceFrequency.Monthly,
        interval: 1,
        totalOccurrences: totalOccurrences,
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
        
        // Filtrar eventos de SubTrack ESTRICTAMENTE
        // Solo eventos que tengan nuestra firma única en la descripción
        final filtered = result.data!
            .where((event) {
              final title = event.title ?? '';
              final description = event.description ?? '';
              
              // CRITERIO ESTRICTO: Debe tener el emoji 💳 en el título
              // Y la firma única de SubTrack en la descripción
              final hasSubTrackSignature = title.contains('💳') && 
                     description.contains('Este recordatorio fue creado automáticamente por SubTrack');
              
              if (hasSubTrackSignature) {
                print('  ✅ "${event.title}" → Evento de SubTrack verificado');
              } else {
                print('  ⏭️ "${event.title}" → NO es de SubTrack');
              }
              
              return hasSubTrackSignature;
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
