import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

import 'package:quran_app/features/essential_moshaf_feature/presentation/screens/ordinary_moshaf_screen.dart';
import 'package:quran_app/features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'package:quran_app/features/splash/presentation/screens/onboarding_screen.dart';
import 'package:quran_app/features/terms_and_conditions/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:quran_app/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../about_app/presentation/cubit/about_app_cubit.dart';

class CoverScreen extends StatefulWidget {
  const CoverScreen({super.key});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  bool isToShowSponsorView = false;
  @override
  void initState() {
    // return;
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // make this screen run in portrate only mode

    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        isToShowSponsorView = !isToShowSponsorView;
      });

      _navigateToNextPage();
    });
    context.read<AboutAppCubit>().getContentOfAboutApp();

    context.read<PrivacyPolicyCubit>().getPrivacyPolicy();
    context.read<TermsAndConditionsCubit>().getTermsAndConditions();
  }

  _navigateToNextPage() {
    Future.delayed(const Duration(seconds: 5), () {
      if (di
              .getItInstance<SharedPreferences>()
              .getBool(AppStrings.isNewUserKey) !=
          false) {
        pushReplacementSlide(context, screen: const OnBoardingScreen());
      } else {
        pushReplacementSlide(context, screen: const OrdinaryMoshafScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: context.height,
        width: context.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(AppAssets.patternBgWithTextBehind))),
        child: !isToShowSponsorView
            ? FadeOutDown(
                delay: const Duration(seconds: 6), child: const SplashView())
            : FadeIn(child: const SpnonsorView()),
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            SvgPicture.asset(
              AppAssets.upperDecoration,
              width: context.width,
            ),
            const Spacer(),
            const Spacer(),
            SvgPicture.asset(
              AppAssets.lowerDecoration,
              width: context.width,
            ),
          ],
        ),
        SvgPicture.asset(
          AppAssets.hollyQuran,
          height: context.height / 2.6,
        ),
        Positioned(
          bottom: context.height * 0.2,
          child: SvgPicture.asset(
            AppAssets.forTenReadings,
          ),
        )
      ],
    );
  }
}

class SpnonsorView extends StatelessWidget {
  const SpnonsorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(
          flex: 3,
        ),
        SvgPicture.asset(
          AppAssets.qsaVertical,
          height: context.height / 4,
        ),
        const SizedBox(height: 30),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.width / 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: const LinearProgressIndicator(
              minHeight: 6,
              color: Color(0xffB9AA95),
              backgroundColor: Color(0xffF4EBDC),
            ),
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        SvgPicture.asset(AppAssets.bobyanSponsor),
        const SizedBox(height: 20),
      ],
    );
  }
}
