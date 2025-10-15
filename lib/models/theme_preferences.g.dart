// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemePreferencesAdapter extends TypeAdapter<ThemePreferences> {
  @override
  final int typeId = 4;

  @override
  ThemePreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemePreferences(
      mode: fields[0] as ThemeMode,
      darkStartHour: fields[1] as int,
      darkStartMinute: fields[2] as int,
      darkEndHour: fields[3] as int,
      darkEndMinute: fields[4] as int,
      colorScheme: fields[5] as AppColorScheme? ?? AppColorScheme.sakuraPink,
      useDynamicColor: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ThemePreferences obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.mode)
      ..writeByte(1)
      ..write(obj.darkStartHour)
      ..writeByte(2)
      ..write(obj.darkStartMinute)
      ..writeByte(3)
      ..write(obj.darkEndHour)
      ..writeByte(4)
      ..write(obj.darkEndMinute)
      ..writeByte(5)
      ..write(obj.colorScheme)
      ..writeByte(6)
      ..write(obj.useDynamicColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 3;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      case 3:
        return ThemeMode.scheduled;
      case 4:
        return ThemeMode.auto;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
      case ThemeMode.scheduled:
        writer.writeByte(3);
        break;
      case ThemeMode.auto:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppColorSchemeAdapter extends TypeAdapter<AppColorScheme> {
  @override
  final int typeId = 5;

  @override
  AppColorScheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppColorScheme.sakuraPink;
      case 1:
        return AppColorScheme.oceanBlue;
      case 2:
        return AppColorScheme.forestGreen;
      case 3:
        return AppColorScheme.sunsetOrange;
      case 4:
        return AppColorScheme.lavenderDream;
      case 5:
        return AppColorScheme.mintFresh;
      default:
        return AppColorScheme.sakuraPink;
    }
  }

  @override
  void write(BinaryWriter writer, AppColorScheme obj) {
    switch (obj) {
      case AppColorScheme.sakuraPink:
        writer.writeByte(0);
        break;
      case AppColorScheme.oceanBlue:
        writer.writeByte(1);
        break;
      case AppColorScheme.forestGreen:
        writer.writeByte(2);
        break;
      case AppColorScheme.sunsetOrange:
        writer.writeByte(3);
        break;
      case AppColorScheme.lavenderDream:
        writer.writeByte(4);
        break;
      case AppColorScheme.mintFresh:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColorSchemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
