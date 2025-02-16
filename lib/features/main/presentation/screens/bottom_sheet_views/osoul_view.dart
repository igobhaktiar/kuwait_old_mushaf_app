import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../tenReadings/data/models/khelafia_word_model.dart';
import '../../../../tenReadings/presentation/cubit/tenreadings_cubit.dart';

class OsoulView extends StatelessWidget {
  const OsoulView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenReadingsCubit, TenReadingsState>(
      buildWhen: (prev, cur) {
        return prev != cur && cur is TenreadingsServicesLoaded;
      },
      builder: (context, state) {
        if (state is TenreadingsServicesLoaded ||
            context.read<TenReadingsCubit>().lastServicesStateLoaded != null) {
          List<OsoulModel> stateOsoul =
              state is TenreadingsServicesLoaded && state.osoul != null
                  ? state.osoul!
                  : [];

          List<OsoulModel> lastOsoul = context
                          .read<TenReadingsCubit>()
                          .lastServicesStateLoaded !=
                      null &&
                  context
                          .read<TenReadingsCubit>()
                          .lastServicesStateLoaded!
                          .osoul !=
                      null
              ? context.read<TenReadingsCubit>().lastServicesStateLoaded!.osoul!
              : [];

          List<OsoulModel> osoulModelsList =
              state is TenreadingsServicesLoaded ? stateOsoul : lastOsoul;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: osoulModelsList.isNotEmpty
                ? Column(
                    children: [
                      const ViewDashIndicator(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(10),
                          child: Card(
                              color: context.theme.brightness == Brightness.dark
                                  ? AppColors.osoulCellBgDark
                                  : AppColors.tabBackground,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                //outer border for the table
                                side: BorderSide(
                                  width: 1.0,
                                  color: context.theme.brightness ==
                                          Brightness.dark
                                      ? Colors.grey
                                      : AppColors.inactiveColor,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  if (osoulModelsList != null)
                                    for (var osoulItemModel in osoulModelsList)
                                      Container(
                                        decoration: BoxDecoration(
                                          //topbottom border for cells
                                          border: Border.symmetric(
                                              horizontal: BorderSide(
                                            width: 0.5,
                                            color: context.theme.brightness ==
                                                    Brightness.dark
                                                ? Colors.grey
                                                : AppColors.inactiveColor,
                                          )),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                // width: context.width * 0.3,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 10),

                                                //todo: right section here
                                                child: RichText(
                                                    text: TextSpan(children: [
                                                  for (var singleChar
                                                      in osoulItemModel
                                                          .keyChars!)
                                                    if (singleChar.unicode !=
                                                        null)
                                                      TextSpan(
                                                          text: addTapOrNewLine(
                                                              singleChar),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                singleChar
                                                                    .fontFamily,
                                                            fontWeight: singleChar
                                                                .getFontWeight(),
                                                            fontSize: singleChar
                                                                    .size! *
                                                                1.5,
                                                            color: context
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : singleChar
                                                                    .color!
                                                                    .getColor(),
                                                          ))
                                                ])),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 10),
                                                decoration: _buildCellBorder(
                                                    context,
                                                    isRightBorder: true),
                                                //todo: left section
                                                child: RichText(
                                                    text: TextSpan(children: [
                                                  for (var singleChar
                                                      in osoulItemModel
                                                          .valueChars!)
                                                    if (singleChar.unicode !=
                                                        null)
                                                      TextSpan(
                                                          text: addTapOrNewLine(
                                                              singleChar),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                singleChar
                                                                    .fontFamily,
                                                            fontWeight: singleChar
                                                                .getFontWeight(),
                                                            fontSize: singleChar
                                                                    .size! *
                                                                1.5,
                                                            color: context
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : singleChar
                                                                    .color!
                                                                    .getColor(),
                                                          ))
                                                ])),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  )
                : CenteredEmptyListMsgWidget(
                    msg: context.translate.no_osoul_in_this_page),
          );
        } else {
          return const EmptyViewWidget();
        }
      },
    );
  }

  BoxDecoration _buildCellBorder(BuildContext context,
      {bool isRightBorder = false}) {
    return BoxDecoration(
      border: Border(
        left: isRightBorder
            ? BorderSide.none
            : BorderSide(
                width: 1.0,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.grey
                    : AppColors.inactiveColor,
              ),
        right: isRightBorder
            ? BorderSide(
                width: 1.0,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.grey
                    : AppColors.inactiveColor,
              )
            : BorderSide.none,
      ),
    );
  }
}

class EmptyViewWidget extends StatelessWidget {
  const EmptyViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(
          Icons.refresh,
          size: 35,
        ),
        onPressed: () {
          context
              .read<TenReadingsCubit>()
              .readDownloadedJsonFilesForCurrrentPage();
        },
      ),
    );
  }
}
