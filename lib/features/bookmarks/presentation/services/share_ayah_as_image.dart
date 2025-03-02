import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as DartImage;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/bookmarks/presentation/widgets/screenshot_widget.dart';
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
    Uint8List imageBytes = await screenshotController.captureFromWidget(ScreenshotWidget(ayah: ayah),
        // targetSize: Size(1024, 1024),
        context: context,
        delay: const Duration(milliseconds: 1000));
    var dir = (Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!;
    File screenshotFile = File("${dir.path}/screenshot.png")..create(recursive: true);
    await screenshotFile.writeAsBytes(imageBytes);
    //resizing the output image
    DartImage.Image? imageData = DartImage.decodeImage(screenshotFile.readAsBytesSync());
    if (imageData == null) {
      return;
    }
    DartImage.Image? resizeImage = DartImage.copyResize(imageData, width: 1024);
    File resizedScreenshotFile = File("${dir.path}/resizedScreenshot.png")
      ..create(recursive: true)
      ..writeAsBytesSync(DartImage.encodePng(resizeImage));
    await Share.shareXFiles([XFile(screenshotFile.path)], subject: "مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}");
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(name: 'shareAyahImage', parameters: {"ayah": "${ayah.number}"});
  } catch (e) {
    AppConstants.showToast(context, msg: context.translate.something_went_wrong);
  }
}
