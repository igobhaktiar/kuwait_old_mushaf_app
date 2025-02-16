import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, Cubit;
import 'package:hive_flutter/adapters.dart';
import 'package:quran_app/core/utils/app_strings.dart' show AppStrings;
import 'package:quran_app/features/bookmarks/data/models/bookmark_model.dart'
    show BookmarkModel;
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart'
    show AyahModel;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

part 'bookmarks_state.dart';

class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit({required this.sharedPreferences}) : super(BookmarksInitial());
  static BookmarksCubit get(context) => BlocProvider.of(context);

  late final Box bookmarksBox;
  late final Box favouritesBox;
  late ValueListenable<Box> bookmarksBoxListenable;
  late ValueListenable<Box> favouritesBoxListenable;
  final SharedPreferences sharedPreferences;

  bool get showBookmarksOnStartEnabled =>
      sharedPreferences.getBool(AppStrings.showBookmarksOnStartEnabledKey) ??
      false;

  Future<void> init() async {
    bookmarksBox = Hive.box(AppStrings.bookmarksBox);
    bookmarksBoxListenable = bookmarksBox.listenable();
    favouritesBox = Hive.box(AppStrings.favouritesBox);
    favouritesBoxListenable = favouritesBox.listenable();
  }

  Future<void> addBookmark({required title, required AyahModel ayah}) async {
    await bookmarksBox.add(BookmarkModel(
        ayahText: ayah.text.toString(),
        bookmarkTitle: title,
        page: ayah.page!,
        surahNameArabic: ayah.surah.toString(),
        surahNameEnglish: ayah.surahEnglish.toString(),
        ayah: ayah.numberInSurah!,
        date: DateTime.now()));
    FirebaseAnalytics.instance.logEvent(
        name: AppStrings.analytcsEventAddBookmark,
        parameters: {'ayah': "${ayah.surah}-${ayah.numberInSurah}"});
  }

  Future<void> deleteBookmarkAt(int index) async =>
      await bookmarksBox.deleteAt(index);

  Future<void> clearAllBookmarks() async => bookmarksBox.clear();

  Future<void> addFavourite({required AyahModel ayah}) async {
    await favouritesBox.add(BookmarkModel(
        ayahText: ayah.text.toString(),
        bookmarkTitle: "fav",
        page: ayah.page!,
        surahNameArabic: ayah.surah.toString(),
        surahNameEnglish: ayah.surahEnglish.toString(),
        ayah: ayah.numberInSurah!,
        date: DateTime.now()));
    FirebaseAnalytics.instance.logEvent(
        name: AppStrings.analytcsEventAddFavourite,
        parameters: {'ayah': "${ayah.surah}-${ayah.numberInSurah}"});
  }

  Future<void> deleteFavouriteAt(int index) async =>
      await favouritesBox.deleteAt(index);

  Future<void> clearAllFavourites() async => await favouritesBox.clear();

  Future<void> setShowBookmarksOnStart(bool newValue) async =>
      await sharedPreferences.setBool(
          AppStrings.showBookmarksOnStartEnabledKey, newValue);

  bool checkToShowBookmarksOnStart() {
    if (bookmarksBox.isNotEmpty && showBookmarksOnStartEnabled) {
      return true;
    }
    return false;
  }
}
