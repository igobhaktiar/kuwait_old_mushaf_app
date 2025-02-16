import 'package:animate_do/animate_do.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/app_colors.dart' show AppColors;
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart' show AppAssets;
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart'
    show
        BottomSheetCubit,
        BottomSheetOrdinaryState,
        BottomSheetState,
        BottomSheetTenQeraatState;
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show ChangeMoshafType, EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/show_dark_theme_not_available__in_10R.dart';
import 'package:quran_app/l10n/localization_context.dart';

class CustomBottomConvextSheet extends StatefulWidget {
  const CustomBottomConvextSheet({Key? key}) : super(key: key);

  @override
  State<CustomBottomConvextSheet> createState() =>
      _CustomBottomConvextSheetState();
}

class _CustomBottomConvextSheetState extends State<CustomBottomConvextSheet>
    with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(
    initialIndex: 1,
    length: 4,
    vsync: this,
  );

  @override
  void initState() {
    tabController.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.translate.localeName == AppStrings.arabicCode
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
        listener: (BuildContext context, EssentialMoshafState state) {
          if (state is ChangeMoshafType) {
            BottomSheetCubit.get(context).changeViewsType(state.moshafType);
            tabController.animateTo(0);
            FirebaseAnalytics.instance.logScreenView(
                screenName: state.moshafType == MoshafTypes.ORDINARY
                    ? AppStrings.analytcsScreenMoshafScreen
                    : AppStrings.analytcsScreenTenReadingsScreen);
          }
        },
        builder: (BuildContext context, EssentialMoshafState state) {
          return AnimatedPositioned(
              duration: const Duration(milliseconds: 375),
              // top: 200, //todo put the sheet position here
              bottom: EssentialMoshafCubit.get(context).isToShowBottomSheet &&
                      MediaQuery.of(context).orientation !=
                          Orientation.landscape
                  ? 0 //[Listen=-80],[tafseer=-80],,[qeraat=0],[osoul=150 & parent=400],,[osoul=100 & parent=400]
                  : -400,
              child: GestureDetector(
                onPanEnd: (DragEndDetails dragEndDetails) {
                  print(
                    "onVerticalDragEnd.velocity=${dragEndDetails.velocity.pixelsPerSecond.distance}",
                  );
                  if (dragEndDetails.velocity.pixelsPerSecond.distance >= 150) {
                    context
                        .read<EssentialMoshafCubit>()
                        .hideBottomSheetSections();
                    context.read<EssentialMoshafCubit>().hideFlyingLayers();
                  }
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    color: Colors.transparent,
                    child: BlocConsumer<BottomSheetCubit, BottomSheetState>(
                      listener: (BuildContext context, BottomSheetState state) {
                        if (state is BottomSheetTenQeraatState) {
                          setState(() =>
                              tabController.animateTo(state.currentViewIndex));
                        } else if (state is BottomSheetOrdinaryState) {
                          setState(() =>
                              tabController.animateTo(state.currentViewIndex));
                        }
                      },
                      builder: (BuildContext context, BottomSheetState state) {
                        return Column(
                          children: [
                            ConvexAppBar.builder(
                                curveSize: 60,
                                top: -20,
                                height: 70,
                                elevation: 1,
                                controller: tabController,
                                backgroundColor: context.isDarkMode
                                    ? AppColors.tabBackgroundDark
                                    : AppColors.tabBackground,
                                count: (state is BottomSheetTenQeraatState)
                                    ? _tenQeraatHeaders(context).length
                                    : _hollyQuranHeaders(context).length,
                                itemBuilder: Builder(
                                  items: (state is BottomSheetTenQeraatState)
                                      ? _tenQeraatHeaders(context)
                                      : _hollyQuranHeaders(context),
                                ),
                                onTap: (final i) {
                                  //todo: change current view through the cubit
                                  BottomSheetCubit.get(context)
                                      .changeViewIndex(i);
                                  setState(() {
                                    tabController.animateTo(i);
                                  });
                                }),
                            Expanded(
                              child: Container(
                                height: 300,
                                width: context.width,
                                decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? AppColors.cardBgDark
                                        : AppColors.white,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(9)),
                                    border: Border.all(
                                        color: context.isDarkMode
                                            ? AppColors.bottomSheetBorderDark
                                            : AppColors.border,
                                        width: 1)),
                                //*current view is shown here
                                child: BottomSheetCubit.get(context)
                                    .currentBottomSheetView,
                              ),
                            ),
                          ],
                        );
                      },
                    )),
              ));
        },
      ),
    );
  }

  List<TabItem> _hollyQuranHeaders(BuildContext context) {
    return [
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.tafseerInactive,
            width: 20,
            height: 20,
            color: context.isDarkMode ? Colors.white : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.tafseerActive,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.tafseer),
      TabItem(
          icon: SvgPicture.asset(
            context.theme.brightness == Brightness.dark
                ? AppAssets.listenBorderDark
                : AppAssets.listenBorder,
            width: 15,
            height: 16,
            color: context.isDarkMode ? AppColors.white : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.listen,
            width: 20, height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
            // color: Colors.white,
          ),
          title: context.translate.listen),
      TabItem(
          activeIcon: SvgPicture.asset(
            AppAssets.bookmarkFilled,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
            width: 20, height: 20,

            // color: Colors.white,
          ),
          icon: SvgPicture.asset(
            AppAssets.bookmarkOutlined,
            width: 20, height: 20,
            color: context.isDarkMode ? AppColors.white : null,
            // color: Colors.white,
          ),
          title: context.translate.bookmarks),
    ];
  }

  List<TabItem> _tenQeraatHeaders(BuildContext context) {
    return [
      TabItem(
          icon: SvgPicture.asset(
            context.theme.brightness == Brightness.dark
                ? AppAssets.listenBorderDark
                : AppAssets.listenBorder,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.listen,
            width: 20, height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
            // color: Colors.white,
          ),
          title: context.translate.readings),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.tafseerInactive,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.tafseerActive,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.osoul),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.fihris,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.fihris,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.shwahid),
      TabItem(
          icon: SvgPicture.asset(
            AppAssets.marginsIcon,
            width: 20,
            height: 20,
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : null,
          ),
          activeIcon: SvgPicture.asset(
            AppAssets.marginsIcon,
            width: 20,
            height: 20,
            color:
                context.isDarkMode ? AppColors.tabBackgroundDark : Colors.white,
          ),
          title: context.translate.hwamish),
    ];
  }
}

class Builder extends DelegateBuilder {
  final List<TabItem> items;
  Builder({required this.items});

  @override
  Widget build(BuildContext context, int index, bool active) {
    dynamic currentIcon = (items[index].activeIcon != null && active)
        ? items[index].activeIcon
        : items[index].icon;
    return Material(
      color: Colors.transparent,
      child: active
          ? SlideInDown(
              child: _buildIconAndTitle(active, currentIcon, index,
                  context: context),
            )
          : _buildIconAndTitle(active, currentIcon, index, context: context),
    );
  }

  Column _buildIconAndTitle(bool active, currentIcon, int index,
      {required BuildContext context}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: active ? 0 : 10),
        Container(
            width: 50,
            alignment: Alignment.center,
            height: active ? 50 : 30, //-10
            decoration: BoxDecoration(
                color: active
                    ? (context.isDarkMode
                        ? AppColors.white
                        : AppColors.activeButtonColor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(50)),
            child: (currentIcon is IconData)
                ? Icon(
                    currentIcon,
                    color: active ? Colors.white : const Color(0xFF968A7A),
                  )
                : FittedBox(
                    child: currentIcon,
                    fit: BoxFit.scaleDown,
                  )),
        SizedBox(height: active ? 12 : 0),
        Expanded(
          child: Text(
            items[index].title.toString(),
            style: TextStyle(
              color: active || context.isDarkMode
                  ? (context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.activeButtonColor)
                  : const Color(0xFF968A7A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }
}
