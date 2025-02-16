import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quran_app/config/dark_theme.dart';
import 'package:quran_app/config/themes/light_theme.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:quran_app/features/downloader/presentation/cubit/downloader_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/search_cubit.dart';
import 'package:quran_app/features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'package:quran_app/features/khatmat/presentation/cubit/khatmat_cubit.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/splash/presentation/screens/cover_screen.dart';
import 'package:quran_app/features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'injection_container.dart' as di;

import 'features/about_app/presentation/cubit/about_app_cubit.dart';

import 'features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'features/terms_and_conditions/presentation/cubit/terms_and_conditions_cubit.dart';

class MoshafAlqeraatApp extends StatefulWidget {
  const MoshafAlqeraatApp({super.key});

  @override
  State<MoshafAlqeraatApp> createState() => _MoshafAlqeraatAppState();
}

class _MoshafAlqeraatAppState extends State<MoshafAlqeraatApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => di.getItInstance<EssentialMoshafCubit>()),
        BlocProvider(create: (context) => di.getItInstance<LangCubit>()),
        BlocProvider(create: (context) => di.getItInstance<SearchCubit>()),
        BlocProvider(create: (context) => BottomSheetCubit()),
        BlocProvider(create: (context) => di.getItInstance<BookmarksCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<AyatHighlightCubit>()),
        BlocProvider(create: (context) => di.getItInstance<ThemeCubit>()),
        BlocProvider(create: (context) => di.getItInstance<DownloaderCubit>()),
        BlocProvider(create: (context) => di.getItInstance<KhatmatCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<ExternalLibrariesCubit>()),
        BlocProvider(
            create: (context) => di.getItInstance<ListeningCubit>()..init()),
        BlocProvider(create: (context) => di.getItInstance<TenReadingsCubit>()),
        BlocProvider(create: (context) => di.getItInstance<TafseerCubit>()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<AboutAppCubit>()..getContentOfAboutApp()),
        BlocProvider(
            create: (context) => di.getItInstance<TermsAndConditionsCubit>()
              ..getTermsAndConditions()),
        BlocProvider(
            create: (context) =>
                di.getItInstance<PrivacyPolicyCubit>()..getPrivacyPolicy()),
      ],
      child: BlocBuilder<LangCubit, LangState>(
        builder: (context, state) {
          return BlocConsumer<ThemeCubit, ThemeState>(
            listener: (BuildContext context, ThemeState state) {
              if (state.brightness == Brightness.light) {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarColor: AppColors.primary,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarContrastEnforced: true,
                  statusBarBrightness: Brightness.light,
                ));
              } else {
                SystemChrome.setSystemUIOverlayStyle(
                  const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarIconBrightness: Brightness.dark,
                      systemNavigationBarColor: Colors.white
                      // systemNavigationBarContrastEnforced: true,
                      ),
                );
              }
            },
            builder: (BuildContext context, ThemeState themeState) {
              // Control device preview options visiblity, put [!kReleaseMode] to ensure it wonn't render when releaasse mode
              return DevicePreview(
                enabled: false,
                builder: (BuildContext context) => MaterialApp(
                  title: AppStrings.appName,
                  debugShowCheckedModeBanner: false,
                  color: AppColors.primary,
                  builder: DevicePreview.appBuilder,
                  // ignore: deprecated_member_use
                  useInheritedMediaQuery: true,
                  locale: state.locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback:
                      (Locale? locale, Iterable<Locale> supportedLocales) {
                    // Check if the current device locale is supported
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                              locale?.languageCode ||
                          supportedLocale.countryCode == locale?.countryCode) {
                        return supportedLocale;
                      }
                    }
                    // If the locale of the device is not supported, use the first one
                    // from the list (English, in this case).
                    return supportedLocales.first;
                  },
                  theme: appLightTheme(),
                  darkTheme: appDarkTheme(),
                  themeMode: themeState.brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const CoverScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
