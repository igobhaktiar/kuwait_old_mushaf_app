import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_strings.dart';

ThemeData appDarkTheme() {
  return ThemeData(
      // primaryColor: AppColors.primary,

      fontFamily: AppStrings.cairoFontFamily,
      brightness: Brightness.dark,
      // colorSchemeSeed: Colors.black45,
      colorScheme: ColorScheme.dark(secondary: Colors.black45),
      hintColor: AppColors.white,
      scaffoldBackgroundColor: AppColors.scaffoldBgDark,
      cardColor: AppColors.cardBgDark,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.dialogBgDark),
      dividerColor: AppColors.cardBgDark,
      appBarTheme: const AppBarTheme(
          // ignore: deprecated_member_use
          backgroundColor: AppColors.appBarBgDark,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(
            color: AppColors.white,
            size: 25,
          ),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            fontSize: 16,
            fontFamily: AppStrings.cairoFontFamily,
          )),
      //////////////////////////////////////////////////////
      //* [TextTheme]
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
            height: 1.4,
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold),
        bodySmall: TextStyle(
            height: 1.4,
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500),
        displayMedium: TextStyle(
          height: 1.4,
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: AppStrings.cairoFontFamily,
        ),
        //* FOR SUBTITLES
        displaySmall: TextStyle(
          height: 1.4,
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: AppStrings.cairoFontFamily,
        ),
      ),
      //////////////////////////////////////////////////////////////
      ///
      ///
      ///
      //////////////////////////////////////////////////////////////
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            textStyle: const TextStyle(color: AppColors.activeButtonColor)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            textStyle: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontFamily: AppStrings.cairoFontFamily)),
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.white,
      ),

      //* for inactive bottom nav bar icons
      iconTheme: const IconThemeData(
        color: AppColors.inActiveIconColorDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
      ),
      dialogBackgroundColor: AppColors.scaffoldBgDark,
      sliderTheme: const SliderThemeData(
        overlappingShapeStrokeColor: AppColors.white,
        overlayColor: AppColors.white,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
        trackHeight: 4,
        activeTrackColor: AppColors.border,
        thumbColor: AppColors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
          linearTrackColor: AppColors.scaffoldBgDark, color: Colors.white));
}
