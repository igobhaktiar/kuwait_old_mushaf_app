import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/osoul_view.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import 'package:quran_app/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../tenReadings/presentation/cubit/tenreadings_cubit.dart';

class MarginsView extends StatelessWidget {
  const MarginsView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenReadingsCubit, TenReadingsState>(
      buildWhen: (prev, cur) => cur is TenreadingsServicesLoaded,
      builder: (context, state) {
        if (state is TenreadingsServicesLoaded ||
            context.read<TenReadingsCubit>().lastServicesStateLoaded != null) {
          List<HwamishModel> stateHwamish =
              state is TenreadingsServicesLoaded && state.hwamishModel != null
                  ? state.hwamishModel!
                  : [];

          List<HwamishModel> lastHwamish =
              context.read<TenReadingsCubit>().lastServicesStateLoaded !=
                          null &&
                      context
                              .read<TenReadingsCubit>()
                              .lastServicesStateLoaded!
                              .hwamishModel !=
                          null
                  ? context
                      .read<TenReadingsCubit>()
                      .lastServicesStateLoaded!
                      .hwamishModel!
                  : [];

          List<HwamishModel> hwamishModelsList =
              state is TenreadingsServicesLoaded ? stateHwamish : lastHwamish;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: hwamishModelsList.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: hwamishModelsList != null
                        ? hwamishModelsList.length
                        : 0,
                    itemBuilder: (context, index) {
                      var currrentHamishModel = hwamishModelsList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: RichText(
                            text: TextSpan(children: [
                          for (CharPropertiesModel singleChar
                              in currrentHamishModel.hamishLine!)
                            TextSpan(
                                text:
                                    "${addTapOrNewLine(singleChar)}${singleChar.unicode == ':' ? '\n' : ''}",
                                style: TextStyle(
                                  fontFamily: singleChar.fontFamily,
                                  fontWeight: singleChar.getFontWeight(),
                                  fontSize: singleChar.size! * 1.5,
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : singleChar.color!.getColor(),
                                ))
                        ])),
                      );
                    })
                : CenteredEmptyListMsgWidget(
                    msg: context.translate.no_hwamish_in_this_page),
          );
        } else {
          return const EmptyViewWidget();
        }
      },
    );
  }
}
