// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatmah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KhatmahModelAdapter extends TypeAdapter<KhatmahModel> {
  @override
  final int typeId = 2;

  @override
  KhatmahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmahModel(
      id: fields[0] as int,
      title: fields[1] as String,
      dateCreated: fields[2] as DateTime,
      totalAwradCount: fields[3] as int,
      completedAwradCount: fields[4] as int,
      notificationStatus: fields[5] as bool,
      timeForDailyWerdNotification: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KhatmahModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateCreated)
      ..writeByte(3)
      ..write(obj.totalAwradCount)
      ..writeByte(4)
      ..write(obj.completedAwradCount)
      ..writeByte(5)
      ..write(obj.notificationStatus)
      ..writeByte(6)
      ..write(obj.timeForDailyWerdNotification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WerdModelAdapter extends TypeAdapter<WerdModel> {
  @override
  final int typeId = 3;

  @override
  WerdModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WerdModel(
      id: fields[0] as int,
      fromPage: fields[7] as int,
      toPage: fields[8] as int,
      fromSurahArabic: fields[1] as String,
      toSurahArabic: fields[3] as String,
      fromAyah: fields[5] as int,
      toAyah: fields[6] as int,
      isCompleted: fields[9] as bool,
      fromSurahEnglish: fields[2] as String,
      toSurahEnglish: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WerdModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromSurahArabic)
      ..writeByte(2)
      ..write(obj.fromSurahEnglish)
      ..writeByte(3)
      ..write(obj.toSurahArabic)
      ..writeByte(4)
      ..write(obj.toSurahEnglish)
      ..writeByte(5)
      ..write(obj.fromAyah)
      ..writeByte(6)
      ..write(obj.toAyah)
      ..writeByte(7)
      ..write(obj.fromPage)
      ..writeByte(8)
      ..write(obj.toPage)
      ..writeByte(9)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WerdModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
