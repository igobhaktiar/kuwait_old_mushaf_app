import 'dart:developer';
import 'dart:math' show min, max;

import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data_sources/all_ayat_without_tashkeel.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/encode_arabic_digits.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../../data/models/khatmah_model.dart';

part 'khatmat_state.dart';

class KhatmatCubit extends Cubit<KhatmatState> {
  KhatmatCubit({required this.sharedPreferences}) : super(KhatmatInitial());
  static KhatmatCubit get(context) => BlocProvider.of(context);
  final SharedPreferences sharedPreferences;

  late final Box<KhatmahModel> khatmatBox;
  late ValueListenable<Box> khatmatBoxListenable;
  List<AyahModel> get allAyatWithoutTashkeel =>
      allAyatWithoutTashkelMapList.map((e) => AyahModel.fromJson(e)).toList();

  init() async {
    khatmatBox = Hive.box(AppStrings.khatmatBox);
    khatmatBoxListenable = khatmatBox.listenable();
  }

  addKhatmah({required title, required KhatmahModel khatmah}) async {
    // Storing key-value pair
    khatmatBox.add(khatmah);

    print('bookmark added to box!');
  }

  Future<void> deleteKhatmahAt(int index) async {
    await khatmatBox.deleteAt(index);
  }

  clearAllKhatmat() {
    khatmatBox.clear();
    print("clearAll: box length= ${khatmatBox.length}");
  }

  void createKhatmah({required int days, required String name}) async {
    int werdPagesCount = (604 / days).round();
    Box<WerdModel> awradBox = await Hive.openBox(encodeArabbicCharToEn(name));
    //todo divide the 604 pages into #days number of werds with [werdPagesCount] pages each
    int startPage = 1;
    for (int i = 1; i <= days; i++) {
      int toPage = (startPage + werdPagesCount > 604 || i == days)
          ? 604
          : startPage + werdPagesCount - 1;
      AyahModel fromAyah = allAyatWithoutTashkeel
          .where((ayah) => ayah.page == startPage)
          .toList()
          .first;
      AyahModel toAyah = allAyatWithoutTashkeel
          .where((ayah) => ayah.page == toPage)
          .toList()
          .last;
      awradBox.add(WerdModel(
          id: i,
          fromPage: startPage,
          toPage: toPage,
          fromSurahArabic: fromAyah.surah!,
          fromSurahEnglish: fromAyah.surahEnglish!,
          toSurahArabic: toAyah.surah!,
          toSurahEnglish: toAyah.surahEnglish!,
          fromAyah: fromAyah.numberInSurah!,
          toAyah: toAyah.numberInSurah!,
          isCompleted: false));
      // startPage = toPage + 1;
      startPage = min(toPage + 1, 604);
    }
    khatmatBox
        .add(KhatmahModel(
            id: khatmatBox.length + 1,
            title: name,
            dateCreated: DateTime.now(),
            totalAwradCount: days,
            completedAwradCount: 0,
            notificationStatus: false))
        .then((value) => print("create result $value"));
    FirebaseAnalytics.instance.logEvent(
        name: AppStrings.analytcsEventCreateKhatmah,
        parameters: {'days': days.toString()});
  }

  void deleteKhatmah(KhatmahModel khatmahModel) {
    List<KhatmahModel> existingKhatmatList = khatmatBox.values.toList();
    int indexOfKhatmahToBeDeleted = existingKhatmatList.indexWhere(
        (element) => element.dateCreated == khatmahModel.dateCreated);
    Hive.deleteBoxFromDisk(khatmahModel.title);
    khatmatBox.deleteAt(indexOfKhatmahToBeDeleted);
  }

  void addAcompletedWerd(KhatmahModel currentKhatmah) {
    List<KhatmahModel> availableKhatmatList = khatmatBox.values.toList();
    int indexOfWantedKhatmah = availableKhatmatList.indexWhere(
        (element) => element.dateCreated == currentKhatmah.dateCreated);
    if (availableKhatmatList[indexOfWantedKhatmah].completedAwradCount !=
        availableKhatmatList[indexOfWantedKhatmah].totalAwradCount) {
      currentKhatmah.completedAwradCount += 1;
      khatmatBox.putAt(indexOfWantedKhatmah, currentKhatmah);
      log("completed awrad = ${currentKhatmah.completedAwradCount}");
    }
  }

  void restartKhatmah(KhatmahModel currentKhatmah) {
    List<KhatmahModel> availableKhatmatList = khatmatBox.values.toList();
    int indexOfWantedKhatmah = availableKhatmatList.indexWhere(
        (element) => element.dateCreated == currentKhatmah.dateCreated);
    khatmatBox.putAt(
        indexOfWantedKhatmah, currentKhatmah..completedAwradCount = 0);
    log("khatmah[${currentKhatmah.title}] has been restarted");
    FirebaseAnalytics.instance
        .logEvent(name: AppStrings.analytcsEventKhatmahRestarted);
  }

  void enableNotification(KhatmahModel khatmahToBeToggleNotificatiobnStatus,
      {required bool value, DateTime? time}) {
    int indexOfWantedKhatmah = khatmatBox.values.toList().indexWhere(
        (element) =>
            element.dateCreated ==
            khatmahToBeToggleNotificatiobnStatus.dateCreated);
    khatmatBox.putAt(
        indexOfWantedKhatmah,
        khatmahToBeToggleNotificatiobnStatus
          ..notificationStatus = value
          ..timeForDailyWerdNotification =
              time != null ? "${time.hour}:${time.minute}" : null);
  }

  void disableAllNotifications({required bool value}) {
    khatmatBox.values.toList().forEach((element) {
      khatmatBox.putAt(khatmatBox.values.toList().indexOf(element),
          element..notificationStatus = false);
    });
    // khatmatBox.putAt(indexOfWantedKhatmah,
    //     khatmahToBeToggleNotificatiobnStatus..notificationStatus = false);
  }
}
