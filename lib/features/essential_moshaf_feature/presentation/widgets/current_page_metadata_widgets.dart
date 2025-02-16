import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart' show AppStrings;
import 'package:quran_app/core/utils/assets_manager.dart' show AppAssets;
import 'package:quran_app/core/utils/encode_arabic_digits.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;

import '../../data/models/ayat_swar_models.dart';

//todo:  current juz,surah,hizb,page in frames
//*1-surah
class CurrentSurahFrameWidget extends StatelessWidget {
  final AyahModel? customAyah;
  final double? customWidth;
  const CurrentSurahFrameWidget({
    Key? key,
    this.customAyah,
    this.customWidth,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isToShowFlyingLayers =
        EssentialMoshafCubit.get(context).isToShowAppBar;
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        return InkWell(
          onTap: () {
            cubit.changeBottomNavBar(0);
            cubit.toggleRootView();
            cubit.changeFihrisView(1);
          },
          child: SizedBox(
            width: context.width * 0.3,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SvgPicture.asset(
                  AppAssets.pageMetadataFrame,
                  width: customWidth ?? 114,
                  color: context.theme.brightness == Brightness.dark
                      ? AppColors.cardBgActiveDark
                      : null,
                  // color: Colors.red,
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  height: customAyah != null ? 30 : 25,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.getSurahName(customAyah != null
                        ? customAyah!.surahNumber!
                        : cubit.currentSurahModel.number!),
                    height: 17,
                    color: context.theme.primaryIconTheme.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//*2- Juz
class CurrentJuzFrameWidget extends StatelessWidget {
  final AyahModel? customAyah;
  final double? customWidth;
  const CurrentJuzFrameWidget({
    Key? key,
    this.customAyah,
    this.customWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToShowFlyingLayers =
        EssentialMoshafCubit.get(context).isToShowAppBar;
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        return InkWell(
          onTap: () {
            cubit.changeBottomNavBar(0);
            cubit.toggleRootView();
            cubit.changeFihrisView(0);
          },
          child: SizedBox(
            width: context.width * 0.3,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SvgPicture.asset(
                  AppAssets.pageMetadataFrame,
                  width: customWidth ?? 114,
                  color: context.theme.brightness == Brightness.dark
                      ? AppColors.cardBgActiveDark
                      : null,
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  height: customAyah != null ? 30 : 25,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.getJuzName(customAyah != null
                        ? customAyah!.juz!
                        : (cubit.currentPage + 1) == 121
                            ? 6
                            : cubit.currentJuz),
                    height: 17,
                    color: context.theme.primaryIconTheme.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//*3- Hizb
class CurrentHizbFrameWidget extends StatelessWidget {
  const CurrentHizbFrameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isToShowFlyingLayers =
        EssentialMoshafCubit.get(context).isToShowAppBar;
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        return SafeArea(
          bottom: true,
          left: false,
          right: false,
          top: false,
          child: InkWell(
            onTap: () {
              cubit.changeBottomNavBar(0);
              cubit.toggleRootView();
              cubit.changeFihrisView(2);
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SvgPicture.asset(
                  AppAssets.pageMetadataFrame,
                  width: 114,
                  color: context.theme.brightness == Brightness.dark
                      ? AppColors.cardBgActiveDark
                      : null,
                  // color: Colors.red,
                  fit: BoxFit.fitWidth,
                ),
                Container(
                  height: 25,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.getHizbName(cubit.currentHizb),
                    height: 17,
                    color: context.theme.primaryIconTheme.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//*4- page
class CurrentPageFrameWidget extends StatelessWidget {
  const CurrentPageFrameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isToShowFlyingLayers =
        EssentialMoshafCubit.get(context).isToShowAppBar;
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        return SafeArea(
          bottom: true,
          left: false,
          right: false,
          top: false,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SvgPicture.asset(
                AppAssets.pageMetadataFrame,
                width: 114,
                color: context.theme.brightness == Brightness.dark
                    ? AppColors.cardBgActiveDark
                    : null,
                // color: Colors.red,
                fit: BoxFit.fitWidth,
              ),
              Container(
                height: 25,
                alignment: Alignment.bottomCenter,
                child: Text(
                  encodeToArabicNumbers(inputInteger: cubit.currentPage + 1),
                  // encodeToArabicNumbers(inputInteger: cubit.currentPage + 1),
                  style: TextStyle(
                      color: context.theme.brightness == Brightness.dark
                          ? AppColors.white
                          : Colors.black,
                      fontSize: 16,
                      fontFamily: AppStrings.uthmanyFontFamily,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
