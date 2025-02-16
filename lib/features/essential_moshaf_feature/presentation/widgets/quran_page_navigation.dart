import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/quran_page_widget.dart'
    show QuranPageWidget;
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart'
    show
        CheckYourInternetConnection,
        ContentNotAvailableState,
        TenReadingCheckingForUpdates,
        TenReadingsCubit,
        TenReadingsState,
        TenreadingLoading,
        TenreadingsFilesMustBeDownloadedFirstPromptState,
        TenreadingsStartedDownloadingAssets,
        UpdateAppToBenefitFromNewFeatursState;
import 'package:quran_app/features/tenReadings/presentation/dialogs/app_needs_update_dialog.dart';
import 'package:quran_app/features/tenReadings/presentation/dialogs/we_must_download_some_files_first_dialog.dart'
    show showPromptToInformUserThatWeMustDownloadSomeFilesFirst;
import 'package:quran_app/l10n/localization_context.dart';

import '../../../tenReadings/presentation/dialogs/show_content_not_available_dialog.dart';

//* the main Navigation pageView widget
class QuranPageView extends StatefulWidget {
  const QuranPageView({
    super.key,
    required this.pageViewKey,
    required this.actualWidth,
    required this.actualHeight,
    required this.leftPadding,
    required this.rightPadding,
  });
  final GlobalKey pageViewKey;
  final double actualWidth;
  final double actualHeight;
  final double leftPadding;
  final double rightPadding;

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  @override
  Widget build(BuildContext context) {
    // return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
    //   listener: (context, state) {
    //     log("form Essential listener i changed Highlights♥👌");
    //     // AyatHighlightCubit.get(context).loadCurrentPageAyatSeg(
    //     //     EssentialMoshafCubit.get(context).currentPage + 1);
    //   },
    //   builder: (context, state) {
    return BlocListener<TenReadingsCubit, TenReadingsState>(
      listener: (context, tenState) {
        if (context
            .read<EssentialMoshafCubit>()
            .currentMoshafType ==
            MoshafTypes.TEN_READINGS) {
          if (context
              .read<TenReadingsCubit>()
              .checkIfCurrentPageIsBeingDownloaded()) {
            AppConstants.showToast(context,
                msg: context.translate.this_page_is_being_downloaded);
            context
                .read<EssentialMoshafCubit>()
                .changeMoshafTypeToOrdinary();
            return;
          }
        }
        if (tenState is TenReadingCheckingForUpdates) {
          AppConstants.showToast(context,
              msg: context.translate.checking_for_updates);
        }
        if (tenState is TenreadingsStartedDownloadingAssets) {
          AppConstants.showToast(context,
              msg: context.translate.downloading_files_in_the_background);
        }
        if (tenState is UpdateAppToBenefitFromNewFeatursState) {
          showAppNeedsUpdateDialog(context);
        }
        if (tenState is CheckYourInternetConnection) {
          if (tenState.showAlertDialog) {
            showContentNotAvailableDialog(context,
                msg: context.translate.check_your_internet_connection);
          } else {
            AppConstants.showToast(context,
                msg: context.translate.check_your_internet_connection);
          }
        }

        if (tenState is ContentNotAvailableState) {
          showContentNotAvailableDialog(context);
        }
        if (tenState is TenreadingsFilesMustBeDownloadedFirstPromptState) {
          showPromptToInformUserThatWeMustDownloadSomeFilesFirst(context);
        }
      },
      child: PageView.builder(
          key: widget.pageViewKey,
          controller:
          EssentialMoshafCubit
              .get(context)
              .moshafPageController,
          itemCount: 604,
          // itemCount: 60,
          onPageChanged: (index) async {
            context
                .read<EssentialMoshafCubit>()
                .navigateToPage(index + 1, jumpToPage: false);
            AyatHighlightCubit.get(context).loadAyatSegs(index + 1);
            context.read<ListeningCubit>().changeCurrentPage(index + 1);
            context.read<TafseerCubit>().loadCurrentPageTafseer(index + 1);
            context.read<TenReadingsCubit>().changeCurrentPage(index + 1);
            if (context
                .read<EssentialMoshafCubit>()
                .isInTenReadingsMode()) {
              context
                  .read<TenReadingsCubit>()
                  .readDownloadedJsonFilesForCurrrentPage();
            }
          },
          itemBuilder: (context, index) =>
              QuranPageWidget(
                  actualHeight: widget.actualHeight,
                  actualWidth: widget.actualWidth,
                  leftPadding: widget.leftPadding,
                  rightPadding: widget.rightPadding,
                  index: index)),
    );
  }
  //     },
  //   );
  // }
}
