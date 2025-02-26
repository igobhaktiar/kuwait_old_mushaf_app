import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/encode_timestamps.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/widgets/custom_switch_list_tile.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:quran_app/features/listening/data/models/reciter_model.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/listening/presentation/screens/control_buttons.dart';
import 'package:quran_app/features/listening/presentation/screens/section_repeat_enum%7B.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../essential_moshaf_feature/data/models/fihris_models.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

class ListenView extends StatefulWidget {
  const ListenView({
    Key? key,
  }) : super(key: key);

  @override
  State<ListenView> createState() => _ListenViewState();
}

class _ListenViewState extends State<ListenView> {
  bool isTorepeatAyah = false;
  bool isTorepeatSection = false;
  int ayahRepeatCount = 1;
  int sectionRepeatCount = 1;
  int currentSection = 1;

  List<String> sectionTypesStrings(BuildContext context) {
    var sectionNames = [
      context.translate.custom,
      context.translate.single_page,
      context.translate.surah,
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
  List dropDowns = [];
  List<SurahFihrisModel?> swarForCustomRange = [null, null];
  List<int?> ayatForCustomRange = [null, null];
  SurahFihrisModel? surahSection;

  @override
  void initState() {
    surahSection = context.read<EssentialMoshafCubit>().swarListForFihris.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dropDowns = [
      const SizedBox(),
      _buildPageSectionDropDown(),
      _buildSurahSectionDropDown(),
      _buildHizbSectionDropDown(),
      _buildJuzSectionDropDown(),
    ];
    return BlocBuilder<ListeningCubit, ListeningState>(
      builder: (context, state) {
        var cubit = ListeningCubit.get(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: cubit.isToChooseRepeat
              ? _buildRepeatOptionsView()
              : cubit.isToChooseSheikh
                  ? _buildSheikhOptions()
                  : const ControlButtonsRow(),
        );
      },
    );
  }

  Widget _buildSheikhOptions() {
    return BlocConsumer<ListeningCubit, ListeningState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var cubit = ListeningCubit.get(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ViewDashIndicator(),
            _buildListenOptionsHeader(title: context.translate.please_choose_reciter, withNoConfirm: true, onConfirmed: () {}),
            const SizedBox(
              height: 10,
            ),
            for (ReciterModel reciter in cubit.recitersList)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    color: cubit.currentReciter == reciter ? (context.theme.brightness == Brightness.dark ? AppColors.selectedShiekhBgDark : AppColors.selectedListTileColor) : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        ListeningCubit.get(context).setCurrentReciter(reciter);
                      },
                      dense: true,
                      title: Text(
                        context.translate.localeName == AppStrings.arabicCode ? reciter.nameArabic.toString() : reciter.nameEnglish.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          color: cubit.currentReciter == reciter ? (context.theme.brightness == Brightness.dark ? Colors.white : AppColors.activeButtonColor) : (context.theme.brightness == Brightness.dark ? Colors.white : AppColors.inactiveColor),
                          fontWeight: cubit.currentReciter == reciter ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(reciter.photo.toString()),
                      ),
                      trailing: StreamBuilder<PlayerState>(
                          stream: cubit.player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;

                            final playing = playerState == null
                                ? false
                                : playerState.processingState == ProcessingState.completed
                                    ? false
                                    : playerState.playing;
                            return SvgPicture.asset(
                              cubit.currentReciter == reciter && playing ? AppAssets.pause : AppAssets.outlinePlay,
                              color: context.theme.brightness == Brightness.dark ? Colors.white : null,
                              height: 20,
                            );
                          }),
                    ),
                  ),
                  AppConstants.appDivider(context, color: context.theme.brightness == Brightness.dark ? AppColors.shiekhDividerDark : null),
                ],
              )
          ],
        );
      },
    );
  }

  Column _buildRepeatOptionsView() {
    return Column(
      children: [
        const ViewDashIndicator(),
        _buildListenOptionsHeader(
            title: context.translate.please_choose_repetition,
            onConfirmed: () {
              _feedPlayerWithAudios();
              context.read<ListeningCubit>().returnToControllersView();
            }),
        const SizedBox(height: 10),
        _buildSectionRepeatControls(),
        _buildAyahRepeatControls(),
      ],
    );
  }

  Widget _buildListenOptionsHeader({
    required String title,
    required void Function() onConfirmed,
    bool withNoConfirm = false,
  }) {
    return Row(
      children: [
        InkWell(
            onTap: () {
              context.read<ListeningCubit>().returnToControllersView();
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                Icons.arrow_back_ios_sharp,
                size: 20,
                color: context.theme.primaryIconTheme.color,
              ),
            )),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: context.textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Opacity(
          opacity: withNoConfirm ? 0.0 : 1.0,
          child: InkWell(
            onTap: withNoConfirm
                ? null
                : () {
                    //todo: confirm selection
                    onConfirmed();
                  },
            child: Text(
              context.translate.confirm,
              style: context.textTheme.bodySmall!.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Card _buildSectionRepeatControls() {
    return Card(
      color: context.theme.brightness == Brightness.dark ? AppColors.cardBgDark : AppColors.tabBackground,
      child: Column(
        children: [
          Row(
            children: [
              for (String stringType in sectionTypesStrings(context))
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        currentSection = sectionTypesStrings(context).indexOf(stringType);
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: stringType == sectionTypesStrings(context)[currentSection]
                              ? context.theme.brightness == Brightness.dark
                                  ? AppColors.activeTypeBgDark
                                  : AppColors.activeButtonColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(
                        stringType,
                        style: TextStyle(
                            color: stringType == sectionTypesStrings(context)[currentSection]
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
          if (currentSection == 0)
            AyatRangeSelectorWidget(
                savedSelectedAyat: ayatForCustomRange,
                savedSelectedSwar: swarForCustomRange,
                onCustomRangeChanged: (List<SurahFihrisModel?> swar, List<int?> ayat) {
                  setState(() {
                    swarForCustomRange = swar;
                    ayatForCustomRange = ayat;
                  });
                  debugPrint("customRange:swar=${swarForCustomRange.map((e) => e == null ? "--" : e.englishName.toString()).toList()},ayat=$ayatForCustomRange ");
                }),
          if (currentSection != 0)
            CountControlWidget(
              title: context.translate.localeName == AppStrings.arabicCode ? "${currentSection != 2 ? "رقم" : ''} ال${sectionTypesStrings(context)[currentSection]}" : "${sectionTypesStrings(context)[currentSection]} number",
              value: sectionTypesValues[currentSection],
              dropDownWidget: currentSection == 0
                  ? null
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.dark ? AppColors.cardBgActiveDark : AppColors.beige,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: dropDowns[currentSection]),
              onIncrement: () {
                if (
                    // for pages[1-604]
                    currentSection == 1 && sectionTypesValues[currentSection] < 604 ||
                        // for swar[1-114]
                        currentSection == 2 && sectionTypesValues[currentSection] < 114 ||
                        // for hizbQuraters[1-240]
                        currentSection == 3 && sectionTypesValues[currentSection] < 60 ||
                        // for hizbs[1-60]
                        currentSection == 4 && sectionTypesValues[currentSection] < 30) {
                  //todo: handle pages, surahs
                  setState(() {
                    sectionTypesValues[currentSection]++;
                    if (currentSection == 2) {
                      var matchSurahList = context.read<EssentialMoshafCubit>().swarListForFihris.where((element) => element.number == sectionTypesValues[currentSection]).toList();
                      if (matchSurahList.isNotEmpty) {
                        surahSection = matchSurahList.first;
                      }
                    }
                  });
                }
              },
              onDecrement: () {
                if (sectionTypesValues[currentSection] > 1) {
                  setState(() {
                    sectionTypesValues[currentSection]--;
                    if (currentSection == 2) {
                      var matchSurahList = context.read<EssentialMoshafCubit>().swarListForFihris.where((element) => element.number == sectionTypesValues[currentSection]).toList();
                      if (matchSurahList.isNotEmpty) {
                        surahSection = matchSurahList.first;
                      }
                    }
                  });
                }
              },
            ),

          const SizedBox(height: 10),
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
              // color: Colors.red,
              indent: 40,
            ),
          //todo: sectionTypesStrings List
          if (isTorepeatSection)
            CountControlWidget(
              title: context.translate.section_repetition_count,
              value: sectionRepeatCount,
              onIncrement: () {
                if (sectionRepeatCount < 10) {
                  setState(() {
                    sectionRepeatCount++;
                  });
                }
              },
              onDecrement: () {
                if (sectionRepeatCount != 0) {
                  setState(() {
                    sectionRepeatCount--;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

//* method to build the dropdownButton to select the surah section
  DropdownButton<SurahFihrisModel> _buildSurahSectionDropDown() {
    return DropdownButton<SurahFihrisModel>(
        borderRadius: BorderRadius.circular(20),
        hint: Text(context.translate.select_surah),
        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        elevation: 6,
        underline: const SizedBox(),
        isDense: true,
        value: surahSection,
        items: context
            .read<EssentialMoshafCubit>()
            .swarListForFihris
            .map((surah) => DropdownMenuItem<SurahFihrisModel>(
                  value: surah,
                  child: Text('${surah.name}'.replaceAll(RegExp(r"سورة"), '')),
                ))
            .toList(),
        onChanged: (selectedSurah) {
          setState(() {
            surahSection = selectedSurah;
            sectionTypesValues[2] = selectedSurah!.number!;
          });
        });
  }

//* method to build the dropdownButton to select the page section
  DropdownButton<int> _buildPageSectionDropDown() {
    return DropdownButton<int>(
        borderRadius: BorderRadius.circular(20),
        hint: Text(context.translate.select_surah),
        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        elevation: 6,
        underline: const SizedBox(),
        isDense: true,
        value: sectionTypesValues[1],
        items: List<int>.generate(604, (index) => index + 1)
            .map((page) => DropdownMenuItem<int>(
                  value: page,
                  child: Text('$page'),
                ))
            .toList(),
        onChanged: (selectedPage) {
          setState(() {
            sectionTypesValues[1] = selectedPage ?? 1;
          });
        });
  }

//* method to build the dropdownButton to select the hizb section
  DropdownButton<int> _buildHizbSectionDropDown() {
    return DropdownButton<int>(
        borderRadius: BorderRadius.circular(20),
        hint: Text(context.translate.select_surah),
        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        elevation: 6,
        underline: const SizedBox(),
        isDense: true,
        value: sectionTypesValues[3],
        items: List<int>.generate(60, (index) => index + 1)
            .map((hizb) => DropdownMenuItem<int>(
                  value: hizb,
                  child: Text('$hizb'),
                ))
            .toList(),
        onChanged: (selectedHizb) {
          setState(() {
            sectionTypesValues[3] = selectedHizb ?? 1;
          });
        });
  }

//* method to build the dropdownButton to select the hizb section
  DropdownButton<int> _buildJuzSectionDropDown() {
    return DropdownButton<int>(
        borderRadius: BorderRadius.circular(20),
        hint: Text(context.translate.select_surah),
        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        elevation: 6,
        underline: const SizedBox(),
        isDense: true,
        value: sectionTypesValues[4],
        items: List<int>.generate(30, (index) => index + 1)
            .map((hizb) => DropdownMenuItem<int>(
                  value: hizb,
                  child: Text('$hizb'),
                ))
            .toList(),
        onChanged: (selectedJuz) {
          setState(() {
            sectionTypesValues[4] = selectedJuz ?? 1;
          });
        });
  }

  Card _buildAyahRepeatControls() {
    return Card(
      color: context.theme.brightness == Brightness.dark ? AppColors.cardBgDark : AppColors.tabBackground,
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
              value: ayahRepeatCount,
              onIncrement: () {
                if (ayahRepeatCount < 10) {
                  setState(() {
                    ayahRepeatCount++;
                  });
                }
              },
              onDecrement: () {
                if (ayahRepeatCount != 0) {
                  setState(() {
                    ayahRepeatCount--;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  void _feedPlayerWithAudios() {
    SectionRepeatType sectionRepeatType = SectionRepeatType.page;
    switch (currentSection) {
      case 0:
        sectionRepeatType = SectionRepeatType.custom;
        break;
      case 1:
        sectionRepeatType = SectionRepeatType.page;
        break;
      case 2:
        sectionRepeatType = SectionRepeatType.surah;
        break;
      case 3:
        sectionRepeatType = SectionRepeatType.hizb;
        break;
    }
    int? ayahStart;
    int? ayahEnd;
    if (sectionRepeatType == SectionRepeatType.custom) {
      if (ayatForCustomRange.any((element) => element == null)) {
        AppConstants.showToast(context, msg: context.translate.please_select_ayat_range_first, color: Colors.red);
        return;
      } else {
        List<AyahModel> allAyat = context.read<ListeningCubit>().allAyat;
        ayahStart = allAyat.singleWhere((ayah) => ayah.numberInSurah == ayatForCustomRange[0] && ayah.surahNumber == swarForCustomRange[0]!.number!).number;
        ayahEnd = allAyat.singleWhere((ayah) => ayah.numberInSurah == ayatForCustomRange[1] && ayah.surahNumber == swarForCustomRange[1]!.number!).number;
        debugPrint("ayahStart:$ayahStart, ayahEnd:$ayahEnd");
      }
    }
    context.read<ListeningCubit>().listenToCurrentPage(
        repeatType: sectionRepeatType, sectionValue: currentSection != 0 ? sectionTypesValues[currentSection] : null, ayatForCustomRange: [ayahStart, ayahEnd], sectionRepeatCount: isTorepeatSection ? sectionRepeatCount : null, ayahRepeatCount: isTorepeatAyah ? ayahRepeatCount : null);
  }
}

class ControlButtonsRow extends StatefulWidget {
  const ControlButtonsRow({super.key});

  @override
  State<ControlButtonsRow> createState() => _ControlButtonsRowState();
}

class _ControlButtonsRowState extends State<ControlButtonsRow> {
  double timeValue = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //todo: choose sheikh from here
        InkWell(
          onTap: () {
            ListeningCubit.get(context).showChooseShiekh();
          },
          child: BlocBuilder<ListeningCubit, ListeningState>(
            builder: (context, state) {
              var cubit = ListeningCubit.get(context);
              ReciterModel? currentReciter = cubit.currentReciter;
              if (currentReciter == null) {
                return const SizedBox(
                  height: 30,
                  width: 50,
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(currentReciter.photo.toString()),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    currentReciter.nameArabic.toString(),
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: context.theme.primaryIconTheme.color,
                  )
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        //todo: audio control utton here
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //todo: broadcast icon
                // IconButton(
                //     onPressed: () async {
                //       // await context.read<ListeningCubit>().player.stop();
                //       // context.read<ListeningCubit>().listenToRadio();
                //     },
                //     icon: SvgPicture.asset(
                //       AppAssets.live,
                //       height: 20,
                //       color: context.theme.brightness == Brightness.dark
                //           ? Colors.white
                //           : null,
                //     )),
                const SizedBox(width: 15),
                //todo: forward icon
                StreamBuilder<int?>(
                    stream: context.read<ListeningCubit>().player.currentIndexStream,
                    builder: (context, snapshot) {
                      var currentIndex = snapshot.data;
                      bool hasNext = false;
                      if (currentIndex != null) {
                        hasNext = context.read<ListeningCubit>().player.hasNext;
                      }
                      return Opacity(
                        opacity: hasNext ? 1.0 : 0.5,
                        child: IconButton(
                            onPressed: () async {
                              await context.read<ListeningCubit>().player.seekToNext();
                            },
                            icon: SvgPicture.asset(
                              AppAssets.next,
                              height: 25,
                              color: context.theme.brightness == Brightness.dark ? Colors.white : null,
                            )),
                      );
                    }),
                //todo: play icon
                ControlButtons(context.read<ListeningCubit>().player),
                //todo: previous icon
                StreamBuilder<int?>(
                    stream: context.read<ListeningCubit>().player.currentIndexStream,
                    builder: (context, snapshot) {
                      var currentIndex = snapshot.data;
                      bool hasPrevious = false;
                      if (currentIndex != null) {
                        hasPrevious = context.read<ListeningCubit>().player.hasPrevious;
                      }
                      return Opacity(
                        opacity: hasPrevious ? 1.0 : 0.5,
                        child: IconButton(
                            onPressed: () async {
                              await context.read<ListeningCubit>().player.seekToPrevious();
                            },
                            icon: SvgPicture.asset(
                              AppAssets.prev,
                              height: 25,
                              color: context.theme.brightness == Brightness.dark ? Colors.white : null,
                            )),
                      );
                    }),
                //todo: repeat icon
                IconButton(
                    onPressed: () async {
                      setState(() {
                        ListeningCubit.get(context).showChooseRepeat();
                      });
                    },
                    icon: SvgPicture.asset(
                      AppAssets.repeat,
                      height: 17,
                      color: context.theme.brightness == Brightness.dark ? Colors.white : null,
                    )),
              ],
            ),
          ),
        ), //todo: slider and timeStamps here
        StreamBuilder<Duration>(
            stream: context.read<ListeningCubit>().player.positionStream,
            builder: (context, snapshot) {
              if (snapshot.data != null && context.read<ListeningCubit>().player.duration != null) {
                Duration? currentPosition = snapshot.data;
                int currentPositonInSeconds = currentPosition!.inSeconds;
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Slider(
                        min: 0,
                        max: context.read<ListeningCubit>().player.duration!.inSeconds + 0.0,
                        label: "${currentPosition.inMinutes}:${currentPositonInSeconds % 60}",
                        value: currentPositonInSeconds + 0.0,
                        onChanged: (seekToVlaue) {
                          context.read<ListeningCubit>().player.seek(Duration(seconds: seekToVlaue.round()));
                        },
                      ),
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
                                encodeTimestamp(context.read<ListeningCubit>().player.position),
                                style: context.textTheme.bodyMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                encodeTimestamp(context.read<ListeningCubit>().player.duration),
                                style: context.textTheme.bodyMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            })
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
    this.dropDownWidget,
  }) : super(key: key);
  final void Function() onIncrement;
  final void Function() onDecrement;
  final int value;
  final String title;
  final Widget? dropDownWidget;

  @override
  Widget build(BuildContext context) {
    var incrementAndDecrement = [
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
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          if (dropDownWidget != null) dropDownWidget!,
          if (dropDownWidget == null)
            Text(
              "$value",
              style: context.textTheme.bodyMedium!.copyWith(fontSize: 14),
            ),
          const Spacer(),
          Container(
              height: 35,
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark ? AppColors.cardBgActiveDark : AppColors.beige,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: context.translate.localeName == AppStrings.arabicCode ? incrementAndDecrement : incrementAndDecrement.reversed.toList(),
              ))
        ],
      ),
    );
  }
}

class AyatRangeSelectorWidget extends StatefulWidget {
  AyatRangeSelectorWidget({super.key, required this.onCustomRangeChanged, required this.savedSelectedAyat, required this.savedSelectedSwar});
  void Function(List<SurahFihrisModel?> swar, List<int?> ayat) onCustomRangeChanged;
  final List<SurahFihrisModel?> savedSelectedSwar;
  final List<int?> savedSelectedAyat;

  @override
  State<AyatRangeSelectorWidget> createState() => _AyatRangeSelectorWidgetState();
}

class _AyatRangeSelectorWidgetState extends State<AyatRangeSelectorWidget> {
  List<SurahFihrisModel?> selectedSwar = [null, null];
  List<int?> selectedAyat = [null, null];

  @override
  void initState() {
    selectedSwar = widget.savedSelectedSwar;
    selectedAyat = widget.savedSelectedAyat;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index in [0, 1]) _buildAyahSelectorRow(context, index: index)
        ],
      ),
    );
  }

  Widget _buildAyahSelectorRow(BuildContext context, {required int index}) {
    List<SurahFihrisModel> allSwar = context.read<EssentialMoshafCubit>().swarListForFihris;
    List<int> ayatToChooseFrom = selectedSwar[0] == null || selectedSwar[index] == null
        ? []
        : index == 1 && selectedSwar[0] == selectedSwar[1] && selectedAyat[0] != null
            ? List<int>.generate(selectedSwar[0]!.count! - selectedAyat[0]! + 1, (index) => index + selectedAyat[0]!).toList()
            : List<int>.generate(selectedSwar[index]!.count!, (index) => index + 1);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            index == 0 ? context.translate.from_surah : context.translate.to_surah,
            style: const TextStyle(fontSize: 13),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark ? AppColors.cardBgActiveDark : AppColors.beige,
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButton<SurahFihrisModel>(
                  borderRadius: BorderRadius.circular(20),
                  hint: Text(context.translate.select_surah),
                  style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  elevation: 6,
                  underline: const SizedBox(),
                  isDense: true,
                  isExpanded: true,
                  value: selectedSwar[index],
                  items: (index == 0
                          ? allSwar
                          : selectedSwar[0] != null && index == 1
                              ? allSwar.getRange(allSwar.indexOf(selectedSwar[0]!), allSwar.length).toList()
                              : [])
                      .map((surah) => DropdownMenuItem<SurahFihrisModel>(
                            value: surah,
                            child: Text('${surah.name}'.replaceAll(RegExp(r"سورة"), '')),
                          ))
                      .toList(),
                  onChanged: (selectedSurah) {
                    setState(() {
                      //* if the new selected surah is equal to previously selected then do nothing.
                      if (selectedSurah == selectedSwar[index] && selectedSwar[index] != null) {
                        return;
                      }
                      //* if the new selected surah is different than previously selected then nullize the ayah number

                      else if (selectedSurah != selectedSwar[index]) {
                        selectedAyat[index] = null;
                        selectedSwar[index] = selectedSurah;
                        //* and if you are editing the [fromSurah] value then nullize the [toSurah,toAyah] values too.
                        if (index == 0) {
                          selectedAyat[1] = null;
                          selectedSwar[1] = null;
                        }
                      }
                    });
                    widget.onCustomRangeChanged(selectedSwar, selectedAyat);
                  }),
            ),
          ),
          Text(
            context.translate.ayah_number,
            style: const TextStyle(fontSize: 13),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: context.theme.brightness == Brightness.dark ? AppColors.cardBgActiveDark : AppColors.beige,
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButton<int>(
                  borderRadius: BorderRadius.circular(20),
                  // dropdownColor: context.theme.dividerColor,
                  hint: Text(context.translate.select_ayah),
                  style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  elevation: 6,
                  isExpanded: true,
                  underline: const SizedBox(),
                  isDense: true,
                  value: selectedAyat[index],
                  items: ayatToChooseFrom
                      .map((ayahNumber) => DropdownMenuItem<int>(
                            value: ayahNumber,
                            child: Text('$ayahNumber'),
                          ))
                      .toList(),
                  onChanged: (selectedAyah) {
                    setState(() {
                      selectedAyat[index] = selectedAyah;
                      if (index == 0) {
                        selectedAyat[1] = null;
                        selectedSwar[1] = null;
                      }
                    });
                    widget.onCustomRangeChanged(selectedSwar, selectedAyat);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
