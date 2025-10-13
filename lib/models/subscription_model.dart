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
    );
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
