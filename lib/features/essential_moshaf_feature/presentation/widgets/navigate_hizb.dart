import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/encode_arabic_digits.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show ChangeCurrentPage, EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/app_strings.dart';

class NavigateByJuzHizbQuarter extends StatelessWidget {
  const NavigateByJuzHizbQuarter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
      listener: (BuildContext context, EssentialMoshafState state) {
        if (state is ChangeCurrentPage) {
          final cubit = EssentialMoshafCubit.get(context);
          final currentJuz = cubit.currentJuz;
          final List<int> currentJuzQuarters = List<int>.generate(
              8, (index) => (currentJuz - 1) * 8 + 1 + index);
          final offsetToMove =
              (138.22 * (currentJuzQuarters.indexOf(state.newQuarter)))
                  .toDouble();
          cubit.navigateByQuarterController.animateTo(offsetToMove,
              duration: const Duration(milliseconds: 375),
              curve: Curves.easeOut);
        }
      },
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        final currentJuz = cubit.currentJuz;
        final currentQuarter = cubit.currentQuarter;
        final List<int> currentJuzQuarters =
            List<int>.generate(8, (index) => (currentJuz - 1) * 8 + 1 + index);
        return AnimatedContainer(
          duration: AppConstants.enteringAnimationDuration,
          curve: Curves.easeOut,
          width: context.width,
          height: cubit.isToShowTopBottomNavListViews ? 120 : 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: ListView(
            controller: context
                .read<EssentialMoshafCubit>()
                .navigateByQuarterController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            children: [
              Row(
                children: [
                  Stack(alignment: Alignment.center, children: [
                    SvgPicture.asset(AppAssets.juzIcon),
                    Text(
                      "${context.translate.juz} $currentJuz",
                      style: const TextStyle(
                          color: AppColors.activeButtonColor, fontSize: 10),
                    ),
                  ]),
                  //todo: qurters are here
                  for (final quarter in currentJuzQuarters)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () => context
                            .read<EssentialMoshafCubit>()
                            .navigateToQuarter(quarter),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              currentQuarter == quarter
                                  ? AppAssets.suraNameFrameActive
                                  : AppAssets.suraNameFrameDisabled,
                              height: 60,
                              color: context.theme.brightness == Brightness.dark
                                  ? AppColors.cardBgActiveDark
                                  : null,
                            ),
                            Opacity(
                              opacity: currentQuarter == quarter ? 1.0 : 0.4,
                              child: Center(
                                child: FittedBox(
                                  child: Column(
                                    children: [
                                      RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: AppStrings
                                                    .uthmanyHafsV20fontFamily,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    context.theme.brightness ==
                                                            Brightness.dark
                                                        ? AppColors.white
                                                        : AppColors
                                                            .activeButtonColor,
                                              ),
                                              children: [
                                            TextSpan(
                                                text: getQuarterText(
                                                    currentJuzQuarters
                                                        .indexOf(quarter),
                                                    currentJuz)[0]),
                                            TextSpan(
                                                text: getQuarterText(
                                                    currentJuzQuarters
                                                        .indexOf(quarter),
                                                    currentJuz)[1],
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontFamily: AppStrings
                                                        .uthmanyFontFamily)),
                                          ])),

                                      // Hizb
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> getQuarterText(int quarterIndex, int currentJuz) {
    List<int> currentJuzAhzab =
        List<int>.generate(2, (index) => currentJuz * 2 - 1 + index);
    List<String> quarterText = [];
    switch (quarterIndex) {
      case 0:
        quarterText = [
          "الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.first))
        ];
        break;
      case 1:
        quarterText = [
          "رُبُعُ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.first))
        ];
        break;
      case 2:
        quarterText = [
          "نِصۡفُ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.first))
        ];
        break;
      case 3:
        quarterText = [
          "ثََلاثَةٌ أَربَاعِ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.first))
        ];
        break;
      case 4:
        quarterText = [
          "الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.last))
        ];
        break;
      case 5:
        quarterText = [
          "رُبُعُ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.last))
        ];
        break;
      case 6:
        quarterText = [
          "نِصۡفُ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.last))
        ];
        break;
      case 7:
        quarterText = [
          "ثََلاثَةٌ أَربَاعِ الحِزۡبِۭ ",
          (encodeToArabicNumbers(inputInteger: currentJuzAhzab.last))
        ];
        break;
    }
    return quarterText;
  }
}
