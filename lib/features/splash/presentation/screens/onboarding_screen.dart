import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/screens/ordinary_moshaf_screen.dart';
import 'package:quran_app/injection_container.dart' as di;
import 'package:quran_app/l10n/localization_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final PageController _onBoardingPageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light),
      )),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          flexibleSpace: const SizedBox(),
          toolbarHeight: 0,
        ),
        body: PageView.builder(
          controller: _onBoardingPageController,
          itemCount: 9,
          itemBuilder: (context, index) {
            return _buildOnBoarrdingWidget(context, index);
          },
        ),
      ),
    );
  }

  Stack _buildOnBoarrdingWidget(BuildContext context, int index) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: context.width,
          height: context.height,
          color: AppColors.inactiveColor,
          child: Image.asset(
            "${AppStrings.onBoardingBgPng}$index.png",
            fit: BoxFit.fill,
          ),
        ),
        //* next screen arrow button
        Positioned(
          bottom: 30,
          child: InkWell(
            onTap: () {
              _nextPage(context);
            },
            child: SvgPicture.asset(
              "${AppStrings.onBoardingBtnSvg}$index.svg",
              height: 50,
              width: 50,
            ),
          ),
        ),
        //* skip onboarding to quran page
        Positioned(
          left: 10,
          top: 50,
          child: InkWell(
            onTap: () {
              _skipSplashScreen(context);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
            },
            child: Padding(
              padding: EdgeInsets.only(top: context.topPadding),
              child: Row(
                children: [
                  Text(
                    context.translate.skip,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 15,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage(BuildContext context) {
    if (kDebugMode) {
      print("animated to ${_onBoardingPageController.page! + 1}");
    }
    if (_onBoardingPageController.page == 8.0) {
      _skipSplashScreen(context);
    } else {
      _onBoardingPageController.nextPage(
          duration: const Duration(microseconds: 375), curve: Curves.easeInOut);
    }
  }

  Future<void> _skipSplashScreen(BuildContext context) async {
    pushReplacementSlide(context, screen: const OrdinaryMoshafScreen());
    await di
        .getItInstance<SharedPreferences>()
        .setBool(AppStrings.isNewUserKey, false);
  }
}
