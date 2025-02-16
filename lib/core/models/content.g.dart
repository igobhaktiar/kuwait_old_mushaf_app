// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentAdapter extends TypeAdapter<Content> {
  @override
  final int typeId = 91;

  @override
  Content read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Content(
      type: fields[0] as String,
      id: fields[1] as String,
      value: fields[2] as ContentValue,
    );
  }

  @override
  void write(BinaryWriter writer, Content obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
