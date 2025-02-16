import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

showDarkThemeNotAvailableIn10R(BuildContext context,
    {bool? returnToLightTheme}) {
  bool isInTenReadingsMode =
      context.read<EssentialMoshafCubit>().isInTenReadingsMode();
  if (context.isDarkMode && isInTenReadingsMode) {
    context.read<ThemeCubit>().setCurrentTheme(1);
  }
  if (isInTenReadingsMode) {
    return;
  }
  AppConstants.showConfirmationDialog(context,
      confirmMsg: context
          .translate.dark_mode_is_not_available_currently_for_tenreadings_mode,
      acceptButtonText: context.translate.download_current_juz_now,
      withOkButton: false,
      refuseButtonText: context.translate.ok, cancelCallback: () {
    if (context.isDarkMode && isInTenReadingsMode) {
      context.read<ThemeCubit>().setCurrentTheme(1);
    }
    Navigator.pop(context);
  }, onDialogDismissed: () async {
    if (context.isDarkMode && isInTenReadingsMode) {
      context.read<ThemeCubit>().setCurrentTheme(1);
    }
    log("dialog dissmissed");
    return true;
  });
}
