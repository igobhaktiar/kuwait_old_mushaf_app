import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart' show AppColors;
import 'package:quran_app/core/utils/app_strings.dart' show AppStrings;
import 'package:quran_app/core/utils/assets_manager.dart' show AppAssets;
import 'package:quran_app/core/utils/constants.dart' show AppConstants;
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:quran_app/features/bookmarks/data/models/bookmark_model.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart'
    show BookmarksCubit, BookmarksState;
import 'package:quran_app/features/bookmarks/presentation/screens/bookmarks_list.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit;
import 'package:quran_app/l10n/localization_context.dart';

enum CurrentScreen { bookmark, favorite }

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  var currScreen = CurrentScreen.bookmark;
  @override
  Widget build(BuildContext context) {
    final List favoriteBookmarksText = [
      context.translate.bookmarks,
      context.translate.favourites
    ];
    return Scaffold(
      appBar: AppBar(
          title: Text(favoriteBookmarksText[currScreen.index]),
          leading: AppConstants.customBackButton(context,
              onPressed: () =>
                  EssentialMoshafCubit.get(context).toggleRootView())),
      body: SafeArea(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 15,
                ),
                padding: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: (context.theme.brightness == Brightness.dark
                          ? AppColors.scaffoldBgDark
                          : AppColors.border),
                      width: (context.theme.brightness == Brightness.dark
                          ? 0.0
                          : 1.0)),
                  color: context.theme.brightness == Brightness.dark
                      ? context.theme.cardColor
                      : AppColors.tabBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (CurrentScreen scr in CurrentScreen.values)
                            InkWell(
                              onTap: () => setState(() => currScreen = scr),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: scr == currScreen
                                      ? (context.theme.brightness ==
                                              Brightness.dark
                                          ? AppColors.activeTypeBgDark
                                          : AppColors.activeButtonColor)
                                      : (context.theme.brightness ==
                                              Brightness.dark
                                          ? context.theme.cardColor
                                          : AppColors.tabBackground),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  favoriteBookmarksText[scr.index],
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                      color: scr == currScreen
                                          ? AppColors.white
                                          : (context.theme.brightness ==
                                                  Brightness.dark
                                              ? AppColors.white
                                              : AppColors.activeButtonColor),
                                      fontSize: Orientation.landscape ==
                                              MediaQuery.of(context).orientation
                                          ? context.width * 0.012
                                          : context.width * 0.029,
                                      fontWeight: scr == currScreen
                                          ? FontWeight.bold
                                          : FontWeight.w400),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: currScreen == CurrentScreen.favorite
                ? const StarListBody()
                : const BookmarkListBody(),
          )
        ],
      )),
    );
  }
}

class StarListBody extends StatefulWidget {
  const StarListBody({Key? key}) : super(key: key);

  @override
  State<StarListBody> createState() => _StarListBodyState();
}

class _StarListBodyState extends State<StarListBody> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (BuildContext context, BookmarksState state) {
      final cubit = BookmarksCubit.get(context);
      return ValueListenableBuilder(
        valueListenable: cubit.favouritesBoxListenable,
        builder: (BuildContext context, Box box, widget) {
          return box.isEmpty
              ? Center(
                  child: Text(
                    context.translate.favourites_list_is_empty,
                    textDirection:
                        context.translate.localeName == AppStrings.arabicCode
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int i = 0; i < box.length; i++)
                        SlidableFavListTile(
                            key: Key((box.getAt(i) as BookmarkModel)
                                .date
                                .toIso8601String()),
                            context,
                            box.getAt(i) as BookmarkModel,
                            index: i),
                    ],
                  ),
                );
        },
      );
    });
  }
}

class SlidableFavListTile extends StatelessWidget {
  const SlidableFavListTile(
    this.mainContext,
    this.favModel, {
    Key? key,
    required this.index,
  }) : super(key: key);
  final BuildContext mainContext;
  final BookmarkModel favModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Slidable(
        closeOnScroll: true,
        key: const ValueKey(0),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            Container(
              color: context.theme.brightness == Brightness.dark
                  ? context.theme.scaffoldBackgroundColor
                  : const Color(0xFFFEF2F2),
              width: MediaQuery.of(context).size.width / 2,
              child: Align(
                child: InkWell(
                  onTap: () => _onDeletePressed(mainContext),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        AppAssets.delete,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        context.translate.delete,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.red,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // alignment: Alignment.,
              ),
            )
          ],
        ),
        child: InkWell(
          onTap: () => _onFavouriteTapped(context),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      // color: Colors.green,
                      child: SvgPicture.asset(
                        AppAssets.starFilled,
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : null,
                      )),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SvgPicture.asset(AppAssets.sura_name),
                        RichText(
                            strutStyle: const StrutStyle(
                                height: 2, forceStrutHeight: true),
                            text: TextSpan(children: [
                              TextSpan(
                                text: favModel.ayahText.toString(),
                                style: context.textTheme.bodyMedium!.copyWith(
                                    color: context.theme.brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 25,
                                    height: 1.8,
                                    fontFamily:
                                        AppStrings.uthmanyHafsV20fontFamily),
                              ),
                              TextSpan(
                                text:
                                    ' ${String.fromCharCode(favModel.ayah + AppConstants.ayahNumberUnicodeStarter)}',
                                style: context.textTheme.bodyMedium!.copyWith(
                                    color: context.theme.brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 30,
                                    fontFamily: AppStrings
                                        .uthmanicAyatNumbersFontFamily),
                              ),
                            ])),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        Text(
                          '${context.translate.localeName == AppStrings.arabicCode ? favModel.surahNameArabic : favModel.surahNameEnglish} - ${context.translate.the_ayah} ${favModel.ayah} - ${context.translate.the_page} ${favModel.page}',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  void _onDeletePressed(BuildContext context) {
    AppConstants.showConfirmationDialog(context,
        confirmMsg: context.translate
            .do_you_want_to_delete_this_item(context.translate.this_item),
        okCallback: () async {
      await BookmarksCubit.get(context)
          .deleteFavouriteAt(index)
          .whenComplete(() => Navigator.pop(context));
    });
  }

  void _onFavouriteTapped(BuildContext context) {
    context.read<EssentialMoshafCubit>().navigateToPage(favModel.page);
    context.read<EssentialMoshafCubit>().hideFlyingLayers();
    context.read<EssentialMoshafCubit>().hidePagesPopUp();
    var surahNumber = context
        .read<EssentialMoshafCubit>()
        .getSurahNumberFromItsName(favModel.surahNameEnglish);
    context.read<AyatHighlightCubit>().highlightAyah(
        AyahModel(numberInSurah: favModel.ayah, surahNumber: surahNumber));

    EssentialMoshafCubit.get(context).toggleRootView();
  }
}
