import 'dart:developer';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/widgets/saved_bookmarks_dialog.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart' show ChangeCurrentPage, EssentialMoshafCubit, EssentialMoshafState, StartListeningToTheNewPage;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/custom_convex_bottom_sheet.dart' show CustomBottomConvextSheet;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/navigate_hizb.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/navigate_page_number.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/navigate_surah.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/quran_page_navigation.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/top_navigation_bar.dart';
import 'package:quran_app/features/khatmat/presentation/screens/khatmat/khatmat_screen.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart' show CheckYourNetworkConnectionState, NavigateToCurrentAyahPageState, ListeningCubit, ListeningState;
import 'package:quran_app/features/main/presentation/screens/settings_screens/root_app.dart' show RootApp;
import 'package:quran_app/injection_container.dart' as di;
import 'package:quran_app/l10n/localization_context.dart';
import 'package:quran_app/notification_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/utils/app_strings.dart';

import '../../../tenReadings/presentation/dialogs/app_needs_update_dialog.dart';

class OrdinaryMoshafScreen extends StatefulWidget {
  final int? page;

  const OrdinaryMoshafScreen({this.page, super.key});

  @override
  State<OrdinaryMoshafScreen> createState() => _OrdinaryMoshafScreenState();
}

class _OrdinaryMoshafScreenState extends State<OrdinaryMoshafScreen> {
  final GlobalKey pageViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logScreenView(screenName: AppStrings.analytcsScreenMoshafScreen);
    if (widget.page != null && mounted) {
      context.read<EssentialMoshafCubit>().navigateToPage(widget.page!);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WakelockPlus.enabled.then((enabled) {
      if (!enabled) {
        WakelockPlus.enable();
      }
    });

    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    Future.delayed(const Duration(seconds: 5), () {
      if (context.read<BookmarksCubit>().checkToShowBookmarksOnStart()) {
        showSavedBookmarks(context);
      }
    });
    _firebaseMessagingOnMessageListener();
    _firebaseMessagingOnMessageOpenAppListener();
  }

  //* Notifications Methods started

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((ReceivedNotification receivedNotification) async {
      log("receivedNotification payload=${receivedNotification.payload}");
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null ? Text(receivedNotification.title!) : null,
          content: receivedNotification.body != null ? Text(receivedNotification.body!) : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const KhatmatScreen(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      log("selectedNotification payload=$payload");
      if (payload != null) {
        bool isRootViewshown = EssentialMoshafCubit.get(context).isShowFihris;
        if (!isRootViewshown) {
          EssentialMoshafCubit.get(context).toggleRootView();
        }
        EssentialMoshafCubit.get(context).changeBottomNavBarToKhatmatWithPayload(payload);
      }
    });
  }

  _firebaseMessagingOnMessageListener() {
    log("firebaseMessaging: onMessage started listening");
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      log("firebaseMessaging: onMessage recieved msg with data");
      log("firebaseMessaging: " + remoteMessage.toMap().toString());
      String? type = remoteMessage.data["type"];
      if (type != null) {
        if (type.contains("update")) {
          showAppNeedsUpdateDialog(context);
        }
      }
    });
  }

  _firebaseMessagingOnMessageOpenAppListener() {
    log("firebaseMessaging: OnMessageOpenApp started listening");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      log("firebaseMessaging: OnMessageOpenApp recieved msg with data");
      log("firebaseMessaging: " + remoteMessage.toMap().toString());
      String? type = remoteMessage.data["type"];
      if (type != null) {
        if (type.contains("update")) {
          showAppNeedsUpdateDialog(context);
        }
      }
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    WakelockPlus.disable();
    super.dispose();
  }

  //* Notifications Methods ended

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final actualHeightBeforeSafeArea = size.height - padding.top - padding.bottom;
    final actualWidthBeforeSafeArea = size.width - padding.left - padding.right;
    log(
      "look== actual height:$actualHeightBeforeSafeArea, actual width:$actualWidthBeforeSafeArea, topPadding:${padding.top}, bottomPadding: ${padding.bottom}, rightPadding: ${padding.right}, leftPadding: ${padding.left}",
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.theme.appBarTheme.systemOverlayStyle!,
      child: WillPopScope(
        onWillPop: () {
          if (EssentialMoshafCubit.get(context).isToShowAppBar || EssentialMoshafCubit.get(context).isToShowBottomSheet) {
            EssentialMoshafCubit.get(context).hideFlyingLayers();
            EssentialMoshafCubit.get(context).hideBottomSheetSections();
            // EssentialMoshafCubit.get(context).hideBottomSheetSections();
            return Future.value(false);
          } else if (!EssentialMoshafCubit.get(context).isShowFihris) {
            EssentialMoshafCubit.get(context).toggleRootView();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: BlocProvider(
          create: (BuildContext context) => di.getItInstance<ListeningCubit>()..init(),
          child: BlocListener<ListeningCubit, ListeningState>(
            listener: (context, state) {
              if (state is NavigateToCurrentAyahPageState) {
                context.read<EssentialMoshafCubit>().navigateToPage(state.page);
              }
              if (state is CheckYourNetworkConnectionState) {
                AppConstants.showToast(
                  context,
                  msg: context.translate.check_your_internet_connection,
                );
              }
            },
            child: Container(
              color: context.theme.brightness == Brightness.dark ? AppColors.appBarBgDark : AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (BuildContext context, ThemeState state) {
                          return Scaffold(
                            resizeToAvoidBottomInset: false,
                            backgroundColor: state.brightness == Brightness.light ? state.pageBgcolor : null,
                            body: Stack(
                              children: [
                                Column(
                                  children: [
                                    const NavigateBySurahListView(),
                                    Expanded(
                                      child: GestureDetector(
                                        onPanEnd: (DragEndDetails dragEndDetails) {
                                          if (kDebugMode) {
                                            print("onVerticalDragEnd.velocity=${dragEndDetails.velocity.pixelsPerSecond.distance}");
                                          }
                                          if (dragEndDetails.velocity.pixelsPerSecond.distance >= 150) {
                                            EssentialMoshafCubit.get(context).toggleTopBottomNavListViews();
                                          }
                                        },
                                        child: MediaQuery.of(context).orientation != Orientation.landscape
                                            ? QuranPageView(
                                                actualHeight: actualHeightBeforeSafeArea,
                                                actualWidth: actualWidthBeforeSafeArea,
                                                rightPadding: MediaQuery.of(context).padding.right,
                                                leftPadding: MediaQuery.of(context).padding.left,
                                                pageViewKey: pageViewKey,
                                              )
                                            : SingleChildScrollView(
                                                controller: context.read<EssentialMoshafCubit>().quranPageLandscapeVerticalScrollController,
                                                child: SizedBox(
                                                  height: context.width / AppConstants.moshafPageAspectRatio,
                                                  width: context.width,
                                                  child: QuranPageView(
                                                    actualHeight: actualHeightBeforeSafeArea,
                                                    actualWidth: actualWidthBeforeSafeArea,
                                                    rightPadding: padding.right,
                                                    leftPadding: padding.left,
                                                    pageViewKey: pageViewKey,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const NavigateByJuzHizbQuarter(),
                                  ],
                                ),
                                const TopFlyingAppBar(withNavitateSourah: false),
                                const NavigateByPageNumberListView(),
                                const CustomBottomConvextSheet(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
                      listenWhen: (prev, cur) => cur is StartListeningToTheNewPage,
                      listener: (context, state) {
                        if (state is StartListeningToTheNewPage) {}
                        if (state is ChangeCurrentPage) {
                          context.read<EssentialMoshafCubit>().quranPageLandscapeVerticalScrollController.jumpTo(0.0);
                        }
                      },
                      builder: (BuildContext context, EssentialMoshafState state) {
                        return AnimatedPositioned(
                          left: EssentialMoshafCubit.get(context).isShowFihris ? 0 : context.width,
                          right: EssentialMoshafCubit.get(context).isShowFihris ? 0 : -context.width,
                          duration: const Duration(milliseconds: 100),
                          child: SizedBox(
                            width: context.width,
                            height: context.height,
                            child: const RootApp(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
