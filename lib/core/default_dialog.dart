import 'package:flutter/material.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';

showDefaultDialog(BuildContext context,
    {String? title,
    String btntext = "save",
    double? titleFontSize,
    FontWeight? titleFontWeight,
    bool withSaveButton = true,
    bool barrierDismissible = true,
    VoidCallback? onSaved,
    Future<bool> Function()? onDialogDismissed,
    Widget? content}) {
  showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: onDialogDismissed ?? () async => true,
          child: Center(
            child: Dialog(
              insetAnimationCurve: Curves.easeOut,
              insetPadding: context.isLandscape
                  ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
                  : const EdgeInsets.all(18),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  // margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: context.theme.brightness == Brightness.dark
                        ? AppColors.scaffoldBgDark
                        : AppColors.tabBackground,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium!.copyWith(
                                  fontSize: titleFontSize ?? 16,
                                  fontWeight:
                                      titleFontWeight ?? FontWeight.bold),
                            ),
                          ),
                        if (content != null) content,
                        if (withSaveButton)
                          SizedBox(
                            width: context.width,
                            child: ElevatedButton(
                              onPressed: onSaved,
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: context
                                      .theme
                                      .elevatedButtonTheme
                                      .style!
                                      .backgroundColor!
                                      .resolve({})!,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Text(
                                btntext,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.theme.elevatedButtonTheme
                                      .style!.textStyle!
                                      .resolve({})!.color,
                                  fontFamily: AppStrings.cairoFontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
