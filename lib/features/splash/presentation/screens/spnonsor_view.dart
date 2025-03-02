import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';

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
