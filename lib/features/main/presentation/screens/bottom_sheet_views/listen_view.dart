import 'package:flutter/foundation.dart' show Brightness, Key, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart' show AppAssets;
import 'package:quran_app/core/utils/constants.dart' show AppConstants;
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/widgets/custom_switch_list_tile.dart'
    show CustomSwitchListTile;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:quran_app/l10n/localization_context.dart';

class ListenView extends StatefulWidget {
  const ListenView({
    Key? key,
  }) : super(key: key);

  @override
  State<ListenView> createState() => _ListenViewState();
}

class _ListenViewState extends State<ListenView> {
  double timeValue = 0.0;
  bool isToChooseRepeat = false;
  bool isToChooseSheikh = false;
  bool isTorepeatAyah = false;
  bool isTorepeatSection = false;
  int ayahRepeatValue = 1;
  int sectionRepeatValue = 1;
  int currentSection = 0;
  int currentSelectedSheikh = 0;
  List<String> sectionTypesStrings(BuildContext context) {
    var sectionNames = [
      context.translate.single_page,
      context.translate.surah,
      context.translate.quarter,
      context.translate.hizb,
      context.translate.juz,
    ];
    return sectionNames;
  }

  List<int> sectionTypesValues = [
    1,
    1,
    1,
    1,
    1,
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: isToChooseRepeat
          ? _buildRepeatOptionsView()
          : isToChooseSheikh
              ? _buildSheikhOptions()
              : _buildPlayerButtons(),
    );
  }

  Column _buildSheikhOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ViewDashIndicator(),
        _buildListenOptionsHeader(
            title: context.translate.please_choose_reciter,
            withNoConfirm: true,
            onConfirmed: () {}),
        const SizedBox(
          height: 10,
        ),
        for (int i = 0; i < 5; i++)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: currentSelectedSheikh == i
                    ? (context.theme.brightness == Brightness.dark
                        ? AppColors.selectedShiekhBgDark
                        : AppColors.selectedListTileColor)
                    : Colors.transparent,
                child: ListTile(
                  onTap: () {
                    setState(() {
                      currentSelectedSheikh = i;
                      if (kDebugMode) {
                        print("currentSelectedSheikh =$currentSelectedSheikh");
                      }
                    });
                  },
                  dense: true,
                  title: Text(
                    'مشاري راشد العفاسي',
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: currentSelectedSheikh == i
                          ? (context.theme.brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.activeButtonColor)
                          : (context.theme.brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.inactiveColor),
                      fontWeight: currentSelectedSheikh == i
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  leading: const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(AppAssets.sheikh),
                  ),
                  trailing: SvgPicture.asset(
                    currentSelectedSheikh == i
                        ? AppAssets.pause
                        : AppAssets.outlinePlay,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                    height: 20,
                  ),
                ),
              ),
              AppConstants.appDivider(context,
                  color: context.theme.brightness == Brightness.dark
                      ? AppColors.shiekhDividerDark
                      : null),
            ],
          )
      ],
    );
  }

  Column _buildRepeatOptionsView() {
    return Column(
      children: [
        const ViewDashIndicator(),
        _buildListenOptionsHeader(
            title: context.translate.please_choose_repetition,
            onConfirmed: () {}),
        const SizedBox(height: 10),
        _buildAyahRepeatControls(),
        _buildSectionRepeatControls(),
      ],
    );
  }

  Row _buildListenOptionsHeader({
    required String title,
    required void Function() onConfirmed,
    bool withNoConfirm = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              setState(() {
                isToChooseRepeat = false;
                isToChooseSheikh = false;
              });
            },
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              size: 20,
              color: context.theme.primaryIconTheme.color,
            )),
        Text(
          title,
          style: context.textTheme.bodyMedium!
              .copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        withNoConfirm
            ? const SizedBox()
            : InkWell(
                onTap: () {
                  //todo: confirm selection
                  onConfirmed();
                },
                child: Text(
                  context.translate.confirm,
                  style: context.textTheme.bodySmall!
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
      ],
    );
  }

  Card _buildSectionRepeatControls() {
    return Card(
      color: context.theme.brightness == Brightness.dark
          ? AppColors.cardBgDark
          : AppColors.tabBackground,
      child: Column(
        children: [
          CustomSwitchListTile(
              title: context.translate.section_repetition,
              value: isTorepeatSection,
              onChanged: (value) {
                setState(() {
                  isTorepeatSection = value;
                });
              }),
          if (isTorepeatSection)
            AppConstants.appDivider(
              context,
              endIndent: 40,
              indent: 40,
            ),
          //todo: sectionTypesStrings List
          if (isTorepeatSection)
            Row(
              children: [
                for (String stringType in sectionTypesStrings(context))
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentSection =
                              sectionTypesStrings(context).indexOf(stringType);
                          if (kDebugMode) {
                            print(
                                "index:$currentSection,type=${sectionTypesStrings(context)[currentSection]},sectionTypesValues=$sectionTypesValues");
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: stringType ==
                                    sectionTypesStrings(context)[currentSection]
                                ? context.theme.brightness == Brightness.dark
                                    ? AppColors.activeTypeBgDark
                                    : AppColors.activeButtonColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          stringType,
                          style: TextStyle(
                              color: stringType ==
                                      sectionTypesStrings(
                                          context)[currentSection]
                                  ? AppColors.white
                                  : context.theme.brightness == Brightness.dark
                                      ? AppColors.border
                                      : AppColors.inactiveColor,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          if (isTorepeatSection)
            CountControlWidget(
              title: context.translate.localeName == AppStrings.arabicCode
                  ? "رقم ال${sectionTypesStrings(context)[currentSection]}"
                  : "${sectionTypesStrings(context)[currentSection]} number",
              value: sectionTypesValues[currentSection],
              onIncrement: () {
                if (
                    // for pages[1-604]
                    currentSection == 0 &&
                            sectionTypesValues[currentSection] < 604 ||
                        // for swar[1-114]
                        currentSection == 1 &&
                            sectionTypesValues[currentSection] < 114 ||
                        // for hizbQuraters[1-240]
                        currentSection == 2 &&
                            sectionTypesValues[currentSection] < 240 ||
                        // for hizbs[1-60]
                        currentSection == 3 &&
                            sectionTypesValues[currentSection] < 60 ||
                        // for juzs[1-30]
                        currentSection == 4 &&
                            sectionTypesValues[currentSection] < 30) {
                  //todo: handle pages, surahs
                  setState(() {
                    sectionTypesValues[currentSection]++;
                    if (kDebugMode) {
                      print(
                          "index:$currentSection,type=${sectionTypesStrings(context)[currentSection]},sectionTypesValues=$sectionTypesValues");
                    }
                  });
                }
              },
              onDecrement: () {
                if (sectionTypesValues[currentSection] > 1) {
                  setState(() {
                    sectionTypesValues[currentSection]--;
                    if (kDebugMode) {
                      print(
                          "index:$currentSection,type=${sectionTypesStrings(context)[currentSection]},sectionTypesValues=$sectionTypesValues");
                    }
                  });
                }
              },
            ),
          if (isTorepeatSection)
            CountControlWidget(
              title: context.translate.section_repetition_count,
              value: sectionRepeatValue,
              onIncrement: () {
                if (sectionRepeatValue < 10) {
                  setState(() {
                    sectionRepeatValue++;
                  });
                }
              },
              onDecrement: () {
                if (sectionRepeatValue != 0) {
                  setState(() {
                    sectionRepeatValue--;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Card _buildAyahRepeatControls() {
    return Card(
      color: context.theme.brightness == Brightness.dark
          ? AppColors.cardBgDark
          : AppColors.tabBackground,
      child: Column(
        children: [
          CustomSwitchListTile(
              title: context.translate.verse_repetition,
              value: isTorepeatAyah,
              onChanged: (value) {
                setState(() {
                  isTorepeatAyah = value;
                });
              }),
          if (isTorepeatAyah)
            AppConstants.appDivider(
              context,
              endIndent: 40,
              indent: 40,
            ),
          if (isTorepeatAyah)
            CountControlWidget(
              title: context.translate.verse_repetition_count,
              value: ayahRepeatValue,
              onIncrement: () {
                if (ayahRepeatValue < 10) {
                  setState(() {
                    ayahRepeatValue++;
                  });
                }
              },
              onDecrement: () {
                if (ayahRepeatValue != 0) {
                  setState(() {
                    ayahRepeatValue--;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Column _buildPlayerButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //todo: choose sheikh from here
        InkWell(
          onTap: () {
            setState(() {
              isToChooseSheikh = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage(AppAssets.sheikh),
              ),
              const SizedBox(width: 10),
              Text(
                'مشاري راشد العفاسي',
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: context.theme.primaryIconTheme.color,
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        //todo: audio control utton here
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //todo: broadcast icon
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    AppAssets.live,
                    height: 20,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  )),
              //todo: forward icon
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    AppAssets.next,
                    height: 25,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  )),
              //todo: play icon
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    AppAssets.play,
                    height: 30,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  )),
              //todo: previous icon
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    AppAssets.prev,
                    height: 25,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  )),
              //todo: repeat icon
              IconButton(
                  onPressed: () {
                    setState(() {
                      isToChooseRepeat = true;
                    });
                  },
                  icon: SvgPicture.asset(
                    AppAssets.repeat,
                    height: 17,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.white
                        : null,
                  )),
            ],
          ),
        ), //todo: slider and timeStamps here
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Slider(
                  value: timeValue,
                  max: 50,
                  min: 0,
                  onChanged: (_) {},
                  onChangeEnd: (time) {
                    setState(() {
                      timeValue = time;
                    });
                  }),
              Positioned(
                top: 35,
                child: Container(
                  width: context.width,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '00:00',
                        style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '15:30',
                        style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class CountControlWidget extends StatelessWidget {
  const CountControlWidget({
    Key? key,
    required this.title,
    required this.onIncrement,
    required this.value,
    required this.onDecrement,
  }) : super(key: key);
  final void Function() onIncrement;
  final void Function() onDecrement;
  final int value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: context.textTheme.bodyMedium!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Text(
            "$value",
            style: context.textTheme.bodyMedium!.copyWith(fontSize: 14),
          ),
          const Spacer(),
          Container(
              height: 35,
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark
                    ? AppColors.cardBgActiveDark
                    : AppColors.beige,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => onIncrement(),
                      icon: Icon(
                        Icons.add,
                        color: context.theme.primaryIconTheme.color,
                        size: 20,
                      )),
                  Container(
                    height: 15,
                    width: 0.5,
                    color: context.theme.primaryIconTheme.color,
                  ),
                  IconButton(
                      onPressed: () => onDecrement(),
                      icon: Icon(
                        Icons.remove,
                        color: context.theme.primaryIconTheme.color,
                        size: 20,
                      ))
                ],
              ))
        ],
      ),
    );
  }
}
