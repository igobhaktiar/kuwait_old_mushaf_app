import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PlatformService {
  static const MethodChannel _channel =
  MethodChannel('kw.gov.qsa.quranapp.kqaplatformchannel');


  static Future<Uint8List?> getAssetFile(String packageName, String filename) async {
    try {
      final byteData = await _channel.invokeMethod('getAssetFileContent', {
        'packageName': packageName,
        'filename': filename,
      });
      if (byteData != null) {
        return byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      }
    } catch (e) {
      print("Error fetching asset file: $e");
    }
    return null;
  }


  static Future<dynamic> getAssetsJson(
      String packageName, String filename) async {
    try {
      final Uint8List? data = await getAssetFile(packageName, filename);
      if (data != null) {
        // Decode the JSON directly from the Uint8List
        String contents = utf8.decode(data);
        return json.decode(contents);
      }
    } catch (e) {
      print("Error decoding JSON from asset data: $e");
    }
    return null; // Return null if there's an error or data doesn't exist
  }

  static Future<File?> getAssetFileAudio(
      String packageName, String filename, String tempFilename) async {
    try {
      final byteData = await _channel.invokeMethod('getAssetFileContent', {
        'packageName': packageName,
        'filename': filename,
      });
      if (byteData != null) {
        final buffer = byteData.buffer;
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}/$tempFilename'; // Use tempFilename here
        final File file = File(filePath);
        await file.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        return file;
      }
    } catch (e) {
      print("Error fetching asset file: $e");
    }
    return null;
  }
}
