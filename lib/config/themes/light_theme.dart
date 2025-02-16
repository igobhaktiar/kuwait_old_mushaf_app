// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_strings.dart';

ThemeData appLightTheme() {
  return ThemeData(
    fontFamily: AppStrings.cairoFontFamily,
    brightness: Brightness.light,
    cardColor: AppColors.cardColorLight,
    // primaryColor: AppColors.primary,
    colorSchemeSeed: AppColors.primary, //AppColors.primary
    hintColor: AppColors.inactiveColor,
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundColor),
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        centerTitle: true,
        color: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.activeButtonColor,
          size: 25,
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.activeButtonColor,
          fontSize: 16,
          fontFamily: AppStrings.cairoFontFamily,
        )),
    //////////////////////////////////////////////////////
    ///
    ///
    ///
    ///
    //////////////////////////////////////////////////////
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
          height: 1.3,
          fontSize: 16,
          color: AppColors.activeButtonColor,
          fontWeight: FontWeight.bold),
      bodySmall: TextStyle(
          height: 1.4,
          fontSize: 14,
          color: AppColors.inactiveColor,
          fontWeight: FontWeight.w500),
      displayMedium: TextStyle(
        height: 1.4,
        fontSize: 14,
        color: AppColors.inactiveColor,
        fontWeight: FontWeight.w400,
        fontFamily: AppStrings.cairoFontFamily,
      ),
      //* FOR SUBTITLES
      displaySmall: TextStyle(
        height: 1.4,
        fontSize: 10,
        color: AppColors.inactiveColor,
        fontWeight: FontWeight.w400,
        fontFamily: AppStrings.cairoFontFamily,
      ),
    ),
    /////////////////////////////////////////////////////////
    ///
    ///
    ///
    /////////////////////////////////////////////////////////
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.createKhatmahButtonColor,
          // backgroundColor: AppColors.activeButtonColor,
          textStyle: const TextStyle(color: AppColors.white)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          textStyle: TextStyle(
              color: AppColors.activeButtonColor,
              fontSize: 14,
              fontFamily: AppStrings.cairoFontFamily)),
    ),
    //* forliistTiles leading and trailing icons and images
    primaryIconTheme: const IconThemeData(
      color: AppColors.activeButtonColor,
    ),
    //* for inactive bottom nav bar icons
    iconTheme: const IconThemeData(
      color: AppColors.inactiveColor,
    ),
    dialogBackgroundColor: AppColors.tabBackground,
    sliderTheme: const SliderThemeData(
      overlappingShapeStrokeColor: AppColors.white,
      overlayColor: AppColors.white,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      trackHeight: 4,
      activeTrackColor: AppColors.activeButtonColor,
      thumbColor: AppColors.activeButtonColor,
    ),
  );
}
