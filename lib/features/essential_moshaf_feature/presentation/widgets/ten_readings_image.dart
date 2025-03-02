import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/quran_page_widget.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:quran_app/kqa_platform_service.dart';

class TenReadingsImage extends StatelessWidget {
  const TenReadingsImage({super.key, required this.tenCubit, required this.widget, required this.state});

  final TenReadingsCubit tenCubit;
  final QuranPageWidget widget;
  final TenReadingsState state;

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

  // Future<File> loadImageAssetPackAsFile(String filename, String tempFilename) async {
  //   const packageName = 'kw.gov.qsa.quranapp';
  //   // const filename = 'assets/images/example.png'; // Example asset file path in the other app
  //   // const tempFilename = 'example_temp.png'; // Temporary filename in your app
  //   print ("5254 Waleed filename: $filename");
  //   File? file = await PlatformService.getAssetFile(packageName, filename, tempFilename);
  //   return file!;
  // }
  Future<Uint8List> loadImageAssetPackAsFile(String filename, String tempFilename) async {
    const packageName = 'kw.gov.qsa.quranapp';
    // const filename = 'assets/images/example.png'; // Example asset file path in the other app
    // const tempFilename = 'example_temp.png'; // Temporary filename in your app
    print("5254 Waleed filename: $filename");
    Uint8List? data = await PlatformService.getAssetFile(packageName, filename);
    return data!;
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStrings.myDebugMode) {
      return FutureBuilder<Uint8List>(
        // future: loadImageAssetAsFile("assets/colored/${AppStrings.getColoredImageFileName(widget.index + 1)}"),
        future: loadImageAssetPackAsFile("colored/${AppStrings.getColoredImageFileName(widget.index + 1)}", "tempcc.png"),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
          // Check the state of the future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Return a loader widget or something similar while waiting
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle errors, maybe show an error message
            return Text('Error: ${snapshot.error}');
          } else {
            // Once the future completes, snapshot.data will contain your File
            // Use the File to build your widget
            // For example, displaying the image
            return Image.memory(
              snapshot.data!,
              key: const Key('tenReadingsquranImage'),
              color: context.isDarkMode ? Colors.white : null,
              height: context.width / AppConstants.moshafPageAspectRatio,
              fit: MediaQuery.of(context).orientation == Orientation.landscape ? BoxFit.fitWidth : null,
            );
          }
        },
      );
    } else {
      return Image.asset(
        "assets/colored/${AppStrings.getColoredImageFileName(widget.index + 1)}",
        key: const Key('tenReadingsquranImage'),
        color: context.isDarkMode ? Colors.white : null,
        height: context.width / AppConstants.moshafPageAspectRatio,
        fit: MediaQuery.of(context).orientation == Orientation.landscape ? BoxFit.fitWidth : null,
      );
    }

    // File? f = loadImageAssetAsFile ("assets/colored/${AppStrings.getColoredImageFileName(widget.index + 1)}") as File;
    // return Image.asset("assets/colored/${AppStrings.getColoredImageFileName(widget.index + 1)}",
    //   key: const Key('tenReadingsquranImage'),
    //   color: context.isDarkMode ? Colors.white : null,
    //   height: context.width / AppConstants.moshafPageAspectRatio,
    //   fit: MediaQuery.of(context).orientation == Orientation.landscape
    //       ? BoxFit.fitWidth
    //       : null,
    // );
    // return Image.file(
    //   tenCubit.coloredImagesSubFolderPath != '' &&
    //           File("${tenCubit.coloredImagesSubFolderPath}${AppStrings.getColoredImageFileName(widget.index + 1)}")
    //               .existsSync()
    //       ? File(
    //           "${tenCubit.coloredImagesSubFolderPath}${AppStrings.getColoredImageFileName(widget.index + 1)}")
    //       : (state as TenreadingsServicesLoaded).coloredImageFile!,
    //   key: const Key('tenReadingsquranImage'),
    //   color: context.isDarkMode ? Colors.white : null,
    //   height: context.width / AppConstants.moshafPageAspectRatio,
    //   fit: MediaQuery.of(context).orientation == Orientation.landscape
    //       ? BoxFit.fitWidth
    //       : null,
    // );
  }
}
