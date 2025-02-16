import 'package:hive/hive.dart';
part 'bookmark_model.g.dart';
// todo: runthis command to generate the type adaper
// flutter packages pub run build_runner build

@HiveType(typeId: 1)
class BookmarkModel {
  @HiveField(0)
  int page;
  @HiveField(1)
  String surahNameArabic;
  @HiveField(2)
  String surahNameEnglish;
  @HiveField(3)
  int ayah;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  String ayahText;
  @HiveField(6)
  String bookmarkTitle;

  BookmarkModel(
      {required this.page,
      required this.surahNameArabic,
      required this.surahNameEnglish,
      required this.ayah,
      required this.ayahText,
      required this.bookmarkTitle,
      required this.date});
}
