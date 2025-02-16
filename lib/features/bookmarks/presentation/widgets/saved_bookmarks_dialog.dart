import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/default_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../main/presentation/screens/bottom_sheet_views/bookmarksview.dart';

showSavedBookmarks(BuildContext context) {
  showDefaultDialog(
    context,
    title: context.translate.bookmarks,
    withSaveButton: false,
    content: SizedBox(
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: context.theme.brightness == Brightness.dark
                        ? AppColors.cardBgDark
                        : AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(9)),
                child: const BookmarksView(
                  withDash: false,
                  popWhenCicked: true,
                  dense: true,
                  forSavedView: true,
                )),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AppButton(
                    text: context.translate.start_over,
                    height: 55,
                    color: AppColors.white,
                    textColor: AppColors.activeButtonColor,
                    hasSide: true,
                    side: const BorderSide(
                        color: AppColors.activeButtonColor, width: 1.5),
                    borderRadius: 10,
                    width: MediaQuery.of(context).size.width / 2.3,
                    onPressed: () => onStartOverPressed(context)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                    text: context.translate.read_on,
                    textColor: context.theme.brightness == Brightness.dark
                        ? AppColors.activeButtonDark
                        : AppColors.white,
                    height: 55,
                    color: context.theme.brightness == Brightness.dark
                        ? context.theme.scaffoldBackgroundColor
                        : AppColors.activeButtonColor,
                    side: const BorderSide(
                        color: AppColors.activeButtonDark, width: 1.5),
                    borderRadius: 10,
                    onPressed: () => onReadOnPressed(context)),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
    ),
  );
}

onStartOverPressed(BuildContext context) {
  Navigator.pop(context);
}

onReadOnPressed(BuildContext context) {
  context.read<EssentialMoshafCubit>().navigateToLastAccessedPage();
  Navigator.pop(context);
}
