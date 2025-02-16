//*Flutter AssetsClassGenerator script.
//* Created by Eng. Mohammed Salem
//* Contact me at moahmedsalem51@gmail.com
//* GitHub: https://github.com/mohammedsalem97

const String iconsAssetsPath = 'assets/icons';
const String imagesAssetsPath = 'assets/imgs';
const String blackImgsAssetsPath = 'assets/all_black_pages';
const String surasNamesAssetsPath = 'assets/suras_names';
const String ahzabNamesAssetsPath = 'assets/ahzab_names';
const String ajzaaNamesAssetsPath = 'assets/ajzaa_names';
const String coloredAssetsPath = 'assets/colored';
const String readingsJsonAssetsPath = 'assets/readings_json';
const String soundsAssetsPath = 'assets/sounds';

class AppAssets {
  static String getSurahName(int surahNumber) {
    return "$surasNamesAssetsPath/$surahNumber.svg";
  }

  static String getHizbName(int hizbNumber) {
    return "$ahzabNamesAssetsPath/$hizbNumber.svg";
  }

  static String getJuzName(int juzNumber) {
    return "$ajzaaNamesAssetsPath/$juzNumber.svg";
  }

//* png files.
  static const String cover = "$imagesAssetsPath/cover.png";
  static const String onboarding_0 = "$imagesAssetsPath/onboarding_0.png";
  static const String onboarding_1 = "$imagesAssetsPath/onboarding_1.png";
  static const String onboarding_2 = "$imagesAssetsPath/onboarding_2.png";
  static const String onboarding_3 = "$imagesAssetsPath/onboarding_3.png";
  static const String splash = "$imagesAssetsPath/splash.png";
  static const String sheikh = "$imagesAssetsPath/sheikh.png";
  static const String sheikh1 = "$imagesAssetsPath/badr_al_ali.png";
  static const String sheikh2 = "$imagesAssetsPath/sodais.png";
  static const String sheikh3 = "$imagesAssetsPath/sheikh.png";
  static const String sheikh4 = "$imagesAssetsPath/shreem.png";
  static const String hosary = "$imagesAssetsPath/hosary.png";
  static const String minshawy = "$imagesAssetsPath/minshawy.png";
  static const String pattern = "$imagesAssetsPath/pattern.png";
  static const String patternBgWithTextBehind =
      "$imagesAssetsPath/pattern-bg-with-text-behind.png";
  static const String appIcon = "$imagesAssetsPath/app-icon.png";

//* svg files.
  static const String currentJuz = "$iconsAssetsPath/current_juz.svg";
  static const String currentQuarterFrame =
      "$iconsAssetsPath/current_quarter_frame.svg";
  static const String quarter_1 = "$iconsAssetsPath/quarter_1.svg";
  static const String quarter_2 = "$iconsAssetsPath/quarter_2.svg";
  static const String quarter_3 = "$iconsAssetsPath/quarter_3.svg";
  static const String quarter_4 = "$iconsAssetsPath/quarter_4.svg";
  static const String juzIcon = "$iconsAssetsPath/juz_icon.svg";

  static const String onBoardingBtn1 = "$iconsAssetsPath/onboarding_btn_1.svg";
  static const String backArrow = "$iconsAssetsPath/arrow-forward-ios.svg";
  static const String onBoardingBtn2 = "$iconsAssetsPath/onboarding_btn_2.svg";
  static const String onBoardingBtn3 = "$iconsAssetsPath/onboarding_btn_3.svg";
  static const String onBoardingBtn4 = "$iconsAssetsPath/onboarding_btn_4.svg";
  static const String khatmah = "$iconsAssetsPath/Khatmah.svg";
  static const String search = "$iconsAssetsPath/Search.svg";
  static const String noSearchResultsIcon =
      "$iconsAssetsPath/no_search_reults_icon.svg";
  static const String bookmarkBtn = "$iconsAssetsPath/bookmark-btn.svg";
  static const String bookmarkFilled = "$iconsAssetsPath/bookmark-filled.svg";
  static const String bookmarkOutlined =
      "$iconsAssetsPath/bookmark-outlined.svg";
  static const String brightnessHigh = "$iconsAssetsPath/brightness-high.svg";
  static const String brightnessLow = "$iconsAssetsPath/brightness-low.svg";
  static const String brightness_2 = "$iconsAssetsPath/brightness_2.svg";
  static const String checkBlack = "$iconsAssetsPath/check-black.svg";
  static const String checkGreen = "$iconsAssetsPath/check-green.svg";
  static const String checkMark = "$iconsAssetsPath/check-mark.svg";
  static const String darkMode = "$iconsAssetsPath/dark-mode.svg";
  static const String delete = "$iconsAssetsPath/delete.svg";
  static const String document = "$iconsAssetsPath/document.svg";
  static const String downloadActive = "$iconsAssetsPath/download-active.svg";
  static const String downloadDisabled =
      "$iconsAssetsPath/download-disabled.svg";
  static const String fihris = "$iconsAssetsPath/fihris.svg";

  static const String gear = "$iconsAssetsPath/gear.svg";
  static const String listen = "$iconsAssetsPath/listen.svg";
  static const String listenBorder = "$iconsAssetsPath/listen-border.svg";
  static const String listenBorderDark =
      "$iconsAssetsPath/listen-border-dark.svg";
  static const String tafseerActive = "$iconsAssetsPath/tafseer-active.svg";
  static const String tafseerInactive = "$iconsAssetsPath/tafseer-inactive.svg";
  static const String live = "$iconsAssetsPath/live.svg";
  static const String menuIcon = "$iconsAssetsPath/menu-icon.svg";
  static const String mushafIcon = "$iconsAssetsPath/mushaf-icon.svg";
  static const String next = "$iconsAssetsPath/next.svg";
  static const String outlinePlay = "$iconsAssetsPath/outline-play.svg";
  static const String pageNumberFrame =
      "$iconsAssetsPath/page-number-frame.svg";
  static const String pause = "$iconsAssetsPath/pause.svg";
  static const String play = "$iconsAssetsPath/play.svg";
  static const String prev = "$iconsAssetsPath/prev.svg";
  static const String repeat = "$iconsAssetsPath/repeat.svg";
  static const String set_1 = "$iconsAssetsPath/set-1.svg";
  static const String set_2 = "$iconsAssetsPath/set-2.svg";
  static const String set_3 = "$iconsAssetsPath/set-3.svg";
  static const String set_4 = "$iconsAssetsPath/set-4.svg";
  static const String set_5 = "$iconsAssetsPath/set-5.svg";
  static const String set_6 = "$iconsAssetsPath/set-6.svg";
  static const String set_7 = "$iconsAssetsPath/set-7.svg";
  static const String set_8 = "$iconsAssetsPath/set-8.svg";
  static const String arabicFlag = "$iconsAssetsPath/arabic_flag.svg";
  static const String englishFlag = "$iconsAssetsPath/english_flag.svg";
  static const String englishWord = "$iconsAssetsPath/english_word.svg";
  static const String starFilled = "$iconsAssetsPath/star-filled.svg";
  static const String star = "$iconsAssetsPath/star.svg";
  static const String stop = "$iconsAssetsPath/stop.svg";
  static const String suraNameFrameActive =
      "$iconsAssetsPath/sura-name-frame-active.svg";
  static const String frame = "$iconsAssetsPath/frame.svg";
  static const String pageMetadataFrame =
      "$iconsAssetsPath/page_matadata-frame.svg";
  static const String suraNameFrameDisabled =
      "$iconsAssetsPath/sura-name-frame-disabled.svg";
  static const String suraNumberFrame =
      "$iconsAssetsPath/sura-number-frame.svg";
  static const String suraName = "$surasNamesAssetsPath/3.svg";
  static const String bookmarkActive = "$iconsAssetsPath/bookmark-active.svg";
  static const String currentPage = "$iconsAssetsPath/current-page.svg";
  static const String fihrisActive = "$iconsAssetsPath/fihris-active.svg";
  static const String gearActive = "$iconsAssetsPath/gear-active.svg";
  static const String khatmahActive = "$iconsAssetsPath/khatmah-active.svg";
  static const String nextPage = "$iconsAssetsPath/next-page.svg";
  static const String starActive = "$iconsAssetsPath/star-active.svg";
  static const String shareIcon = "$iconsAssetsPath/share_icon.svg";
  static const String marginsIcon = "$iconsAssetsPath/margins_icon.svg";
  static const String tenReadingsIcon =
      "$iconsAssetsPath/ten-readings-icon.svg";
  static const String booksActive = "$iconsAssetsPath/books_active.svg";
  static const String booksDisabled = "$iconsAssetsPath/books_disabled.svg";
  static const String moshafBadge = "$iconsAssetsPath/moshaf-badge.svg";
  static const String qsaBadge = "$iconsAssetsPath/qsa-badge.svg";
  static const String qsaVertical = "$iconsAssetsPath/qsa-vertical.svg";
  static const String bobyanSponsor = "$iconsAssetsPath/bobyan-sponsor.svg";
  static const String upperDecoration = "$iconsAssetsPath/upper-decoration.svg";
  static const String lowerDecoration = "$iconsAssetsPath/lower-decoration.svg";
  static const String forTenReadings = "$iconsAssetsPath/for-ten-readings.svg";
  static const String hollyQuran = "$iconsAssetsPath/holly-quran.svg";
  static const String qsaLogoWithMoshafSloganForImageShare =
      "$iconsAssetsPath/qsa-logo-with-moshaf-slogan.svg";
}
