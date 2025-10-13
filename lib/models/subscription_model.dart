import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String category;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  DateTime billingDate;

  @HiveField(7)
  BillingCycle billingCycle;

  @HiveField(8)
  bool reminderEnabled;

  @HiveField(9)
  int reminderDaysBefore;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  String? calendarEventId;

  @HiveField(13)
  String? calendarId;

  @HiveField(14)
  DateTime? lastPaymentDate;

  @HiveField(15)
  int? reminderHour; // Hora del recordatorio (0-23), null = todo el día

  @HiveField(16)
  int? reminderMinute; // Minuto del recordatorio (0-59)

  @HiveField(17)
  bool reminderAllDay; // true = recordatorio todo el día

  @HiveField(18)
  SubscriptionStatus status; // Estado: activa, pausada, cancelada

  @HiveField(19)
  DateTime? subscriptionEndDate; // Fecha de fin de suscripción (null = indefinida)

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.category,
    required this.colorValue,
    required this.billingDate,
    required this.billingCycle,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 1,
    this.notes,
    required this.createdAt,
    this.calendarEventId,
    this.calendarId,
    this.lastPaymentDate,
    this.reminderHour,
    this.reminderMinute,
    this.reminderAllDay = false,
    this.status = SubscriptionStatus.active,
    this.subscriptionEndDate,
  });

  /// Obtiene la próxima fecha de cobro
  DateTime getNextBillingDate() {
    final now = DateTime.now();
    DateTime nextDate = billingDate;

    while (nextDate.isBefore(now)) {
      switch (billingCycle) {
        case BillingCycle.monthly:
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 1,
            nextDate.day,
          );
          break;
        case BillingCycle.quarterly:
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 3,
            nextDate.day,
          );
          break;
        case BillingCycle.semiannual:
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 6,
            nextDate.day,
          );
          break;
        case BillingCycle.annual:
          nextDate = DateTime(
            nextDate.year + 1,
            nextDate.month,
            nextDate.day,
          );
          break;
      }
    }

    return nextDate;
  }

  /// Calcula el costo mensual equivalente
  double getMonthlyCost() {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return price;
      case BillingCycle.quarterly:
        return price / 3;
      case BillingCycle.semiannual:
        return price / 6;
      case BillingCycle.annual:
        return price / 12;
    }
  }

  /// Obtiene los días restantes hasta el próximo cobro
  int getDaysUntilNextBilling() {
    final nextDate = getNextBillingDate();
    return nextDate.difference(DateTime.now()).inDays;
  }

  /// Marca la suscripción como pagada en la fecha actual
  void markAsPaid() {
    lastPaymentDate = DateTime.now();
  }

  /// Desmarca la suscripción como pagada (revierte el pago)
  void unmarkAsPaid() {
    lastPaymentDate = null;
  }

  /// Cancela la suscripción
  void cancel() {
    status = SubscriptionStatus.canceled;
  }

  /// Renueva la suscripción (de cancelada/pausada a activa)
  void renew({DateTime? newEndDate}) {
    status = SubscriptionStatus.active;
    subscriptionEndDate = newEndDate;
  }

  /// Pausa la suscripción
  void pause() {
    status = SubscriptionStatus.paused;
  }

  /// Verifica si la suscripción está activa
  bool get isActive => status == SubscriptionStatus.active;

  /// Verifica si la suscripción está cancelada
  bool get isCanceled => status == SubscriptionStatus.canceled;

  /// Verifica si la suscripción está pausada
  bool get isPaused => status == SubscriptionStatus.paused;

  /// Verifica si la suscripción ha expirado (pasó la fecha de fin)
  bool get isExpired {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isAfter(subscriptionEndDate!);
  }

  /// Verifica si la suscripción fue pagada este mes/ciclo
  bool isPaidThisCycle() {
    if (lastPaymentDate == null) return false;
    
    final nextBilling = getNextBillingDate();
    final lastBilling = _getPreviousBillingDate(nextBilling);
    
    return lastPaymentDate!.isAfter(lastBilling) && 
           lastPaymentDate!.isBefore(nextBilling);
  }

  /// Obtiene la fecha del cobro anterior
  DateTime getPreviousBillingDate(DateTime fromDate) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(fromDate.year, fromDate.month - 1, fromDate.day);
      case BillingCycle.quarterly:
        return DateTime(fromDate.year, fromDate.month - 3, fromDate.day);
      case BillingCycle.semiannual:
        return DateTime(fromDate.year, fromDate.month - 6, fromDate.day);
      case BillingCycle.annual:
        return DateTime(fromDate.year - 1, fromDate.month, fromDate.day);
    }
  }

  DateTime _getPreviousBillingDate(DateTime fromDate) {
    return getPreviousBillingDate(fromDate);
  }

  /// Copia la suscripción con valores modificados
  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    String? category,
    int? colorValue,
    DateTime? billingDate,
    BillingCycle? billingCycle,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    String? notes,
    DateTime? createdAt,
    String? calendarEventId,
    String? calendarId,
    DateTime? lastPaymentDate,
    int? reminderHour,
    int? reminderMinute,
    bool? reminderAllDay,
    SubscriptionStatus? status,
    DateTime? subscriptionEndDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      billingDate: billingDate ?? this.billingDate,
      billingCycle: billingCycle ?? this.billingCycle,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      calendarId: calendarId ?? this.calendarId,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderAllDay: reminderAllDay ?? this.reminderAllDay,
      status: status ?? this.status,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}

@HiveType(typeId: 2)
enum SubscriptionStatus {
  @HiveField(0)
  active, // Activa

  @HiveField(1)
  paused, // Pausada

  @HiveField(2)
  canceled, // Cancelada/Archivada
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Activa';
      case SubscriptionStatus.paused:
        return 'Pausada';
      case SubscriptionStatus.canceled:
        return 'Cancelada';
    }
  }

  String get emoji {
    switch (this) {
      case SubscriptionStatus.active:
        return '✅';
      case SubscriptionStatus.paused:
        return '⏸️';
      case SubscriptionStatus.canceled:
        return '❌';
    }
  }
}

@HiveType(typeId: 1)
enum BillingCycle {
  @HiveField(0)
  monthly,

  @HiveField(1)
  quarterly,

  @HiveField(2)
  semiannual,

  @HiveField(3)
  annual,
}

extension BillingCycleExtension on BillingCycle {
  String get displayName {
    switch (this) {
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

  String get shortName {
    switch (this) {
      case BillingCycle.monthly:
        return '/mes';
      case BillingCycle.quarterly:
        return '/3 meses';
      case BillingCycle.semiannual:
        return '/6 meses';
      case BillingCycle.annual:
        return '/año';
    }
  }
}
