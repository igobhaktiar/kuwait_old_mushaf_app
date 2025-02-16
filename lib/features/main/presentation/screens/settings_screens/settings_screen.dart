import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart'
    show AppConstants, ListItemData;
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit;

import 'package:quran_app/features/main/presentation/screens/settings_screens/advanced_settings.dart'
    show AdvancedSettingScreen;
import 'package:quran_app/features/main/presentation/screens/settings_screens/appearance_control_screen.dart'
    show AppearanceControlScreen;
import 'package:quran_app/features/main/presentation/screens/settings_screens/language_control_screen.dart'
    show LanguageControlScreen;
import 'package:quran_app/features/main/presentation/screens/settings_screens/notifications_control_screen.dart'
    show NotificationsControlScreen;
import 'package:quran_app/features/main/presentation/screens/settings_screens/storage_screen.dart'
    show StorageScreen;
import 'package:quran_app/features/terms_and_conditions/presentation/screens/terms_and_conditions_screen.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../about_app/presentation/screens/about_app_screen.dart';
import '../../../../privacy_policy/presentation/screens/privacy_policy_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.settings),
          leading: AppConstants.customBackButton(context, onPressed: () {
            EssentialMoshafCubit.get(context).toggleRootView();
          }),
        ),
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SettingWidgetList(
                            groupTitle: context.translate.general_settings,
                            settingListData: _settinglistTiles1(context),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          SettingWidgetList(
                            groupTitle:
                                context.translate.security_and_usage_policy,
                            settingListData: _settinglistTiles2(context),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                )
              ]),
        ));
  }

  List<ListItemData> _settinglistTiles1(BuildContext context) {
    //* LANGUAGES
    final settingList = [
      ListItemData.image(
        image: AppAssets.set_1,
        onPressed: () {
          pushSlide(context, screen: const LanguageControlScreen());
        },
        name: context.translate.ui_language,
      ),
      //* NOTIFICATIONS
      ListItemData.image(
        name: context.translate.notifications_and_reminders,
        image: AppAssets.set_2,
        onPressed: () {
          pushSlide(context, screen: const NotificationsControlScreen());
        },
      ),
      //* THEME
      ListItemData.image(
        image: AppAssets.set_3,
        name: context.translate.appearance,
        onPressed: () {
          pushSlide(context, screen: const AppearanceControlScreen());
        },
      ),

      //* STORAGE
      ListItemData.image(
        name: context.translate.storage,
        image: AppAssets.set_4,
        onPressed: () {
          pushSlide(context, screen: const StorageScreen());
        },
      ),

      //* ADVANCED SETTINGS
      ListItemData.image(
        name: context.translate.advanced_settings,
        image: AppAssets.set_5,
        onPressed: () {
          pushSlide(context, screen: const AdvancedSettingScreen());
        },
      ),
    ];
    return settingList;
  }

  List<ListItemData> _settinglistTiles2(BuildContext context) {
    final settingList = [
      //* PRIVACY POLICY
      ListItemData.image(
        name: context.translate.privacy_policy,
        image: AppAssets.set_6,
        onPressed: () {
          pushSlide(context, screen: const PrivacyPolicyScreen());
        },
      ),
      //* TERMS OF USE
      ListItemData.image(
        name: context.translate.terms_of_use,
        image: AppAssets.set_7,
        onPressed: () {
          pushSlide(context, screen: const TermsAndConditionsScreen());
        },
      ),
      //* ABOUT THE APP
      ListItemData.image(
        name: context.translate.about_app,
        image: AppAssets.set_8,
        onPressed: () {
          pushSlide(context, screen: const AboutAppScreen());
        },
      ),
      ListItemData.image(
        name: context.translate.share_app,
        image: AppAssets.shareIcon,
        onPressed: () {
          Share.share('مصحف دولة الكويت للقراءات العشر\n ${AppStrings.appUrl}');
        },
      ),
    ];
    return settingList;
  }
}

@immutable
class SettingWidgetList extends StatelessWidget {
  const SettingWidgetList({
    required this.settingListData,
    required this.groupTitle,
    Key? key,
  }) : super(key: key);
  final List<dynamic> settingListData;
  final String groupTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            separatorBuilder: (_, index) {
              return Divider(
                color: context.theme.brightness == Brightness.dark
                    ? const Color(0xff565657)
                    : context.theme.dividerColor,
                thickness: 2,
                indent: 40,
              );
            },
            itemCount: settingListData.length,
            itemBuilder: (_, index) {
              return InkWell(
                onTap: settingListData[index].onPressed,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      SvgPicture.asset(
                        settingListData[index].image!,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        settingListData[index].name!,
                        style: context.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: context.theme.primaryIconTheme.color,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
