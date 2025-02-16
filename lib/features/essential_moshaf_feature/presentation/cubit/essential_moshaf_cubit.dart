import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/data_sources/all_ayat_with_tashkeel.dart';
import 'package:quran_app/core/data_sources/all_ayat_without_tashkeel.dart'
    show allAyatWithoutTashkelMapList;
import 'package:quran_app/core/data_sources/hizb_fihris.dart'
    show hizbFihrisJson;
import 'package:quran_app/core/data_sources/juz_fihris.dart'
    show ajzaaFihrisJson;
import 'package:quran_app/core/data_sources/swar_fihris.dart'
    show swarFihrisJson;
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/favourites_screen.dart'
    show FavouritesScreen;
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart'
    show AyahModel;
import 'package:quran_app/features/essential_moshaf_feature/data/models/fihris_models.dart'
    show HizbFihrisModel, JuzFihrisModel, SurahFihrisModel;
import 'package:quran_app/features/externalLibraries/presentation/screens/external_libraries_screen.dart';
import 'package:quran_app/features/khatmat/presentation/screens/khatmat/khatmat_screen.dart'
    show KhatmatScreen;
import 'package:quran_app/features/main/presentation/screens/quran_fihris_screen.dart'
    show FihrisScreen;
import 'package:quran_app/features/main/presentation/screens/settings_screens/settings_screen.dart'
    show SettingScreen;
import 'package:shared_preferences/shared_preferences.dart';

part 'essential_moshaf_state.dart';

class EssentialMoshafCubit extends Cubit<EssentialMoshafState> {
  EssentialMoshafCubit({required this.sharedPreferences})
      : super(EssentialMoshafInitial());
  final SharedPreferences sharedPreferences;

  List<SurahFihrisModel> get swarListForFihris =>
      swarFihrisJson.map((e) => SurahFihrisModel.fromJson(e)).toList();
  List<JuzFihrisModel> get ajzaaListForFihris =>
      ajzaaFihrisJson.map((e) => JuzFihrisModel.fromJson(e)).toList();
  List<HizbFihrisModel> get ahzabListForFihris =>
      hizbFihrisJson.map((e) => HizbFihrisModel.fromJson(e)).toList();
  List<AyahModel> get allAyat => allAyatWithoutTashkelMapList
      .map((ayah) => AyahModel.fromJson(ayah))
      .toList();
  List<AyahModel> get allAyatWithTashkeelList =>
      allAyatWithTashkeel.map((ayah) => AyahModel.fromJson(ayah)).toList();
  int get lastAccessedPage =>
      sharedPreferences.getInt(AppStrings.lastAccessedPageKey) ?? 0;

  static EssentialMoshafCubit get(context) => BlocProvider.of(context);

  //* VARIABLE MEMBERS
  PageController moshafPageController = PageController();
  ScrollController navigateBySurahController = ScrollController();
  ScrollController navigateByPageNumberController = ScrollController();
  ScrollController navigateByQuarterController = ScrollController();
  ScrollController quranPageLandscapeVerticalScrollController =
      ScrollController();

  bool isToShowAppBar = false;
  bool isToShowBottomSheet = false;
  bool isToShowBottomSheetContentDetails = true;
  int currentBottomSheetViewIndex = 0;
  Widget currentBottomSheetView = const SizedBox();
  bool isToShowTopBottomNavListViews = false;
  bool isShowNavigateByPage = false;

  int currentPage = 0;
  int currentSurahInt = 1;
  int currentQuarter = 1;
  int currentHizb = 1;
  int currentJuz = 1;
  String currentJuzText = "الجزء الأول";
  bool isShowFihris = false;
  Orientation currentOrientation = Orientation.portrait;

  static const double surahWidgetWidth = 118.22;
  static const double pageNumberWidgetWidth = 64;
  late SurahFihrisModel currentSurahModel;
  late AyahModel firstAyahInCurrentPage;
  int homeViewBottomNavIndex = 0;

  List<Widget> mainViewbottomScreens = [
    const FihrisScreen(),
    const KhatmatScreen(),
    const FavouritesScreen(),
    const ExternalLibrariesScreen(),
    const SettingScreen(),
  ];

  MoshafTypes currentMoshafType = MoshafTypes.ORDINARY;

  List<TabItem> currentQeraatBottomSheetItems = [];

  String currentLocale = AppStrings.arabicCode;
  int currentThemeId = 0;

  //* METHOD MEMBERS

  ///* Method to initialize the read mode[ordinary-10readings] and corresponding dependencies
  void init() async {
    listenToScrollControllers();
    currentSurahModel = swarListForFihris.first;
    firstAyahInCurrentPage = allAyat.first;
    Future.delayed(const Duration(milliseconds: 100),
        () => scheduleMicrotask(() => navigateToLastAccessedPage()));
  }

  ///* Method to listen to the page controller when the cubit initializes [required for proper implementation]
  void listenToScrollControllers() {
    moshafPageController.addListener(() {});
    navigateBySurahController.addListener(() {});
    navigateByPageNumberController.addListener(() {});
    navigateByQuarterController.addListener(() {});
    quranPageLandscapeVerticalScrollController.addListener(() {});
  }

  ///* Method to toggle the Root view that contains [Fihris,khatmat,bookmarks,favourites,settings]
  void toggleRootView() {
    isShowFihris = !isShowFihris;
    if (isShowFihris) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }
    emit(ToggleRootView(isShowFihris));
    FirebaseAnalytics.instance.logScreenView(
        screenName: isShowFihris
            ? AppStrings.analytcsScreenMenuScreens
            : isInTenReadingsMode()
                ? AppStrings.analytcsScreenTenReadingsScreen
                : AppStrings.analytcsScreenMoshafScreen);
  }

  ///* Method to toggle the state of showing or hiding the flying layes like [appbar and bottom options]
  void toggleShowflyingLayers() {
    if (isToShowTopBottomNavListViews) {
      toggleTopBottomNavListViews();
    }

    if (!isToShowBottomSheet) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: isToShowAppBar ? SystemUiOverlay.values : []);
    }

    if (isToShowBottomSheet && !isToShowAppBar) {
      hideBottomSheetSections();
      return;
    }
    if (!isToShowBottomSheet) {
      showBottomSheetSections();
    } else {
      hideBottomSheetSections();
    }
    isToShowAppBar = !isToShowAppBar;

    // emit(FlyingWidgetsVisibleState(isToShowAppBar));

    log("isToShowFlyingLayers=$isToShowAppBar");
  }

  showFlyingLayers() {
    isToShowAppBar = true;

    emit(FlyingWidgetsVisibleState(isToShowAppBar));
  }

  hideFlyingLayers() {
    emit(FlyingWidgetsVisibleState(false));
    isToShowAppBar = false;
    isToShowBottomSheet = false;

    log("isToShowFlyingLayers=$isToShowAppBar");
  }

  showBottomSheetSections() {
    isToShowBottomSheet = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    emit(FlyingWidgetsVisibleState(true));
  }

  hideBottomSheetSections() {
    isToShowBottomSheet = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    emit(BottomSheetVisibleState(false));
  }

  toggleBottomSheetSection() {
    if (isToShowBottomSheet == false) {
      showBottomSheetSections();
    } else {
      hideBottomSheetSections();
    }
  }

  ///* Method to toggle the state of showing or hiding the bottom sheet the contains views like  [التفسير،القراءات، الاستماع...إلخ]
  toggleShowHideBottomSheetContentDetails() {
    emit(EssentialMoshafInitial());
    isToShowBottomSheetContentDetails = !isToShowBottomSheetContentDetails;
    if (isToShowAppBar) {
      emit(FlyingWidgetsVisibleState(isToShowAppBar));
    }
    log("isToShowFlyingLayers=$isToShowAppBar");
  }

  ///* Method to toggle the state of showing or hiding the Navigation listViews  [swar and pages navigations]
  void toggleTopBottomNavListViews() {
    if (isToShowAppBar) {
      return;
    }
    isToShowTopBottomNavListViews = !isToShowTopBottomNavListViews;
    if (isToShowTopBottomNavListViews) {
      emit(ShowNavigationListViewsState(isToShowTopBottomNavListViews));
    } else {
      emit(ShowNavigationListViewsState(isToShowTopBottomNavListViews));
    }
    log("isToShowFlyingLayers=$isToShowAppBar");
  }

  ///* Method to change current surah, typically used in the reading page at the top
  void navigateToPage(int newPageNumber, {bool jumpToPage = true}) {
    if (currentPage == newPageNumber - 1) return;
    emit(EssentialMoshafInitial());
    setLastPage(newPageNumber - 1);
    if (!isToShowTopBottomNavListViews) {
      isShowNavigateByPage = true;
    }
    currentPage = newPageNumber - 1;
    firstAyahInCurrentPage = allAyat
        .where((ayah) => ayah.page == math.min(currentPage + 1, 604))
        .toList()
        .first;

    //detect current hizb and current juz.
    currentQuarter = allAyat
        .where((ayah) => ayah.page == math.min(currentPage + 1, 604))
        .toList()
        .map((ayah) => ayah.hizbQuarter as int)
        .toList()
        .last;

    currentQuarter = math.min(currentQuarter, 240);
    debugPrint("currentQuarter=$currentQuarter");

    bool isTheSameHizb = (currentQuarter % 4 == 0);
    currentHizb = isTheSameHizb ? currentQuarter ~/ 4 : currentQuarter ~/ 4 + 1;
    currentHizb = math.min(currentHizb, 60);
    debugPrint("currentHizb: $currentHizb");

    final isTheSameJuz = currentHizb % 2 == 0;
    currentJuz = isTheSameJuz ? currentHizb ~/ 2 : currentHizb ~/ 2 + 1;
    currentJuz = math.min(currentJuz, 30);
    debugPrint("currentJuz: $currentJuz");

    currentJuzText = ajzaaListForFihris
        .where((element) => element.number == currentJuz)
        .toList()
        .first
        .name
        .toString();
    debugPrint("currentJuz: $currentJuz");

    // let this be induced from the [pageNumber] value.

    final swarInNewPageNumber = swarListForFihris
        .where((surah) => surah.page! == newPageNumber)
        .toList();
    final swarBeforeNewPageNumber = swarListForFihris
        .where((surah) => surah.page! <= newPageNumber)
        .toList();

    currentSurahModel = swarInNewPageNumber.isNotEmpty
        ? swarInNewPageNumber.first
        : swarBeforeNewPageNumber.isNotEmpty
            ? swarBeforeNewPageNumber.last
            : swarListForFihris.first;
    currentSurahInt = currentSurahModel.number!;

    // when we know the number of the surah and the width of surah name widget we can jump to it [done]
    final pixelsToScrollSurahs = (currentSurahInt - 1) * surahWidgetWidth;
    if (navigateBySurahController.hasClients) {
      navigateBySurahController.animateTo(pixelsToScrollSurahs,
          duration: AppConstants.enteringAnimationDuration,
          curve: Curves.easeOut);
    }
    // when we know the page number and the width of pageNuber widget we can jump to it [done]
    // double pixelsToScrollPages =
    //     (currentPage.isOdd ? currentPage - 2 : currentPage - 2) *
    //         pageNumberWidgetWidth *
    //         22;
    if (navigateByPageNumberController.hasClients) {
      navigateByPageNumberController.animateTo(
          (navigateByPageNumberController.position.maxScrollExtent /
                      301 *
                      currentPage +
                  44) /
              2,
          duration: AppConstants.enteringAnimationDuration,
          curve: Curves.easeOut);
    }
    if (quranPageLandscapeVerticalScrollController.hasClients) {
      quranPageLandscapeVerticalScrollController.jumpTo(
        0.0,
      );
    }
    emit(
      ChangeCurrentPage(currentPage: currentPage, newQuarter: currentQuarter),
    );

    log("navigateToPage: currentPage=$currentPage");
    log("navigateToPage: currentSurahModel=${currentSurahModel.toJson()}");

    if (jumpToPage) {
      if (moshafPageController.hasClients) {
        moshafPageController.jumpToPage(currentPage);
        log("moshafPageController=${moshafPageController.page}");
      }
    }

    emit(ChangeCurrentSurah(currentSurah: currentSurahInt));

    log("changeCurrentSurah=$currentSurahInt");
  }

  ///* method to navigate by hizb quarter
  void navigateToQuarter(int newQuarter) {
    int quarterFirstPage = allAyat
        .where((ayah) => ayah.hizbQuarter == newQuarter)
        .toList()
        .first
        .page!;
    navigateToPage(quarterFirstPage);
  }

  void hidePagesPopUp() {
    isShowNavigateByPage = false;
    emit(HidePagesPopUpState());
  }

  ///* 0=>Fihris,
  void changeBottomNavBar(int index) {
    emit(EssentialMoshafInitial());
    homeViewBottomNavIndex = index;
    FirebaseAnalytics.instance
        .logScreenView(screenName: mainViewbottomScreens[index].toString());

    emit(ChangeBottomNavState());
  }

  ///* Method to switch between the three supported themes [light_white,light_gold,night_mode]
  void changeTheme(int themeId) {
    emit(EssentialMoshafInitial());

    currentThemeId = themeId == 1 ? 3 : themeId;
    log("currentThemeId=$currentThemeId");

    emit(ChangecheckButtonState());
  }

  void changeSwitch(bool state, bool isSwitch) {
    emit(EssentialMoshafInitial());

    isSwitch = state;

    emit(ChangecheckButtonState());
  }

  bool stateIcon = false;
  changeCollapseIcon() {
    emit(EssentialMoshafInitial());

    stateIcon = !stateIcon;

    emit(ChangeCollapseIconState());
  }

  void changeMoshafType(MoshafTypes type) {
    currentMoshafType = type;
    emit(ChangeMoshafType(type));
  }

  void changeMoshafTypeToOrdinary() {
    currentMoshafType = MoshafTypes.ORDINARY;
    emit(const ChangeMoshafType(MoshafTypes.ORDINARY));
  }

  void changeBottomNavBarToKhatmatWithPayload(String? payload) {
    changeBottomNavBar(1);
    emit(SelectedKhatmahPayloadFromNotification(payload: payload!));
    emit(EssentialMoshafInitial());
  }

  void togglePageNavigationOrFlying() {
    if (isShowNavigateByPage) {
      hidePagesPopUp();
      if (isToShowBottomSheet) {
        hideBottomSheetSections();
        hideFlyingLayers();
      }
      return;
    }
    toggleShowflyingLayers();
  }

  void changeOrientaion(Orientation orientation) {
    if (currentOrientation != orientation) {
      currentOrientation = orientation;
      navigateToPage(currentPage);
      emit(OrientationChanged(orientation));
    }
  }

  int? getSurahNumberFromItsName(String surahNameEnglish) {
    var resultList = swarListForFihris
        .where((surahInFihris) => surahInFihris.englishName == surahNameEnglish)
        .toList();
    if (resultList.isNotEmpty) {
      return resultList.first.number;
    } else {
      return null;
    }
  }

  setLastPage(int newPage) {
    sharedPreferences.setInt(AppStrings.lastAccessedPageKey, newPage);
  }

  void navigateToLastAccessedPage() {
    navigateToPage(lastAccessedPage + 1);
  }

  void navigateToNextPage() {
    navigateToPage(currentPage + 2);
    hidePagesPopUp();
    emit(StartListeningToTheNewPage());
  }

  bool isInTenReadingsMode() {
    return currentMoshafType == MoshafTypes.TEN_READINGS;
  }

  changeFihrisView(int viewIndex) {
    emit(ChangeFihrisIndex(viewIndex: viewIndex));
  }
}
