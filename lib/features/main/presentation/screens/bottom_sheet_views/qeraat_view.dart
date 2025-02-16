import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/osoul_view.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import 'package:quran_app/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../listening/presentation/cubit/listening_cubit.dart';
import 'bookmarksview.dart';

class QeraaatView extends StatefulWidget {
  const QeraaatView({
    Key? key,
  }) : super(key: key);

  @override
  State<QeraaatView> createState() => _QeraaatViewState();
}

class _QeraaatViewState extends State<QeraaatView> {
  List<KhelafiaWordModel> currentKhelafiaWordsModelsListToShow = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenReadingsCubit, TenReadingsState>(
      buildWhen: (prev, cur) => cur is TenreadingsServicesLoaded,
      builder: (context, state) {
        if (state is TenreadingsServicesLoaded) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: _kalematToShow(state).isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.khelfiaWords != null)
                          for (var currrentKhelafiaWord
                              in _kalematToShow(state))
                            KalemahKhelafiaWordWidget(
                                currrentKhelafiaWord: currrentKhelafiaWord),
                      ],
                    ),
                  )
                : CenteredEmptyListMsgWidget(
                    msg: context.translate.no_kalemat_khelafia_in_this_page),
          );
        } else {
          return const EmptyViewWidget();
        }
      },
    );
  }

  List<KhelafiaWordModel> _kalematToShow(TenReadingsState state) {
    List<KhelafiaWordModel> filteredKhelafiaWordsModelsList = [];
    if (state is TenreadingsServicesLoaded) {
      var khelafiaWordsModelsList =
          state.clickedWord ?? state.khelfiaWords ?? <KhelafiaWordModel>[];

      filteredKhelafiaWordsModelsList = khelafiaWordsModelsList.toList();
      //step1 sort by word order
      filteredKhelafiaWordsModelsList
          .sort((a, b) => a.wordOrder!.compareTo(b.wordOrder!));

      // step2 createe the distinct list of items
      var tempList = <KhelafiaWordModel>[];
      for (var element in filteredKhelafiaWordsModelsList) {
        if (!tempList.any((item) => item.wordText == element.wordText)) {
          tempList.add(element);
        }
      }
      filteredKhelafiaWordsModelsList = tempList;

      return filteredKhelafiaWordsModelsList;
    } else {
      return [];
    }
  }
}

class KalemahKhelafiaWordWidget extends StatelessWidget {
  const KalemahKhelafiaWordWidget({
    Key? key,
    required this.currrentKhelafiaWord,
  }) : super(key: key);

  final KhelafiaWordModel currrentKhelafiaWord;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    if (currrentKhelafiaWord.titleUnicodeCharsList != null)
                      for (CharPropertiesModel singleChar
                          in currrentKhelafiaWord.titleUnicodeCharsList!)
                        TextSpan(
                            text: addTapOrNewLine(singleChar),
                            style: TextStyle(
                              overflow: TextOverflow.visible,
                              wordSpacing: 0.5,
                              leadingDistribution:
                                  TextLeadingDistribution.proportional,
                              letterSpacing: 0.5,
                              height: 1.5,
                              fontFamily: singleChar.fontFamily,
                              fontWeight: singleChar.getFontWeight(),
                              fontSize: singleChar.size! * 1.5,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : singleChar.color!.getColor(),
                            ))
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 0),
        for (var singleQera2a in currrentKhelafiaWord.qeraat!)
          QeraahLineUnderHeader(sinngleQeraaModel: singleQera2a),
        AppConstants.appDivider(context),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class QeraahLineUnderHeader extends StatefulWidget {
  const QeraahLineUnderHeader({
    Key? key,
    required this.sinngleQeraaModel,
  }) : super(key: key);
  final SingleQeraaModel sinngleQeraaModel;

  @override
  State<QeraahLineUnderHeader> createState() => _QeraahLineUnderHeaderState();
}

class _QeraahLineUnderHeaderState extends State<QeraahLineUnderHeader> {
  bool isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocConsumer<TenReadingsCubit, TenReadingsState>(
            listener: (context, state) {
              if (state is ChangeCurrentPlayingQeraaFileState &&
                  state.qeraaBeingPlayed == widget.sinngleQeraaModel) {
                setState(() {
                  isPlaying = true;
                });
              } else {
                setState(() {
                  isPlaying = false;
                });
              }
            },
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: () {
                    if (widget.sinngleQeraaModel.file != null) {
                      context.read<ListeningCubit>().pausePlayer();
                      context
                          .read<TenReadingsCubit>()
                          .playQeraaFile(widget.sinngleQeraaModel);
                    } else {
                      AppConstants.showToast(context, msg: "الملف غير موجود");
                    }
                  },
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: isPlaying
                        ? AppColors.inactiveColor
                        : context.isDarkMode
                            ? Colors.white
                            : AppColors.activeButtonColor,
                    child: Center(
                      child: isPlaying
                          ? const Icon(
                              Icons.stop,
                              color: AppColors.white,
                              size: 16,
                            )
                          : SvgPicture.asset(
                              AppAssets.listen,
                              color: context.isDarkMode
                                  ? AppColors.scaffoldBgDark
                                  : null,
                              width: 11,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
                // strutStyle:
                //     const StrutStyle(height: 0.8, forceStrutHeight: true),
                text: TextSpan(children: [
              if (widget.sinngleQeraaModel.unicodeCharsList != null)
                for (CharPropertiesModel singleChar
                    in widget.sinngleQeraaModel.unicodeCharsList!)
                  TextSpan(
                      text: singleChar.unicode!.contains(RegExp(r"\n|\t"))
                          ? "--"
                          : addTapOrNewLine(singleChar),
                      style: TextStyle(
                        fontFamily: singleChar.fontFamily,
                        fontSize: singleChar.size! * 1.5,
                        fontWeight: singleChar.getFontWeight(),
                        color: context.isDarkMode
                            ? Colors.white
                            : singleChar.color!.getColor(),
                      ))
            ])),
          ),
        ],
      ),
    );
  }
}
