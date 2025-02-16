import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/features/bookmarks/data/models/bookmark_model.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/bookmarks_list.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

class BookmarksView extends StatefulWidget {
  final bool withDash;
  final bool dense;
  final bool forSavedView;
  final bool popWhenCicked;
  const BookmarksView({
    this.withDash = true,
    this.dense = false,
    this.forSavedView = false,
    Key? key,
    this.popWhenCicked = false,
  }) : super(key: key);

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarksCubit, BookmarksState>(
        builder: (context, state) {
      var cubit = BookmarksCubit.get(context);
      return ValueListenableBuilder(
        valueListenable: cubit.bookmarksBoxListenable,
        builder: (context, Box box, boxWidget) {
          return box.isEmpty
              ? Column(
                  children: [
                    if (widget.withDash) const ViewDashIndicator(),
                    Expanded(
                      child: CenteredEmptyListMsgWidget(
                          msg: context.translate.bookmarks_list_is_empty),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (widget.withDash) const ViewDashIndicator(),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < box.length; i++)
                              SlidableBookmarkListTile(
                                  dense: widget.dense,
                                  popWhenCicked: widget.popWhenCicked,
                                  forSavedView: widget.forSavedView,
                                  key: Key((box.getAt(i) as BookmarkModel)
                                      .date
                                      .toIso8601String()),
                                  context,
                                  box.getAt(i) as BookmarkModel,
                                  index: i),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      );
    });
  }
}

class CenteredEmptyListMsgWidget extends StatelessWidget {
  const CenteredEmptyListMsgWidget({
    Key? key,
    required this.msg,
  }) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        textDirection: context.translate.localeName == AppStrings.arabicCode
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: context.textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ViewDashIndicator extends StatelessWidget {
  const ViewDashIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<EssentialMoshafCubit>().hideFlyingLayers(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 31,
        decoration: BoxDecoration(
          border: Border.all(width: 2.5, color: AppColors.lightBrown),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
