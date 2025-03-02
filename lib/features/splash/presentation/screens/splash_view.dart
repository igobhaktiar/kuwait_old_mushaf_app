import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';

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
