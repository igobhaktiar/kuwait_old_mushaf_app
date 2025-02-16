import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:quran_app/features/bookmarks/data/models/bookmark_model.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

class BookmarkListBody extends StatefulWidget {
  const BookmarkListBody({Key? key}) : super(key: key);

  @override
  State<BookmarkListBody> createState() => _BookmarkListBodyState();
}

class _BookmarkListBodyState extends State<BookmarkListBody> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (BuildContext context, BookmarksState state) {
      var cubit = BookmarksCubit.get(context);
      return ValueListenableBuilder(
        valueListenable: cubit.bookmarksBoxListenable,
        builder: (BuildContext context, Box box, Widget? widget) {
          return box.isEmpty
              ? Center(
                  child: Text(
                    context.translate.bookmarks_list_is_empty,
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
                        SlidableBookmarkListTile(
                          key: Key((box.getAt(i) as BookmarkModel)
                              .date
                              .toIso8601String()),
                          context,
                          box.getAt(i) as BookmarkModel,
                          index: i,
                        ),
                    ],
                  ),
                );
        },
      );
    });
  }
}

class SlidableBookmarkListTile extends StatelessWidget {
  const SlidableBookmarkListTile(
    this.parentContext,
    this.bookmark, {
    Key? key,
    required this.index,
    this.dense = false,
    this.forSavedView = false,
    this.popWhenCicked = false,
  }) : super(key: key);
  final BookmarkModel bookmark;
  final int index;
  final bool dense;
  final bool popWhenCicked;
  final bool forSavedView;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slidable(
          enabled: !forSavedView,
          closeOnScroll: true,
          key: const ValueKey(0),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              Expanded(
                child: Container(
                  color: context.theme.brightness == Brightness.dark
                      ? context.theme.scaffoldBackgroundColor
                      : const Color(0xFFFEF2F2),
                  // width: double.infinity,

                  child: Align(
                    child: Builder(
                      builder: (ctx) {
                        return InkWell(
                          onTap: () => _onDeletePressed(parentContext),
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
                        );
                      },
                    ),
                    // alignment: Alignment.,
                  ),
                ),
              )
            ],
          ),
          child: ListTile(
            dense: dense,
            contentPadding:
                EdgeInsets.symmetric(vertical: dense ? 0 : 10, horizontal: 25),
            minVerticalPadding: dense ? 0 : 10,
            minLeadingWidth: 0,
            title: Text(
              bookmark.bookmarkTitle.toString(),
              style: context.textTheme.bodyMedium!.copyWith(
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            leading: SvgPicture.asset(
              AppAssets.bookmarkFilled,
              color: context.theme.brightness == Brightness.dark
                  ? Colors.white
                  : null,
            ),
            trailing: Text(
              '${context.translate.localeName == AppStrings.arabicCode ? bookmark.surahNameArabic : bookmark.surahNameEnglish} - ${context.translate.the_ayah} ${bookmark.ayah}',
              style: context.textTheme.bodySmall!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () => _onBookmarkTapped(context),
          ),
        ),
        if (forSavedView)
          AppConstants.appDivider(context,
              endIndent: 40,
              color: context.theme.brightness == Brightness.dark
                  ? AppColors.bottomSheetBorderDark
                  : AppColors.border)
      ],
    );
  }

  _onDeletePressed(BuildContext context) {
    AppConstants.showConfirmationDialog(context,
        confirmMsg: context.translate
            .do_you_want_to_delete_this_item(context.translate.this_item),
        okCallback: () {
      BookmarksCubit.get(context)
          .deleteBookmarkAt(index)
          .whenComplete(() => Navigator.pop(context));
    });
  }

  _onBookmarkTapped(BuildContext context) {
    EssentialMoshafCubit.get(context).navigateToPage(bookmark.page);
    if (popWhenCicked) {
      Navigator.pop(context);
    }
    var surahNumber = context
        .read<EssentialMoshafCubit>()
        .getSurahNumberFromItsName(bookmark.surahNameEnglish);
    context.read<AyatHighlightCubit>().highlightAyah(
        AyahModel(numberInSurah: bookmark.ayah, surahNumber: surahNumber));
    if (EssentialMoshafCubit.get(context).isShowFihris) {
      EssentialMoshafCubit.get(context).toggleRootView();
      context.read<EssentialMoshafCubit>().hideFlyingLayers();
      context.read<EssentialMoshafCubit>().hidePagesPopUp();
    }
  }
}
