import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart' show EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/features/main/presentation/screens/quran_search_screen.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart' show TenReadingsCubit, TenReadingsState, TenreadingLoading;
import 'package:quran_app/features/tenReadings/presentation/dialogs/app_needs_update_dialog.dart';
import 'package:quran_app/l10n/localization_context.dart';

///* This Widget is to build the top flying appBar which includes surah name, drawer icon and search icon
class TopFlyingAppBar extends StatelessWidget {
  final bool withNavitateSourah;
  const TopFlyingAppBar({super.key, required this.withNavitateSourah});
  //* qeraat types [القرءان الكريم - القراءات العشر]
  List<Map<String, dynamic>> _moshafTypes(BuildContext context) {
    return [
      {"name": context.translate.holy_quran, "type": MoshafTypes.ORDINARY},
      {"name": context.translate.ten_readings, "type": MoshafTypes.TEN_READINGS}
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final isToShowFlyingLayers = EssentialMoshafCubit.get(context).isToShowAppBar;
        final currantSurah = EssentialMoshafCubit.get(context).currentSurahInt;

        print("isToShowFlyingLayers: $isToShowFlyingLayers");
        return isToShowFlyingLayers
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: context.width,
                    height: 70,
                    decoration: BoxDecoration(color: context.isDarkMode ? AppColors.appBarBgDark : AppColors.primary, image: context.isDarkMode ? null : const DecorationImage(image: AssetImage(AppAssets.pattern), fit: BoxFit.cover)),
                    padding: EdgeInsets.only(top: context.topPadding),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, left: context.width * 0.05, top: !withNavitateSourah ? 0 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                // showAppNeedsUpdateDialog(context);
                                // return;
                                EssentialMoshafCubit.get(context).toggleRootView();
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 14),
                                width: 30,
                                height: 30,
                                child: SvgPicture.asset(
                                  AppAssets.menuIcon,
                                  width: 16,
                                  color: context.theme.primaryIconTheme.color,
                                  fit: BoxFit.none,
                                ),
                              )),
                          SvgPicture.asset(
                            AppAssets.getSurahName(currantSurah),
                            height: 28,
                            color: context.theme.primaryIconTheme.color,
                          ),
                          InkWell(
                            onTap: () => pushSlide(context, screen: const QuranSearch()),
                            child: Container(
                              padding: const EdgeInsets.only(
                                right: 20,
                                top: 10,
                                bottom: 10,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.search,
                                color: context.theme.primaryIconTheme.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocConsumer<TenReadingsCubit, TenReadingsState>(
                    listener: (context, state) {
                      if (state is TenreadingLoading) {
                        context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
                      }
                    },
                    builder: (context, state) {
                      if (context.read<TenReadingsCubit>().isDownloadingAssets || state is TenreadingLoading) {
                        return Container(
                          height: 5,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: LinearProgressIndicator(),
                        );
                      } else {
                        return SizedBox(
                          height: 5,
                        );
                      }
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: (context.theme.brightness == Brightness.dark ? AppColors.scaffoldBgDark : AppColors.border), width: (context.theme.brightness == Brightness.dark ? 0.0 : 1.0)),
                            color: context.theme.brightness == Brightness.dark ? context.theme.cardColor : AppColors.tabBackground,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int screen in [0, 1])
                              InkWell(
                                onTap: () async {
                                  if (_moshafTypes(context)[screen]["type"] == MoshafTypes.TEN_READINGS) {
                                    if (context.read<TenReadingsCubit>().checkIfCurrentPageIsBeingDownloaded()) {
                                      AppConstants.showToast(context, msg: context.translate.this_page_is_being_downloaded);
                                      return;
                                    }

                                    final bool pageFilesAreFound = await context.read<TenReadingsCubit>().checkIfFilesAreFound();

                                    context.read<TenReadingsCubit>().readDownloadedJsonFilesForCurrrentPage();

                                    if (pageFilesAreFound) {
                                      EssentialMoshafCubit.get(context).changeMoshafType(_moshafTypes(context)[screen]["type"]);
                                    } else {
                                      return;
                                    }
                                  } else {
                                    EssentialMoshafCubit.get(context).changeMoshafType(_moshafTypes(context)[screen]["type"]);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: EssentialMoshafCubit.get(context).currentMoshafType == _moshafTypes(context)[screen]["type"]
                                        ? (context.theme.brightness == Brightness.dark ? AppColors.activeTypeBgDark : AppColors.activeButtonColor)
                                        : (context.theme.brightness == Brightness.dark ? context.theme.cardColor : AppColors.tabBackground),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _moshafTypes(context)[screen]["name"],
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: EssentialMoshafCubit.get(context).currentMoshafType == _moshafTypes(context)[screen]["type"] ? AppColors.white : (context.theme.brightness == Brightness.dark ? AppColors.white : AppColors.activeButtonColor),
                                        fontSize: Orientation.landscape == MediaQuery.of(context).orientation ? context.width * 0.012 : context.width * 0.029,
                                        fontWeight: EssentialMoshafCubit.get(context).currentMoshafType == _moshafTypes(context)[screen]["type"] ? FontWeight.bold : FontWeight.w400),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: isToShowFlyingLayers ? 15 : 0),
                ],
              )
            : Container();
      },
    );
  }
}
