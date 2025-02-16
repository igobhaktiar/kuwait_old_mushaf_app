// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_value.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentValueAdapter extends TypeAdapter<ContentValue> {
  @override
  final int typeId = 0;

  @override
  ContentValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentValue(
      title: fields[0] as String,
      body: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContentValue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
