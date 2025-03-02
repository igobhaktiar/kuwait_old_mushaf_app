import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/quran_page_widget.dart';
import 'package:quran_app/kqa_platform_service.dart';

class OrdinaryMoshafImage extends StatelessWidget {
  const OrdinaryMoshafImage({
    super.key,
    required this.widget,
  });

  final QuranPageWidget widget;

  Future<File> loadImageAssetAsFile(String assetPath) async {
    print("5254 Waleed loadImageAssetAsFile assetPath: $assetPath");
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Get a temporary directory (you could choose a different directory)
    final Directory tempDir = await getTemporaryDirectory();
    // final String filePath = '${tempDir.path}/temppage1.png';
    String fileName = p.basename(assetPath);
    final String filePath = '${tempDir.path}/$fileName';

    // Write the bytes to a file
    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    return file;
  }

  Future<Uint8List> loadImageAssetPackAsFile(String filename, String tempFilename) async {
    const packageName = 'kw.gov.qsa.quranapp';
    // const filename = 'assets/images/example.png'; // Example asset file path in the other app
    // const tempFilename = 'example_temp.png'; // Temporary filename in your app

    Uint8List? data = await PlatformService.getAssetFile(packageName, filename);
    return data!;
  }

  @override
  Widget build(BuildContext context) {
    log("5254 Waleed widget.index: ${widget.index}");
    if (!AppStrings.myDebugMode) {
      return FutureBuilder<Uint8List>(
        future: loadImageAssetPackAsFile("all_black_pages/${AppStrings.getAssetPngBlackPagePath2(widget.index + 1)}", "temppage.png"),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          // Check the state of the future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loader widget or something similar while waiting
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle errors, maybe show an error message
            return Text('Error: ${snapshot.error}');
          } else {
            // Once the future completes, snapshot.data will contain your Uint8List
            // Use the Uint8List to build your widget
            // For example, displaying the image
            return Image.memory(
              snapshot.data!,
              color: context.isDarkMode ? Colors.white : null,
              height: widget.actualWidth / AppConstants.moshafPageAspectRatio,
              fit: MediaQuery.of(context).orientation == Orientation.landscape ? BoxFit.fitWidth : null,
            );
          }
        },
      );
    } else {
      return Image.asset(
        AppStrings.getAssetPngBlackPagePath(widget.index + 1),
        height: widget.actualWidth / AppConstants.moshafPageAspectRatio,
        color: context.isDarkMode ? Colors.white : null,
        errorBuilder: (BuildContext context, Object object, StackTrace? stackTrace) {
          return Text(
            "",
          );
        },
        fit: MediaQuery.of(context).orientation == Orientation.landscape ? BoxFit.fitWidth : null,
      );
    }
  }
}
