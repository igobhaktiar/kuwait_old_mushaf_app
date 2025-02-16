// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkModelAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final int typeId = 1;

  @override
  BookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkModel(
      page: fields[0] as int,
      surahNameArabic: fields[1] as String,
      surahNameEnglish: fields[2] as String,
      ayah: fields[3] as int,
      ayahText: fields[5] as String,
      bookmarkTitle: fields[6] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.page)
      ..writeByte(1)
      ..write(obj.surahNameArabic)
      ..writeByte(2)
      ..write(obj.surahNameEnglish)
      ..writeByte(3)
      ..write(obj.ayah)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.ayahText)
      ..writeByte(6)
      ..write(obj.bookmarkTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
