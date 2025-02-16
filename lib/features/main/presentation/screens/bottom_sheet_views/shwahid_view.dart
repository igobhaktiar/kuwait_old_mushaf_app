import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/osoul_view.dart';
import 'package:quran_app/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart'
    show TenReadingsCubit, TenReadingsState, TenreadingsServicesLoaded;
import 'package:quran_app/l10n/localization_context.dart';

class ShwahidView extends StatelessWidget {
  const ShwahidView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TenReadingsCubit, TenReadingsState>(
      buildWhen: (prev, cur) => cur is TenreadingsServicesLoaded,
      builder: (context, state) {
        if (state is TenreadingsServicesLoaded ||
            context.read<TenReadingsCubit>().lastServicesStateLoaded != null) {
          List<ShwahidDalalatGroupModel> stateShwahid =
              state is TenreadingsServicesLoaded &&
                      state.shwahidDalalatGroups != null
                  ? state.shwahidDalalatGroups!
                  : [];

          List<ShwahidDalalatGroupModel> lastShwahid =
              context.read<TenReadingsCubit>().lastServicesStateLoaded !=
                          null &&
                      context
                              .read<TenReadingsCubit>()
                              .lastServicesStateLoaded!
                              .shwahidDalalatGroups !=
                          null
                  ? context
                      .read<TenReadingsCubit>()
                      .lastServicesStateLoaded!
                      .shwahidDalalatGroups!
                  : [];

          List<ShwahidDalalatGroupModel> shwahidModelsList =
              state is TenreadingsServicesLoaded ? stateShwahid : lastShwahid;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: shwahidModelsList.isNotEmpty
                ? ListView.separated(
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (context, index) {
                      return AppConstants.appDivider(context);
                    },
                    itemCount: shwahidModelsList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ShwahidDalalatWidget(
                          shahidDalalahItem: shwahidModelsList[index]);
                    })
                : CenteredEmptyListMsgWidget(
                    msg: context.translate.no_shwahid_in_this_page),
          );
        } else {
          return const EmptyViewWidget();
        }
      },
    );
  }
}

class ShwahidDalalatWidget extends StatelessWidget {
  const ShwahidDalalatWidget({
    Key? key,
    required this.shahidDalalahItem,
  }) : super(key: key);
  final ShwahidDalalatGroupModel shahidDalalahItem;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //todo: shahid is here
            for (var linePhrase in shahidDalalahItem.shahedChars!)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                        text: TextSpan(children: [
                      for (var singleChar in linePhrase)
                        if (singleChar != null)
                          TextSpan(
                              text: addTapOrNewLine(singleChar),
                              style: TextStyle(
                                fontFamily: singleChar.fontFamily,
                                fontWeight: singleChar.getFontWeight(),
                                fontSize: singleChar.size! * 1.5,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : singleChar.color!.getColor(),
                              ))
                    ])),
                  ),
                ],
              ),

            //todo: dalalat lines here

            for (var linePhrase in shahidDalalahItem.daleelChars!)
              Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(children: [
                          for (var singleChar in linePhrase)
                            if (singleChar != null)
                              // for (CharPropertiesModel singleChar
                              //     in singleShahidLine.dalalat!)
                              TextSpan(
                                  text: addTapOrNewLine(singleChar),
                                  style: TextStyle(
                                    fontFamily: singleChar.fontFamily,
                                    fontWeight: singleChar.getFontWeight(),
                                    fontSize: singleChar.size! * 1.5,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : singleChar.color!.getColor(),
                                  ))
                        ])),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ));
  }
}

String addTapOrNewLine(CharPropertiesModel charModel) {
  String? originalUnicode = charModel.unicode;
  if (originalUnicode == null) {
    return '';
  } else {
    if (charModel.addTab == true) {
      originalUnicode = '\t$originalUnicode';
    }
    if (charModel.isNewLine == true) {
      originalUnicode = '\n$originalUnicode';
    }
    return originalUnicode;
  }
}
