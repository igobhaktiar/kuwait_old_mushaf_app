import 'dart:developer';
import 'dart:io';
import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/ayatHighlight/data/models/ahyah_segs_model.dart' show AyahSegsModel;
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart' show AyatHighlightCubit, AyatHighlightState;
import 'package:quran_app/features/bookmarks/presentation/widgets/add_bookmark_or_fav_dialog.dart' show showAyahOptionsDialog;
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart' show AyahModel;
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart' show EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/current_page_metadata_widgets.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/ordinary_moshaf_image.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/ten_readings_image.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';

class QuranPageWidget extends StatefulWidget {
  const QuranPageWidget({
    super.key,
    required this.index,
    required this.actualWidth,
    required this.actualHeight,
    required this.leftPadding,
    required this.rightPadding,
  });

  final int index;
  final double actualWidth;
  final double actualHeight;
  final double rightPadding;
  final double leftPadding;

  @override
  State<QuranPageWidget> createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  File? lastPageImage;
  List<KhelafiaWordModel>? wordsToHighlight = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
      listener: (context, state) {},
      builder: (context, state) {
        final essentialCubit = context.read<EssentialMoshafCubit>();

        return BlocConsumer<TenReadingsCubit, TenReadingsState>(
          listener: (BuildContext context, TenReadingsState tenState) {
            if (tenState is TenreadingsServicesLoaded && context.read<EssentialMoshafCubit>().currentMoshafType != MoshafTypes.TEN_READINGS) {
              context.read<EssentialMoshafCubit>().changeMoshafType(MoshafTypes.TEN_READINGS);
            } else if (tenState is TenreadingsServicesLoaded && context.read<EssentialMoshafCubit>().currentMoshafType == MoshafTypes.TEN_READINGS) {
              if (lastPageImage == null || (lastPageImage != null && lastPageImage!.path != tenState.coloredImageFile!.path && tenState.khelfiaWords != null && tenState.khelfiaWords!.length != wordsToHighlight!.length)) {
                lastPageImage = tenState.coloredImageFile;
                wordsToHighlight = tenState.khelfiaWords;
              }
            }

            if (tenState is TenreadingsServicesLoaded && tenState.clickedWord != null) {
              context.read<EssentialMoshafCubit>().showFlyingLayers();
              context.read<BottomSheetCubit>().changeViewIndex(0);
            }
          },
          buildWhen: (TenReadingsState prev, TenReadingsState cur) => (cur is TenreadingsServicesLoaded),
          builder: (BuildContext context, TenReadingsState tenState2) {
            if (tenState2 is TenreadingsServicesLoaded) {}
            final tenCubit = context.read<TenReadingsCubit>();
            return BlocListener<ListeningCubit, ListeningState>(
              listener: (BuildContext context, ListeningState state) {
                if (state is ChangeHighlightedAyah) {
                  context.read<AyatHighlightCubit>().highlightPlayingAyah(state.currentlyPlayedAyah);
                } else if (state is PlayerStopped) {
                  final currentPage = context.read<EssentialMoshafCubit>().currentPage + 1;
                  context.read<AyatHighlightCubit>().loadAyatSegs(currentPage);
                }
              },
              child: BlocBuilder<AyatHighlightCubit, AyatHighlightState>(
                builder: (context, state) {
                  return MediaQuery(
                    data: MediaQuery.of(context),
                    child: GestureDetector(
                      onTap: () {
                        context.read<EssentialMoshafCubit>().togglePageNavigationOrFlying();

                        context.read<EssentialMoshafCubit>().toggleBottomSheetSection();
                        if (!context.read<EssentialMoshafCubit>().isInTenReadingsMode()) {
                          context.read<BottomSheetCubit>().changeViewIndex(1);
                        }
                      },
                      child: Container(
                        width: widget.actualWidth,
                        height: MediaQuery.of(context).orientation == Orientation.landscape ? widget.actualWidth / AppConstants.moshafPageAspectRatio : widget.actualHeight,
                        padding: context.read<EssentialMoshafCubit>().isToShowTopBottomNavListViews
                            ? const EdgeInsets.symmetric(
                                vertical: 35,
                                horizontal: 35,
                              )
                            : EdgeInsets.zero,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CurrentJuzFrameWidget(),
                                  CurrentSurahFrameWidget(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  height: widget.actualWidth / AppConstants.moshafPageAspectRatio,
                                  child: Builder(
                                    builder: (BuildContext context) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          checkTenReadingsOrOrdinary(context, tenCubit, tenState2),
                                          if (!essentialCubit.isToShowTopBottomNavListViews)
                                            ..._buildHighlights(
                                              context,
                                              state.highlights,
                                              MediaQuery.of(context).orientation == Orientation.landscape,
                                              target: state.currentlyHighlight,
                                            ),
                                          if (!essentialCubit.isToShowTopBottomNavListViews && essentialCubit.currentMoshafType == MoshafTypes.TEN_READINGS)
                                            if (tenState2 is TenreadingsServicesLoaded && tenState2.khelfiaWords != null)
                                              ..._buildTenReadingsWordsHighlights(
                                                context,
                                                wordsToHighlight!,
                                                tenState2,
                                              ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CurrentHizbFrameWidget(),
                                  CurrentPageFrameWidget(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  StatelessWidget checkTenReadingsOrOrdinary(BuildContext context, TenReadingsCubit tenCubit, TenReadingsState tenState2) {
    return checkScreen(context, tenCubit, tenState2)
        ? TenReadingsImage(
            tenCubit: tenCubit,
            widget: widget,
            state: tenState2,
          )
        : OrdinaryMoshafImage(widget: widget);
  }

  bool checkScreen(BuildContext context, TenReadingsCubit tenCubit, TenReadingsState tenState2) {
    final moshafType = context.read<EssentialMoshafCubit>().currentMoshafType;
    final isColoredPageExists = File("${tenCubit.coloredImagesSubFolderPath}${AppStrings.getColoredImageFileName(widget.index + 1)}").existsSync();
    return (moshafType == MoshafTypes.TEN_READINGS && ((tenCubit.coloredImagesSubFolderPath.isNotEmpty && isColoredPageExists) || tenState2 is TenreadingsServicesLoaded));
  }

  List<Widget> _buildHighlights(BuildContext mainContext, List<AyahSegsModel> lineHighlights, bool isLandscape, {AyahModel? target}) {
    //*scaling factors

    double imageWidth = (((widget.actualWidth) / AppConstants.moshafPageAspectRatio) - AppConstants.clippedPortionFromQuranScreen) * AppConstants.moshafPageAspectRatio;
    log("imageWidth:$imageWidth");

    log("salem= ${widget.leftPadding} + ${widget.rightPadding}");
    double maxFactor = max(((widget.rightPadding + widget.leftPadding > 0.0 ? widget.actualWidth : imageWidth) / 1352), ((widget.actualHeight - AppConstants.clippedPortionFromQuranScreen) / 2170));

    double minFactor = min(((widget.actualWidth) / 1352), ((widget.actualHeight - AppConstants.clippedPortionFromQuranScreen) / 2170));

    log("maxSize:$maxFactor, minSize:$minFactor");

    double heightScaleFactor = isLandscape ? maxFactor : minFactor;

    double widthScaleFactor = isLandscape ? maxFactor : minFactor;
    //with width

    log("scaleFactor=$widthScaleFactor");

    List<Widget> outputList = [];

    for (var highlight in lineHighlights) {
      highlight.segs?.sort((a, b) => a.y!.compareTo(b.y!));
      for (final seg in highlight.segs!) {
        //************************************/

        // if (![-1, 0].contains(highlight.segs!.indexOf(seg))) {
        //seg is not the first in the ayah
        //   var segIndex = highlight.segs!.indexOf(seg);
        //   if (seg.y! - highlight.segs![segIndex - 1].y! < 35) {
        //     // sourceHighlighterTop = highlight.segs![segIndex - 1].y! + 37;
        //     // sourceHighlighterHight = 30;
        //   }
        // }
        var destHighlighterTop = (seg.y!) * heightScaleFactor;
        //  (sourceHighlighterTop).toDouble() *
        //     heightScaleFactor *
        //     (1352 / 2170);
        final destHighlighterHeight = seg.h! * heightScaleFactor;
        // var destHighlighterHeight = 50 * heightScaleFactor * 0.5;
        //************************************/
        outputList.add(
          Positioned(
            top: destHighlighterTop, //todo top
            left: (seg.x!).toDouble() * widthScaleFactor, //todo left
            child: SizedBox(
              // *scaleFactor //todo height
              width: (seg.w!.toDouble() < 10) ? 0 : (seg.w!).toDouble() * widthScaleFactor,
              // height: 50,
              height: destHighlighterHeight,
              child: GestureDetector(
                onTap: () {
                  mainContext.read<EssentialMoshafCubit>().togglePageNavigationOrFlying();

                  if (!context.read<EssentialMoshafCubit>().isInTenReadingsMode()) {
                    context.read<BottomSheetCubit>().changeViewIndex(1);
                  }
                  // // print("highlight.ayaId= ${highlight.ayaId}");
                  // // print("highlight.suraId= ${highlight.segs}");
                  // // print("highlight.ayaId= ${highlight.suraId}");
                },
                onLongPress: () {
                  print('long press');
                  if (context.read<EssentialMoshafCubit>().isInTenReadingsMode()) {
                    context.read<EssentialMoshafCubit>().showBottomSheetSections();
                  } else {
                    showAyahOptionsDialog(
                      mainContext,
                      EssentialMoshafCubit.get(mainContext)
                          .allAyatWithTashkeelList
                          .where(
                            (ayah) => highlight.ayaId == ayah.numberInSurah && highlight.suraId == EssentialMoshafCubit.get(mainContext).swarListForFihris.where((surah) => surah.number == ayah.surahNumber).toList().single.number,
                          )
                          .toList()
                          .single,
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: target != null && target.numberInSurah == highlight.ayaId && target.surahNumber == highlight.suraId
                          // highlight.ayaId != 16
                          ? AppColors.ayahHighlightColor.withOpacity(0.55)
                          : Colors.red.withOpacity(0.0051),
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
          ),
        );
      }
    }
    log("outputList.length= ${outputList.length}");
    return outputList;
  }

  List<Widget> _buildTenReadingsWordsHighlights(BuildContext context, List<KhelafiaWordModel> kalematList, TenreadingsServicesLoaded state) {
    double sideMargin = context.width * (22 / 1024);
    double topMargin = 100;
    double imageWidth = ((widget.actualWidth / AppConstants.moshafPageAspectRatio) - AppConstants.clippedPortionFromQuranScreen) * AppConstants.moshafPageAspectRatio;
    log("imageHeight:$imageWidth");

    double maxFactor = max(((widget.rightPadding + widget.leftPadding > 0.0 ? widget.actualWidth : imageWidth) / 1024), ((widget.actualHeight - AppConstants.clippedPortionFromQuranScreen) / 1656));

    double minFactor = min(((widget.actualWidth - sideMargin) / 1024), ((widget.actualHeight - AppConstants.clippedPortionFromQuranScreen) / 1656));
    log("maxSize:$maxFactor, minSize:$minFactor");

    double heightScaleFactor = context.isLandscape ? maxFactor : minFactor;

    double widthScaleFactor = context.isLandscape ? maxFactor : minFactor;

    // double heightScaleFactor =
    //     (context.width / AppConstants.moshafPageAspectRatio) /
    //         1656; //with height

    // double widthScaleFactor = (context.width - sideMargin) / 1024;

    List<Widget> kalemaHighlights = [];
    for (final kalema in kalematList) {
      kalemaHighlights.add(
        Positioned(
          top: kalema.y!.toDouble() * heightScaleFactor,
          // : kalema.y!.toDouble() * heightScaleFactor + topMargin / 2,
          left: (kalema.x ?? 0).toDouble() * widthScaleFactor, //todo left
          child: SizedBox(
            width: kalema.w!.toDouble() * widthScaleFactor, // *scaleFactor  //todo width
            height: (kalema.h ?? 125.0).toDouble() * heightScaleFactor, // *scaleFactor //todo height

            child: GestureDetector(
              onTap: () {
                context.read<EssentialMoshafCubit>().showBottomSheetSections();
                context.read<BottomSheetCubit>().changeViewIndex(0);
                context.read<TenReadingsCubit>().filterQeraatListOnHighlightClicked(kalema, kalematList);
                if (context.read<EssentialMoshafCubit>().isShowNavigateByPage) {
                  context.read<EssentialMoshafCubit>().hidePagesPopUp();
                }
                context.read<EssentialMoshafCubit>().showFlyingLayers();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: (state.clickedWord != null && (state.clickedWord!.first.wordOrder == kalema.wordOrder || state.clickedWord!.first.wordText == kalema.wordText)) ? AppColors.ayahHighlightColor.withOpacity(0.3) : Colors.blue.withOpacity(0.0041), borderRadius: BorderRadius.circular(5)),
                // child: Text(kalema.wordText!),
              ),
            ),
          ),
        ),
      );
    }
    return kalemaHighlights;
  }
}
