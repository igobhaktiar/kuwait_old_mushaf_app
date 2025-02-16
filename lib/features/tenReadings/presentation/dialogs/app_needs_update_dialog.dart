import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matcher/matcher.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:url_launcher/url_launcher.dart'
    show LaunchMode, canLaunchUrl, launchUrl;

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

showAppNeedsUpdateDialog(BuildContext context) async {
  AppConstants.showConfirmationDialog(context,
      confirmMsg: context.translate.please_update_app_to_get_new_features,
      acceptButtonText: context.translate.update,
      withOkButton: true,
      refuseButtonText: context.translate.later, okCallback: () async {
    Navigator.pop(context);
    // if (await canLaunchUrl(Uri.parse(EndPoints.appLandingPage))) {
    launchUrl(Uri.parse(EndPoints.appLandingPage),
        mode: LaunchMode.externalApplication);
    // }

    FirebaseAnalytics.instance
        .logEvent(name: AppStrings.analytcsEventUpadteAppFromPopUp);
  }, cancelCallback: () {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    context.read<TenReadingsCubit>().resetIsNeedUpdateDialogShown();
    Navigator.pop(context);
  }, onDialogDismissed: () async {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    context.read<TenReadingsCubit>().resetIsNeedUpdateDialogShown();

    return true;
  });
}
