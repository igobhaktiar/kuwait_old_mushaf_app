import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as DartImage;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';

shareAyahAsImage(BuildContext context, {required AyahModel ayah}) async {
  try {
    //* Create an instance of ScreenshotController
    ScreenshotController screenshotController = ScreenshotController();

    //* take the shot
    Uint8List imageBytes = await screenshotController.captureFromWidget(
        ScreenshotWidget(ayah: ayah),
        // targetSize: Size(1024, 1024),
        context: context,
        delay: const Duration(milliseconds: 1000));
    var dir = (Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory())!;
    File screenshotFile = File("${dir.path}/screenshot.png")
      ..create(recursive: true);
    await screenshotFile.writeAsBytes(imageBytes);
    //resizing the output image
    DartImage.Image? imageData =
        DartImage.decodeImage(screenshotFile.readAsBytesSync());
    if (imageData == null) {
      return;
    }
    DartImage.Image? resizeImage = DartImage.copyResize(imageData, width: 1024);
    File resizedScreenshotFile = File("${dir.path}/resizedScreenshot.png")
      ..create(recursive: true)
      ..writeAsBytesSync(DartImage.encodePng(resizeImage));
    await Share.shareXFiles([XFile(screenshotFile.path)],
        subject: "مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}");
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
        name: 'shareAyahImage', parameters: {"ayah": "${ayah.number}"});
  } catch (e) {
    AppConstants.showToast(context,
        msg: context.translate.something_went_wrong);
  }
}

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
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        border: Border.all(
                            color: const Color(0xFFCE9A18), width: 3)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 80),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          AppAssets.getSurahName(
                                              ayah.surahNumber!),
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
                                  strutStyle: const StrutStyle(
                                      height: 2, forceStrutHeight: true),
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: ayah.text!.toString(),
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                              color: Colors.black,
                                              fontSize: 55,
                                              height: 1.8,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: AppStrings
                                                  .uthmanyHafsV20fontFamily),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${String.fromCharCode(ayah.numberInSurah! + AppConstants.ayahNumberUnicodeStarter)}',
                                      style: context.textTheme.bodyMedium!
                                          .copyWith(
                                              color: Colors.black,
                                              fontSize: 65,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: AppStrings
                                                  .uthmanicAyatNumbersFontFamily),
                                    ),
                                  ])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
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
