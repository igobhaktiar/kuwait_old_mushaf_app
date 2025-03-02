import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';

class ScreenshotWidget extends StatelessWidget {
  const ScreenshotWidget({
    super.key,
    required this.ayah,
  });
  final AyahModel ayah;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: 1024,
        child: FittedBox(
          fit: !context.isLandscape ? BoxFit.fitWidth : BoxFit.fitHeight,
          child: Container(
            constraints: const BoxConstraints(minWidth: 1024, maxWidth: 1024),
            child: Container(
              constraints: const BoxConstraints(minWidth: 1024, maxWidth: 1024),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.amber, border: Border.all(color: const Color(0xFFCE9A18), width: 3)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.pageMetadataFrame,
                                        width: 200,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(top: 10),
                                        child: SvgPicture.asset(
                                          AppAssets.getSurahName(ayah.surahNumber!),
                                          height: 21,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.pageMetadataFrame,
                                        width: 200,
                                        color: null,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          AppAssets.getJuzName(ayah.juz!),
                                          height: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ].reversed.toList(),
                              ),
                              const SizedBox(height: 40),
                              RichText(
                                textAlign: TextAlign.center,
                                strutStyle: const StrutStyle(height: 8, forceStrutHeight: true),
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ayah.text!.toString(),
                                      style: context.textTheme.bodyMedium!.copyWith(
                                        color: Colors.black,
                                        fontSize: 55,
                                        height: 1.8,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: AppStrings.uthmanyHafsV20fontFamily,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${String.fromCharCode(ayah.numberInSurah! + AppConstants.ayahNumberUnicodeStarter)}',
                                      style: context.textTheme.bodyMedium!.copyWith(
                                        color: Colors.black,
                                        fontSize: 65,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: AppStrings.uthmanicAyatNumbersFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                          color: const Color(0xFFF7F5F2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppAssets.qsaLogoWithMoshafSloganForImageShare,
                                height: 60,
                              ),
                            ].reversed.toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
