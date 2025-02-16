import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../cubit/tenreadings_cubit.dart';

showContentNotAvailableDialog(BuildContext context, {String? msg}) {
  AppConstants.showConfirmationDialog(context,
      confirmMsg: msg ?? context.translate.this_content_will_be_available_soon,
      acceptButtonText: context.translate.download_current_juz_now,
      withOkButton: false,
      refuseButtonText: context.translate.ok, cancelCallback: () {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    Navigator.pop(context);
  }, onDialogDismissed: () async {
    context.read<EssentialMoshafCubit>().changeMoshafTypeToOrdinary();
    log("dialog dissmissed");
    return true;
  });
}
