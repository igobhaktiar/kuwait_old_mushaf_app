// appearance
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/show_dark_theme_not_available__in_10R.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

class AppearanceControlScreen extends StatelessWidget {
  const AppearanceControlScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        SharedPreferences? sharedPreferences;

        return Scaffold(
            appBar: AppBar(
              title: Text(context.translate.appearance),
              leading: AppConstants.customBackButton(context),
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    sharedPreferences?.getInt(AppStrings.savedTheme) == 0
                        ? Brightness.light
                        : Brightness.dark,
              ),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                      child: SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              AppearanceWidgetList(
                                groupTitle: context.translate.appearance,
                                AppearanceListData:
                                    _AppearancelistTiles1(context),
                              ),
                              const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ]));
      },
    );
  }

  List<ListItemData> _AppearancelistTiles1(BuildContext context) {
    //* AppearanceS
    final AppearanceList = [
      ListItemData(
          icon: AppAssets.brightnessHigh,
          name: context.translate.automatic,
          subTitle: context.translate.according_to_device_settings),
      //* NOTIFICATIONS
      ListItemData(
        icon: AppAssets.brightness_2,
        name: context.translate.light_mode,
      ),
      ListItemData(
          icon: AppAssets.darkMode,
          name: context.translate.dark_mode,
          subTitle: context.translate.the_background_will_be_dark),
    ];
    return AppearanceList;
  }
}

class AppearanceWidgetList extends StatefulWidget {
  AppearanceWidgetList({
    required this.AppearanceListData,
    required this.groupTitle,
    Key? key,
  }) : super(key: key);
  List<ListItemData> AppearanceListData;
  String groupTitle;

  @override
  State<AppearanceWidgetList> createState() => _AppearanceWidgetListState();
}

class _AppearanceWidgetListState extends State<AppearanceWidgetList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            widget.groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
            clipBehavior: Clip.antiAlias,
            color: context.theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              side: BorderSide(
                  color: AppColors.border,
                  width:
                      context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
            ),
            child: BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
              builder: (context, state) {
                //todo: fawwaly what is this?
                final stateIcon = EssentialMoshafCubit.get(context).stateIcon;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, index) {
                    return index == 1 && stateIcon
                        ? const SizedBox()
                        : AppConstants.appDivider(context, indent: 40);
                  },
                  itemCount: widget.AppearanceListData.length,
                  itemBuilder: (_, index) {
                    return Opacity(
                      opacity: index == 2 &&
                              context
                                  .read<EssentialMoshafCubit>()
                                  .isInTenReadingsMode()
                          ? 0.4
                          : 1.0,
                      child: Padding(
                          padding: index != 1
                              ? const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 12)
                              : EdgeInsets.zero,
                          child: InkWell(
                            onTap: () {
                              // EssentialMoshafCubit.get(context)
                              //     .changeTheme(index);
                              if (index == 1) {
                                _toggleLightThemeOptions(context);
                              }

                              context.read<ThemeCubit>().setCurrentTheme(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: index == 1
                                          ? const EdgeInsets.fromLTRB(
                                              15, 12, 20, 20)
                                          : EdgeInsets.zero,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ClipOval(
                                              child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset(
                                              widget.AppearanceListData[index]
                                                  .icon!,
                                              height: 18,
                                              color: context
                                                  .theme.primaryIconTheme.color,

                                              // fit: BoxFit.fitHeight,
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          //* main Tile [default,light,dark]
                                          Container(
                                            // color: Colors.red,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .AppearanceListData[index]
                                                      .name!,
                                                  style: context
                                                      .textTheme.bodyMedium,
                                                ),
                                                SizedBox(
                                                  height: index == 1 ? 0 : 8,
                                                ),
                                                index == 1
                                                    ? Container()
                                                    : Text(
                                                        widget
                                                            .AppearanceListData[
                                                                index]
                                                            .subTitle!,
                                                        style: context.textTheme
                                                            .displaySmall,
                                                      )
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          if (index == 1)
                                            InkWell(
                                              onTap: () =>
                                                  _toggleLightThemeOptions(
                                                      context),
                                              child: RotatedBox(
                                                quarterTurns:
                                                    !stateIcon ? 3 : 1,
                                                child: Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          if (index != 1 &&
                                              context
                                                      .read<ThemeCubit>()
                                                      .currentThemeId ==
                                                  index)
                                            SvgPicture.asset(
                                              AppAssets.checkMark,
                                              color: context
                                                  .theme.primaryIconTheme.color,
                                            ),
                                        ],
                                      ),
                                    ),
                                    //* sub Tiles [light_white,light_gold]
                                    index == 1 && stateIcon
                                        ? Container(
                                            color: context.theme.brightness ==
                                                    Brightness.dark
                                                ? AppColors
                                                    .innerSelectedOptionDark
                                                : AppColors
                                                    .innerSelectedOptionLight,
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              separatorBuilder: (_, index) {
                                                return AppConstants.appDivider(
                                                  context,
                                                  indent: 60,
                                                  color: context.theme
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xff565657)
                                                      : AppColors.border,
                                                );
                                              },
                                              itemCount: 2,
                                              itemBuilder: (_, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 10, 40, 10),
                                                  child: InkWell(
                                                    onTap: () {
                                                      // EssentialMoshafCubit.get(
                                                      //         context)
                                                      //     .changeTheme(
                                                      //         index + 3);
                                                      ThemeCubit.get(context)
                                                          .setCurrentTheme(
                                                              index + 3);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: index == 0
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFFE5D9A9),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  offset:
                                                                      const Offset(
                                                                          0, 4),
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.20),
                                                                  blurRadius:
                                                                      4),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              index == 0
                                                                  ? context
                                                                      .translate
                                                                      .white_mode
                                                                  : context
                                                                      .translate
                                                                      .golden_mode,
                                                              style: context
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              index == 0
                                                                  ? context
                                                                      .translate
                                                                      .the_background_will_be_white_color
                                                                  : context
                                                                      .translate
                                                                      .the_background_will_be_light_yellow_color,
                                                              style: context
                                                                  .textTheme
                                                                  .displaySmall,
                                                            )
                                                          ],
                                                        ),
                                                        const Spacer(),
                                                        if (context
                                                                .read<
                                                                    ThemeCubit>()
                                                                .currentThemeId ==
                                                            index + 3)
                                                          SvgPicture.asset(
                                                            AppAssets.checkMark,
                                                            color: context
                                                                .theme
                                                                .primaryIconTheme
                                                                .color,
                                                          ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          )),
                    );
                  },
                );
              },
            )),
      ],
    );
  }

  _toggleLightThemeOptions(BuildContext context) {
    EssentialMoshafCubit.get(context).changeCollapseIcon();
  }
}
