import 'assets_manager.dart';

class AppStrings {
  static bool myDebugMode = false;

  static const appName = "مصحف الكويت";
  // Will change
  static const appUrl = "https://quranapp.qsa.gov.kw/";

  static const uthmanyFontFamily = "Uthmany";
  static const uthmanicAyatNumbersFontFamily = "uthmanicAyatNumbersFont";
  static const loutsFontFamily = "louts-shamy";
  static const cairoFontFamily = "Cairo";
  static const qadiFontFamily = "Qadi";
  static const String uthmanyHafsV20fontFamily = "UthmanicHafs_V20";
  static const String nekhtemfontFamily = "nekhtem";
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String serverFailure = 'Server Failure';
  static const String cacheFailure = 'Cache Failure';
  static const String unexpectedError = 'Unexpected Error';
  static const String englishCode = 'en';
  static const String arabicCode = 'ar';
  static const String savedTheme = 'savedTheme';
  static const String locale = 'locale';
  static const String onBoardingBgPng = "$imagesAssetsPath/onboarding_";
  static const String onBoardingBtnSvg = "$iconsAssetsPath/onboarding_btn_";
  // static const String saved = 'savedTheme';

  //*Hive Boxes
  static const String bookmarksBox = "bookmarksBox";
  static const String favouritesBox = "favouritesBox";
  static const String khatmatBox = "khatmatBox";

  //* SHAREDPREFERENCES KEYS
  static const String savedLocale = "LOCALE";
  static String lastSearch = "LASTSEARCH";

  static const String lastDefaultPageDowloaded = "lastDefaultPageDowloaded";

  static const String besmellah =
      "https://quranapp.mykuwaitnet.net/media/reciter_sound/2/Bader Al Ali/001/001-01.mp3";

  static const String isNewUserKey = "isNewUser";

  static const String lastAccessedPageKey = "lastAccessedPage";

  static const String showBookmarksOnStartEnabledKey =
      "showBookmarksOnStartEnabled";

  static const String savedReciterKey = "savedReciter";

  static const String enablePlayInBackgroundKey = "enablePlayInBackgroundKey";

  //* firebase analytics log strings [screens-events]
  static String analytcsScreenMoshafScreen = "Moshaf Screen";
  static String analytcsScreenTenReadingsScreen = "Ten-readings Moshaf Screen";
  static String analytcsScreenSearchScreen = "Search Screen";
  static String analytcsScreenStorageScreen = "Storage Screen";
  static String analytcsScreenKhatmatScreen = "Khatmat Screen";
  static String analytcsScreenKhatmahDetailsScreen = "Khatmah Details Screen";
  static String analytcsScreenMasa7efLibraryScreen = "Masa7ef LibraryScreen";
  static String analytcsScreenMenuScreens = "Menu Screens";
  static String analytcsEventShiekhFilesDownload = "shiekhFilesDownload";
  static String analytcsEventShiekhFilesDeleted = "shiekhFilesDeleted";
  static String analytcsEventTenReadingsFilesDeleted =
      "ten-ReadingsFilesDeleted";
  static String analytcsEventTenReadingsJuzDownload = "tenReadingsJuzDownload";
  static String analytcsEventAddBookmark = "addBookmark";
  static String analytcsEventAddFavourite = "addFavourite";
  static String analytcsEventDownloadLibraryPDF = "downloadLibraryPDF";
  static String analytcsEventDeleteLibraryPDF = "deleteLibraryPDF";
  static String analytcsEventCreateKhatmah = "createKhatmah";
  static String analytcsEventKhatmahRestarted = "khatmahRestarted";
  static String analytcsEventChangeLanguage = "changeLanguage";
  static String analytcsEventChangeTheme = "changeTheme";
  static String analytcsEventShareAyahImage = "shareAyahImage";
  static String analytcsEventShareAyahText = "shareAyahText";
  static String analytcsEventShowTafseerForAyah = "showTafseerForAyah";
  static String analytcsEventPlayQeraaMp3 = "playQeraaMp3";
  static String analytcsEventUpadteAppFromPopUp = "upadteAppFromPopUp";

  static String getAssetPngBlackPagePath(int pageNumber) {
    String buffer = pageNumber.toString();
    buffer = buffer.length == 1
        ? "Q_00$buffer.png"
        : buffer.length == 2
            ? "Q_0$buffer.png"
            : "Q_$buffer.png";
    return "$blackImgsAssetsPath/$buffer";
  }

  static String encode3DigitFileName(int pageNumber) {
    return "${pageNumber.toString().padLeft(3, '0')}";
  }

  static String getAssetPngBlackPagePath2(int pageNumber) {
    String buffer = pageNumber.toString();
    buffer = buffer.length == 1
        ? "Q_00$buffer.png"
        : buffer.length == 2
        ? "Q_0$buffer.png"
        : "Q_$buffer.png";
    return buffer;
  }

  static String getAssetSvgBlackPagePath(int pageNumber) {
    String buffer = pageNumber.toString();
    buffer = buffer.length == 1
        ? "Q_00$buffer.svg"
        : buffer.length == 2
            ? "Q_0$buffer.svg"
            : "Q_$buffer.svg";
    return "$blackImgsAssetsPath/$buffer";
  }

  static String getColoredImageFileName(int pageNumber) {
    String buffer = pageNumber.toString();
    buffer = buffer.length == 1
        ? "P_00$buffer.png"
        : buffer.length == 2
            ? "P_0$buffer.png"
            : "P_$buffer.png";
    return buffer;
  }

  //* for Authorizing the api to download needed files
  static const String userName = "mob_app";
  static const String password = "Quran@KW@604";
  static const String token = "token";

  //* for storage folders on the device
  static const String defaultPages = "/default_pages/";
  static const String coloredPages = "/colored_pages/";

  static const String knQuran = 'kn_quran_1';
  static const String aboutApp = 'about_app';
  static const String aboutAppBoxKey = 'about_app';
  static const String termsAndConditions = 'terms_condition';
  static const String termsAndConditionsBoxKey = 'terms_condition';
  static const String privacyPolicy = "privacy_policy";
  static const String privacyPolicyBoxKey = "privacy_policy";
}
