import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required this.sharedPreferences})
      : super(const AppThemeState(brightness: Brightness.light));
  static ThemeCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;
  int currentThemeId = 1;
  init() {
    int savedIndex = sharedPreferences.getInt(AppStrings.savedTheme) ?? 1;
    setCurrentTheme(savedIndex, logAnalyticsEvent: false);
  }

  setCurrentTheme(int index, {bool logAnalyticsEvent = true}) {
    print("setCurrentTheme: index=$index");
    currentThemeId = index;
    if (index == 0) {
      var brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      emit(AppThemeState(
          brightness: !isDarkMode ? Brightness.light : Brightness.dark,
          pageBgcolor: !isDarkMode ? Colors.white : const Color(0xFFF5EFDF)));
    } else {
      emit(AppThemeState(
          brightness:
              [1, 3, 4].contains(index) ? Brightness.light : Brightness.dark,
          pageBgcolor:
              [1, 3].contains(index) ? Colors.white : const Color(0xFFF5EFDF)));
    }
    sharedPreferences.setInt(AppStrings.savedTheme, index);
    if (logAnalyticsEvent) {
      FirebaseAnalytics.instance.logEvent(
          name: AppStrings.analytcsEventChangeTheme,
          parameters: {
            'brightness': state.brightness == Brightness.dark ? "Dark" : "Light"
          });
    }
  }
}
