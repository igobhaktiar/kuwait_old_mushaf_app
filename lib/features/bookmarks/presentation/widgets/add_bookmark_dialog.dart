import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/default_dialog.dart' show showDefaultDialog;
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart' show AppStrings;
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart'
    show AyahModel;
import 'package:quran_app/l10n/localization_context.dart';

import '../../../ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import '../../../essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

showAddBookmarkDialog(BuildContext context, AyahModel ayah) {
  String bookmarkTitle = '';
  TextEditingController bookmarkTitleController = TextEditingController();
  bookmarkTitleController.addListener(() {});
  showDefaultDialog(context,
      title:
          "${context.translate.localeName == AppStrings.arabicCode ? ayah.surah : ayah.surahEnglish} - ${context.translate.the_ayah} ${ayah.numberInSurah}"
              .replaceAll(RegExp(r"سورة"), ''),
      onSaved: () {
        if (bookmarkTitle.isNotEmpty) {
          context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
          BookmarksCubit.get(context)
              .addBookmark(title: bookmarkTitleController.text, ayah: ayah);
          context.read<EssentialMoshafCubit>().showBottomSheetSections();
          context.read<BottomSheetCubit>().changeViewIndex(2);
          Navigator.pop(context);
        } else {
          debugPrint("enter a title first");
        }
      },
      onDialogDismissed: () async {
        context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
        log("dialog dissmissed");
        return true;
      },
      withSaveButton: true,
      btntext: context.translate.add,
      content: StatefulBuilder(builder: (context, updateState) {
        return Column(
          children: [
            TextField(
              controller: bookmarkTitleController,
              onChanged: (value) => updateState(() => bookmarkTitle = value),
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                filled: true,
                fillColor: context.theme.brightness == Brightness.dark
                    ? AppColors.cardBgDark
                    : AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide.none,
                ),
                hintText: context.translate.bookmark_name,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }));
}
