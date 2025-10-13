// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      currency: fields[3] as String,
      category: fields[4] as String,
      colorValue: fields[5] as int,
      billingDate: fields[6] as DateTime,
      billingCycle: fields[7] as BillingCycle,
      reminderEnabled: fields[8] as bool,
      reminderDaysBefore: fields[9] as int,
      notes: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      calendarEventId: fields[12] as String?,
      calendarId: fields[13] as String?,
      lastPaymentDate: fields[14] as DateTime?,
      reminderHour: fields[15] as int?,
      reminderMinute: fields[16] as int?,
      reminderAllDay: fields[17] as bool,
      status: fields[18] as SubscriptionStatus,
      subscriptionEndDate: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.billingDate)
      ..writeByte(7)
      ..write(obj.billingCycle)
      ..writeByte(8)
      ..write(obj.reminderEnabled)
      ..writeByte(9)
      ..write(obj.reminderDaysBefore)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.calendarEventId)
      ..writeByte(13)
      ..write(obj.calendarId)
      ..writeByte(14)
      ..write(obj.lastPaymentDate)
      ..writeByte(15)
      ..write(obj.reminderHour)
      ..writeByte(16)
      ..write(obj.reminderMinute)
      ..writeByte(17)
      ..write(obj.reminderAllDay)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.subscriptionEndDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionStatusAdapter extends TypeAdapter<SubscriptionStatus> {
  @override
  final int typeId = 2;

  @override
  SubscriptionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionStatus.active;
      case 1:
        return SubscriptionStatus.paused;
      case 2:
        return SubscriptionStatus.canceled;
      default:
        return SubscriptionStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionStatus obj) {
    switch (obj) {
      case SubscriptionStatus.active:
        writer.writeByte(0);
        break;
      case SubscriptionStatus.paused:
        writer.writeByte(1);
        break;
      case SubscriptionStatus.canceled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillingCycleAdapter extends TypeAdapter<BillingCycle> {
  @override
  final int typeId = 1;

  @override
  BillingCycle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillingCycle.monthly;
      case 1:
        return BillingCycle.quarterly;
      case 2:
        return BillingCycle.semiannual;
      case 3:
        return BillingCycle.annual;
      default:
        return BillingCycle.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, BillingCycle obj) {
    switch (obj) {
      case BillingCycle.monthly:
        writer.writeByte(0);
        break;
      case BillingCycle.quarterly:
        writer.writeByte(1);
        break;
      case BillingCycle.semiannual:
        writer.writeByte(2);
        break;
      case BillingCycle.annual:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
