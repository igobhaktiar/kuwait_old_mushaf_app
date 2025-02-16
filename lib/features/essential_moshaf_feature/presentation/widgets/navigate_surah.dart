import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;

///*  This Widget is reponsible for builing and handling the top navigation scrollable listView
///* which navigates over the Quran by selecting surah name directly inside reading mode without going to the Index screen.
///
class NavigateBySurahListView extends StatelessWidget {
  const NavigateBySurahListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToShowFlyingLayers =
        EssentialMoshafCubit.get(context).isToShowAppBar;
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (BuildContext context, EssentialMoshafState state) {
        final cubit = EssentialMoshafCubit.get(context);
        return AnimatedContainer(
          duration: AppConstants.enteringAnimationDuration,
          curve: Curves.easeInOut,
          width: context.width,
          height: cubit.isToShowTopBottomNavListViews ? 50 : 0,
          margin: cubit.isToShowTopBottomNavListViews
              ? const EdgeInsets.only(top: 20, bottom: 10)
              : EdgeInsets.zero,
          color: Colors.transparent,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller:
                EssentialMoshafCubit.get(context).navigateBySurahController,
            itemCount:
                EssentialMoshafCubit.get(context).swarListForFihris.length,
            itemBuilder: (BuildContext context, int index) {
              return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
                builder: (BuildContext context, EssentialMoshafState state) {
                  final currantSurah =
                      EssentialMoshafCubit.get(context).currentSurahInt;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: () => EssentialMoshafCubit.get(context)
                          .navigateToPage(EssentialMoshafCubit.get(context)
                              .swarListForFihris[index]
                              .page!),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          //surah frame
                          SvgPicture.asset(
                            currantSurah == index + 1
                                ? AppAssets.suraNameFrameActive
                                : AppAssets.suraNameFrameDisabled,
                            // width: 156,
                            height: 50,
                            color: context.theme.brightness == Brightness.dark
                                ? AppColors.cardBgActiveDark
                                : null,
                            // fit: BoxFit.none,
                          ),
                          // surah name
                          Opacity(
                            opacity: currantSurah == index + 1 ? 1.0 : 0.5,
                            child: SvgPicture.asset(
                              AppAssets.getSurahName(index + 1),
                              height: 20,
                              color: context.theme.brightness == Brightness.dark
                                  ? AppColors.white
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
