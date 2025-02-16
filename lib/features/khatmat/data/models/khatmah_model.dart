import 'package:hive/hive.dart';

part 'khatmah_model.g.dart';

@HiveType(typeId: 2)
class KhatmahModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime dateCreated;
  @HiveField(3)
  int totalAwradCount;
  @HiveField(4)
  int completedAwradCount;
  @HiveField(5)
  bool notificationStatus;
  @HiveField(6)
  String? timeForDailyWerdNotification;

  KhatmahModel({
    required this.id,
    required this.title,
    required this.dateCreated,
    required this.totalAwradCount,
    required this.completedAwradCount,
    required this.notificationStatus,
    this.timeForDailyWerdNotification,
  });
}

@HiveType(typeId: 3)
class WerdModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String fromSurahArabic;
  @HiveField(2)
  String fromSurahEnglish;
  @HiveField(3)
  String toSurahArabic;
  @HiveField(4)
  String toSurahEnglish;
  @HiveField(5)
  int fromAyah;
  @HiveField(6)
  int toAyah;
  @HiveField(7)
  int fromPage;
  @HiveField(8)
  int toPage;
  @HiveField(9)
  bool isCompleted;

  WerdModel({
    required this.id,
    required this.fromPage,
    required this.toPage,
    required this.fromSurahArabic,
    required this.toSurahArabic,
    required this.fromAyah,
    required this.toAyah,
    required this.isCompleted,
    required this.fromSurahEnglish,
    required this.toSurahEnglish,
  });
}
