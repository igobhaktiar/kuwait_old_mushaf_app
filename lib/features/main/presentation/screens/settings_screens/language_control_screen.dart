import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/constants.dart';

class LanguageControlScreen extends StatelessWidget {
  const LanguageControlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.ui_language),
          leading: AppConstants.customBackButton(context),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          LanguageWidgetsList(
                            groupTitle: context.translate.language,
                            languagesListData: _languagelistTiles(),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]));
  }

  List<ListItemData> _languagelistTiles() {
    //* LANGUAGES
    final languageList = [
      ListItemData(
        icon: AppAssets.arabicFlag,
        name: 'العربية',
        subTitle: AppStrings.arabicCode,
      ),
      //* NOTIFICATIONS
      ListItemData(
        icon: AppAssets.englishWord,
        // icon: AppAssets.english_flag,
        name: 'English',
        subTitle: AppStrings.englishCode,
      ),
    ];
    return languageList;
  }
}

class LanguageWidgetsList extends StatefulWidget {
  LanguageWidgetsList({
    required this.languagesListData,
    required this.groupTitle,
    Key? key,
  }) : super(key: key);
  List<ListItemData> languagesListData;
  String groupTitle;

  @override
  State<LanguageWidgetsList> createState() => _LanguageWidgetsListState();
}

class _LanguageWidgetsListState extends State<LanguageWidgetsList> {
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
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, index) {
              return Divider(
                color: context.theme.dividerColor,
                thickness: 2,
                indent: 40,
              );
            },
            itemCount: widget.languagesListData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                child: BlocBuilder<LangCubit, LangState>(
                  builder: (context, state) {
                    var cubit = LangCubit.get(context);
                    return InkWell(
                      onTap: () => LangCubit.get(context).changeLocale(
                          widget.languagesListData[index].subTitle!),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: SizedBox(
                          width: context.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ClipOval(
                                  child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  widget.languagesListData[index].icon!,

                                  // fit: BoxFit.fitHeight,
                                ),
                              )),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                widget.languagesListData[index].name!,
                                style: context.theme.brightness ==
                                        Brightness.dark
                                    ? context.textTheme.bodyMedium!.copyWith(
                                        fontSize: 16,
                                        fontWeight: state.locale.languageCode ==
                                                widget.languagesListData[index]
                                                    .subTitle!
                                            ? FontWeight.w600
                                            : FontWeight.w600,
                                      )
                                    : context.textTheme.bodyMedium!.copyWith(
                                        fontSize: 16,
                                        fontWeight: state.locale.languageCode ==
                                                widget.languagesListData[index]
                                                    .subTitle!
                                            ? FontWeight.w600
                                            : FontWeight.w600,
                                        color: state.locale.languageCode ==
                                                widget.languagesListData[index]
                                                    .subTitle!
                                            ? AppColors.activeButtonColor
                                            : AppColors.hintColor,
                                      ),
                              ),
                              const Spacer(),
                              state.locale.languageCode ==
                                      widget.languagesListData[index].subTitle
                                  ? SvgPicture.asset(
                                      AppAssets.checkMark,
                                      color:
                                          context.theme.primaryIconTheme.color,
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
