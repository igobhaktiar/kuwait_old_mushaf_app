import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/core/api/dio_consumer.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/features/about_app/about_app_injection_container.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/search_cubit.dart';
import 'package:quran_app/features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/app_interceptors.dart';
import 'core/utils/app_strings.dart';
import 'core/utils/audio_handler.dart';
import 'features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'features/bookmarks/data/models/bookmark_model.dart';
import 'features/bookmarks/presentation/screens/theme_cubit.dart';
import 'features/downloader/presentation/cubit/downloader_cubit.dart';
import 'features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'features/khatmat/data/models/khatmah_model.dart';
import 'features/khatmat/presentation/cubit/khatmat_cubit.dart';
import 'features/listening/presentation/cubit/listening_cubit.dart';
import 'features/privacy_policy/privacy_policy_injection_container.dart';
import 'features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'features/terms_and_conditions/terms_and_conditions_injection_container.dart';

final getItInstance = GetIt.instance;

Future<void> init() async {
  // Inititate Hive boxes
  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkModelAdapter());
  Hive.registerAdapter(KhatmahModelAdapter());
  Hive.registerAdapter(WerdModelAdapter());
  await Hive.openBox(AppStrings.bookmarksBox);
  await Hive.openBox(AppStrings.favouritesBox);
  await Hive.openBox<KhatmahModel>(AppStrings.khatmatBox);

  //* CUBITS
  getItInstance
      .registerFactory<EssentialMoshafCubit>(() => EssentialMoshafCubit(
            sharedPreferences: getItInstance(),
          )..init());
  getItInstance.registerFactory<LangCubit>(
      () => LangCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<SearchCubit>(
      () => SearchCubit(sharedPreferences: getItInstance())..getLastSearch());
  getItInstance.registerFactory<BookmarksCubit>(
      () => BookmarksCubit(sharedPreferences: getItInstance())..init());
  getItInstance
      .registerFactory<AyatHighlightCubit>(() => AyatHighlightCubit()..init());
  getItInstance.registerFactory<ThemeCubit>(
      () => ThemeCubit(sharedPreferences: getItInstance())..init());
  getItInstance.registerFactory<DownloaderCubit>(() => DownloaderCubit(
        dioConsumer: getItInstance(),
        sharedPreferences: getItInstance(),
      ));

  getItInstance.registerFactory<ExternalLibrariesCubit>(() =>
      ExternalLibrariesCubit(
          dioConsumer: getItInstance(),
          internetConnectionChecker: getItInstance())
        ..initExternalLibrariesCubit());

  getItInstance.registerFactory<KhatmatCubit>(
      () => KhatmatCubit(sharedPreferences: getItInstance())..init());

  getItInstance.registerFactory<ListeningCubit>(() => ListeningCubit(
      dioConsumer: getItInstance(),
      playerHandler: getItInstance(),
      player: getItInstance(instanceName: "quranPlayer"),
      sharedPreferences: getItInstance(),
      internetConnectionChecker: getItInstance())
    ..init());

  getItInstance.registerFactory<TenReadingsCubit>(() => TenReadingsCubit(
      dioConsumer: getItInstance(),
      player: getItInstance(instanceName: "tenReadingsPlayer"),
      internetConnectionChecker: getItInstance())
    ..init());

  getItInstance.registerFactory<TafseerCubit>(() => TafseerCubit()..init());

  //* features
  initPrivacyPolicyFeature();
  initTermsAndConditionsFeature();
  initAboutAppFeature();

  //* Core
  getItInstance.registerLazySingleton<DioConsumer>(
      () => DioConsumer(client: getItInstance()));

  //* EXTERNAL
  final BuildTarget buildTarget = BuildTarget.PRODUCTION;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final sharedPreferences = await SharedPreferences.getInstance();
  final player = AudioPlayer();

  final tenReadingsPlayer = AudioPlayer();

  player.playbackEventStream.listen((event) {});

  // final InternetConnectionChecker internetConnectionCheckerInstance =
  //     InternetConnectionChecker.createInstance(addresses: [
  //   AddressCheckOption(uri: Uri(scheme: 'https', host: EndPoints.baseUrl))
  // ]);

  final InternetConnectionChecker internetConnectionCheckerInstance =
      InternetConnectionChecker.createInstance();

  getItInstance.registerLazySingleton(() => buildTarget);
  final appIntercepters = AppIntercepters();
  getItInstance.registerLazySingleton(() => sharedPreferences);
  getItInstance.registerLazySingleton(() => player,
      instanceName: "quranPlayer");
  final playerHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(
          player: getItInstance(instanceName: "quranPlayer")),
      config: const AudioServiceConfig(
        androidNotificationIcon: "drawable/app_icon",
        // androidShowNotificationBadge: fals,
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        notificationColor: AppColors.primary,
        androidNotificationOngoing: true,
      ));
  getItInstance.registerLazySingleton(() => playerHandler);
  getItInstance.registerLazySingleton(() => internetConnectionCheckerInstance);
  getItInstance.registerLazySingleton(() => flutterLocalNotificationsPlugin);

  getItInstance.registerLazySingleton(() => tenReadingsPlayer,
      instanceName: "tenReadingsPlayer");

  getItInstance.registerLazySingleton(() => appIntercepters);
  getItInstance.registerLazySingleton(() => LogInterceptor(
      request: true,
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: true,
      error: true));

  getItInstance.registerLazySingleton(() => Dio());
}
