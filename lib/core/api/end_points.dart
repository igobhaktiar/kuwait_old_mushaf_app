class EndPoints {
  static const String baseUrl = 'https://quranappapi.qsa.gov.kw/en/api/v1/';
  static const String appLandingPage = 'https://quranapp.qsa.gov.kw/';
  static const String qeraatMp3RemoteFolder =
      "https://cdn.qsa.gov.kw/media/different_words_sound/";
  static const String awsQeraatMp3RemoteFolder =
      "https://d1sc0qtrfa4gsu.cloudfront.net/media/different_words_sound/";
  static const String obtainToken = 'user/obtain-token/';
  static const String quranDefualt = 'quran/quran-default/';
  static const String quranDefualtSingle = 'quran/quran-default/page/';
  static const String quranTen = 'quran/quran-ten/';
  static const String quranTenSingle = 'quran/quran-ten/page/';
  static const String defualtReciterAyahFile = 'quran/default-reciter/sound/';

  static const String getTenReadingsServicesForSinglePage =
      "quran/quran-ten-page-v/3";
  static const externalResources = "quran/external-resources/";
  static const String getLastModifiedContent = "quran/last-modified/";
  static const String reciters = "quran/reciter/";
  static const String settings = "quran/app-setting/";
  static var recitersMp3RemoteFolder =
      "https://cdn.qsa.gov.kw/media/reciter_sound";
  static var tafseerAlmannan = "quran/tafseer-mannan/";

  //* mehtods
  static String getBaseUrlAccordingToBuildTarget(BuildTarget buildTarget) {
    String tempString = '';
    switch (buildTarget) {
      case BuildTarget.AWS_DEV:
        tempString = "https://awsdev-quranapp.qsa.gov.kw/en/api/v1/";
        break;
      case BuildTarget.PRODUCTION:
        tempString = "https://quranappapi.qsa.gov.kw/en/api/v1/";
        break;
      default:
        tempString = "https://quranappapi.qsa.gov.kw/en/api/v1/";
        break;
    }
    return tempString;
  }

  String getqeraatMp3RemoteFolderAccordingToBuildTarget(
      BuildTarget buildTarget) {
    String tempString = '';
    switch (buildTarget) {
      case BuildTarget.AWS_DEV:
        tempString =
            "https://d1sc0qtrfa4gsu.cloudfront.net/media/different_words_sound/";
        break;
      case BuildTarget.PRODUCTION:
        tempString = "https://cdn.qsa.gov.kw/media/different_words_sound/";
        break;
      default:
        tempString = "https://cdn.qsa.gov.kw/media/different_words_sound/";
        break;
    }
    return tempString;
  }

  static String getBlackPagePathAccordingToBuildTarget(
      {required BuildTarget buildTarget}) {
    String tempString = '';
    switch (buildTarget) {
      case BuildTarget.AWS_DEV:
        tempString =
            "https://d1sc0qtrfa4gsu.cloudfront.net/media/quran_default_img";
        break;
      case BuildTarget.PRODUCTION:
        tempString = "https://cdn.qsa.gov.kw/media/quran_default_img";
        break;
      default:
        tempString =
            "https://d1sc0qtrfa4gsu.cloudfront.net/media/quran_default_img";
        break;
    }
    return tempString;
  }
}

enum BuildTarget { AWS_DEV, PRODUCTION, KUWAIT_NET }
