import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/number_to_arabic.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../essential_moshaf_feature/data/models/fihris_models.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

enum FihrisTypes { SWAR, AJZAA, AHZAB }

const double borderRadius = 25.0;

class FihrisScreen extends StatefulWidget {
  const FihrisScreen({Key? key}) : super(key: key);
  @override
  _FihrisScreenState createState() => _FihrisScreenState();
}

class _FihrisScreenState extends State<FihrisScreen>
    with SingleTickerProviderStateMixin {
  late PageController _fihrisPageController;
  int activePageIndex = 0;

  @override
  void dispose() {
    _fihrisPageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fihrisPageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> fihrisTypesViews = [
      const AjzaaList(),
      const SwarList(),
      const AhzabList()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.quuarn_fihris,
        ),

        // title: Text(context.translate.quuarn_fihris),
        leading: AppConstants.customBackButton(context, onPressed: () {
          EssentialMoshafCubit.get(context).toggleRootView();
        }),

        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: context.isDarkMode
                  ? null
                  : const DecorationImage(
                      image: AssetImage(AppAssets.pattern), fit: BoxFit.cover)),
        ),
      ),
      body: BlocListener<EssentialMoshafCubit, EssentialMoshafState>(
        listener: (context, state) {
          if (state is ChangeFihrisIndex) {
            _onHeaderCategoryTap(state.viewIndex);
          }
        },
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Container(),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _fihrisTypesMenuBar(context),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _fihrisPageController,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (int i) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() => activePageIndex = i);
                        },
                        itemBuilder: (context, index) =>
                            fihrisTypesViews[index],
                        itemCount: fihrisTypesViews.length,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _fihrisTypesMenuBar(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      // alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
              color: (context.theme.brightness == Brightness.dark
                  ? AppColors.scaffoldBgDark
                  : AppColors.border),
              width: (context.theme.brightness == Brightness.dark ? 0.0 : 1.0)),
          color: context.theme.brightness == Brightness.dark
              ? context.theme.cardColor
              : AppColors.tabBackground,
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          headerItem(context, index: 0, title: context.translate.the_juz),
          headerItem(context, index: 1, title: context.translate.the_surah),
          headerItem(context, index: 2, title: context.translate.the_hizb),
        ],
      ),
    );
  }

  Widget headerItem(BuildContext context,
      {required String title, required int index}) {
    return InkWell(
      onTap: () {
        _onHeaderCategoryTap(index);
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: (activePageIndex == index)
                ? (context.theme.brightness == Brightness.dark
                    ? AppColors.activeTypeBgDark
                    : Colors.black)
                : (context.theme.brightness == Brightness.dark
                    ? context.theme.cardColor
                    : AppColors.tabBackground),
            borderRadius: BorderRadius.circular(30)),
        child: Center(
          child: Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(
              fontSize: 13,
              color: activePageIndex == index
                  ? AppColors.white
                  : (context.theme.brightness == Brightness.dark
                      ? AppColors.border
                      : AppColors.inactiveColor),
            ),
            // style: (activePageIndex == index)
            //     ? TextStyle(color: AppColors.white, fontSize: 13)
            //     : TextStyle(color: AppColors.inactiveColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _onHeaderCategoryTap(int page) {
    //todo: what is the hill!!
    _fihrisPageController.animateToPage(page,
        duration: const Duration(microseconds: 1000), curve: Curves.decelerate);
  }
}

class SwarList extends StatelessWidget {
  const SwarList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      fihrisItems: EssentialMoshafCubit.get(context).swarListForFihris,
      fihrisType: FihrisTypes.SWAR,
    );
  }
}

class AhzabList extends StatelessWidget {
  const AhzabList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      fihrisItems: EssentialMoshafCubit.get(context).ahzabListForFihris,
      fihrisType: FihrisTypes.AHZAB,
    );
  }
}

class AjzaaList extends StatelessWidget {
  const AjzaaList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      fihrisItems: EssentialMoshafCubit.get(context).ajzaaListForFihris,
      fihrisType: FihrisTypes.AJZAA,
    );
  }
}

class FihrisListBody extends StatefulWidget {
  final List<dynamic> fihrisItems;

  final FihrisTypes fihrisType;
  const FihrisListBody({
    Key? key,
    required this.fihrisItems,
    required this.fihrisType,
  }) : super(key: key);

  @override
  State<FihrisListBody> createState() => _FihrisListBodyState();
}

class _FihrisListBodyState extends State<FihrisListBody>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          separatorBuilder: ((context, index) =>
              AppConstants.appDivider(context)),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.fihrisItems.length,
          itemBuilder: ((context, index) {
            return widget.fihrisType == FihrisTypes.SWAR
                ? SurahListViewItem(
                    surahFihrisModel: widget.fihrisItems[index],
                  )
                : widget.fihrisType == FihrisTypes.AJZAA
                    ? JuzListViewItem(juzFihrisModel: widget.fihrisItems[index])
                    : HizbListViewItem(
                        hizbFihrisModel: widget.fihrisItems[index]);
          })),
    );
  }
}

class SurahListViewItem extends StatelessWidget {
  final SurahFihrisModel surahFihrisModel;

  const SurahListViewItem({
    Key? key,
    required this.surahFihrisModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        context
            .read<EssentialMoshafCubit>()
            .navigateToPage(surahFihrisModel.page!);

        EssentialMoshafCubit.get(context).toggleRootView();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                surahFihrisModel.number.toString())
                            : surahFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 14,
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? surahFihrisModel.name.toString()
                        : surahFihrisModel.englishName.toString(),
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${surahFihrisModel.page}) - ${context.translate.its_ayat_female} (${surahFihrisModel.count}) - ${context.translate.localeName == "ar" ? surahFihrisModel.revelationTypeArabic : surahFihrisModel.revelationType}',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Text(
                      context.translate.localeName == AppStrings.arabicCode
                          ? "${EssentialMoshafCubit.get(context).ajzaaListForFihris.where((element) => element.number == surahFihrisModel.juz).toList().first.name}"
                          : "${context.translate.the_juz} ${surahFihrisModel.juz}",
                      // "${context.translate.the_juz} ${surahFihrisModel.juz}",
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class JuzListViewItem extends StatelessWidget {
  final JuzFihrisModel juzFihrisModel;

  const JuzListViewItem({
    Key? key,
    required this.juzFihrisModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        context
            .read<EssentialMoshafCubit>()
            .navigateToPage(juzFihrisModel.pageStart!);

        EssentialMoshafCubit.get(context).toggleRootView();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                juzFihrisModel.number.toString())
                            : juzFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? juzFihrisModel.name.toString()
                        : "${context.translate.the_juz} ${juzFihrisModel.number}",
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${juzFihrisModel.pageStart}) - ${context.translate.its_ayat_male} (${juzFihrisModel.count})',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class HizbListViewItem extends StatelessWidget {
  final HizbFihrisModel hizbFihrisModel;

  const HizbListViewItem({
    Key? key,
    required this.hizbFihrisModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        context
            .read<EssentialMoshafCubit>()
            .navigateToPage(hizbFihrisModel.pageStart!);

        EssentialMoshafCubit.get(context).toggleRootView();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          width: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: context.theme.cardColor,
                      child: Text(
                        context.translate.localeName == "ar"
                            ? convertToArabicNumber(
                                hizbFihrisModel.number.toString())
                            : hizbFihrisModel.number.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: context.theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.translate.localeName == "ar"
                        ? hizbFihrisModel.name.toString()
                        : "${context.translate.the_hizb} ${hizbFihrisModel.number}",
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, left: 20),
                child: Row(
                  children: [
                    Text(
                      '${context.translate.the_page} (${hizbFihrisModel.pageStart}) - ${context.translate.its_ayat_male} (${hizbFihrisModel.count})',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    Text(
                      context.translate.localeName == AppStrings.arabicCode
                          ? "${EssentialMoshafCubit.get(context).ajzaaListForFihris.where((element) => element.number == hizbFihrisModel.juz).toList().first.name}"
                          : "${context.translate.the_juz} ${hizbFihrisModel.juz}",
                      style: context.textTheme.bodySmall!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
