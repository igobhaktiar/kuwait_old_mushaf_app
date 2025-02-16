import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/core/api/dio_consumer.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/features/externalLibraries/data/models/external_library_model.dart';
import 'package:quran_app/features/externalLibraries/presentation/cubit/external_libraries_state.dart';
import 'package:quran_app/injection_container.dart' as di;

import '../../../../core/utils/app_strings.dart';

class ExternalLibrariesCubit extends Cubit<ExternalLibrariesState> {
  ExternalLibrariesCubit(
      {required this.dioConsumer, required this.internetConnectionChecker})
      : super(ExternalLibrariesInitial());
  static ExternalLibrariesCubit get(context) => BlocProvider.of(context);

  DioConsumer dioConsumer;
  Map<String, bool> isDownloadingPdfMap = Map.fromIterables([], []);
  Map<String, String> downloadingPdfProgressMap = Map.fromIterables([], []);

  dynamic externalLibrary;

  final InternetConnectionChecker internetConnectionChecker;
  Future<Directory> get getExternalLibrariesDirectory async => Directory(
      "${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/External_Library")
    ..createSync(recursive: true);

  Future<void> initExternalLibrariesCubit() async {
    if (await internetConnectionChecker.connectionStatus ==
        InternetConnectionStatus.connected) {
      externalLibrary = await readExternalLibrariesJson();
    } else {
      externalLibrary = await fetchWhenOffline();
    }

    emit(ExternalLibraryInitialized());
  }

  Future<InternetConnectionStatus> checkConnection() async =>
      await internetConnectionChecker.connectionStatus;

  Future fetchExternalLibrariesData() async {
    final externalResourcesResponse = await dioConsumer.get(
        "${EndPoints.getBaseUrlAccordingToBuildTarget(di.getItInstance())}${EndPoints.externalResources}");
    if (externalResourcesResponse.statusCode == 200) {
      return json.decode(externalResourcesResponse.data);
    }
  }

  Future<bool> pdfFileIsDownloaded(String title) async {
    bool fileIsFound = false;
    Directory("${(await getExternalLibrariesDirectory).path}/rewayat/")
        .listSync()
        .forEach((file) {
      if (file is File) {
        if (file.path!.contains("$title---")) {
          fileIsFound = true;
        }
      }
    });
    return fileIsFound;
    // if (await File(
    //         "${(await getExternalLibrariesDirectory).path}/rewayat/$title.pdf")
    //     .exists()) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Future<List<String>> fetchWhenOffline() async {
    final path = "${(await getExternalLibrariesDirectory).path}/rewayat/";
    final localPaths = <String>[];
    if (Directory(path).existsSync()) {
      for (var element in Directory(path).listSync(followLinks: false)) {
        String resourceTitle =
            basename(element.path).split("---").toList().first;
        localPaths.add(resourceTitle);
      }
      return localPaths.getRange(0, localPaths.length).toList();
    } else {
      return localPaths.toList();
    }
  }

  Future openFileExternal(String title) async {
    final File? pdfFile = await _getRecourceFileByTitle(title);

    if (pdfFile != null && pdfFile.existsSync()) {
      await OpenFile.open(pdfFile.path);
    }
  }

  Future deletePdf(String title) async {
    final file = await _getRecourceFileByTitle(title);
    if (file != null && file.existsSync()) {
      await file.delete();
      FirebaseAnalytics.instance.logEvent(
          name: AppStrings.analytcsEventDeleteLibraryPDF,
          parameters: {'title': title});
    }
    await initExternalLibrariesCubit();
    emit(ExternalLibraryItemDeleted());
  }

  Future downloadExternalLibrary(Resource resource) async {
    isDownloadingPdfMap[resource.title!] = true;
    downloadingPdfProgressMap[resource.title!] = "0.0";
    emit(ExternalLibraryDownloadingAssets(resource.title!));
    await dioConsumer.download(
      // remoteUrl: "https://archive.org/download/hosary2/hosary2.pdf",
      remoteUrl: resource.url!,
      // remoteUrl: resource.url!,
      storagePath:
          "${(await getExternalLibrariesDirectory).path}/rewayat/${resource.title}---${resource.modified}.pdf",
      // "${(await getExternalLibrariesDirectory).path}/rewayat/${resource.title}---${resource.modified}.pdf",
      onRecieveProgress: (int received, int total) {
        if (total != -1) {
          String percentage =
              "${((received / total) * 100).toStringAsFixed(2)}";
          emit(ExternalLibraryDownloadingFile(percentage));
          downloadingPdfProgressMap[resource.title!] = percentage;
          if ((received / total) == 1) {
            isDownloadingPdfMap[resource.title!] = false;
            emit(ExternalLibraryFinishDownload(resource.title!));
            FirebaseAnalytics.instance.logEvent(
                name: AppStrings.analytcsEventDownloadLibraryPDF,
                parameters: {'title': resource.title!});
          }
        }
      },
    );
  }

  Future<ExternalLibrary> readExternalLibrariesJson() async {
    final jsonData = await fetchExternalLibrariesData();
    return ExternalLibrary.fromJson(jsonData);
  }

  Future<File?> _getRecourceFileByTitle(String title) async {
    var matchFiles = <FileSystemEntity>[];
    matchFiles =
        Directory("${(await getExternalLibrariesDirectory).path}/rewayat/")
            .listSync()
            .where((element) => element.path.contains("$title---"))
            .toList();
    if (matchFiles.isNotEmpty) {
      return matchFiles.first as File;
    }
  }

  Future<bool> isFileNeedsUpdatte(Resource resource) async {
    File? resourceFile = await _getRecourceFileByTitle(resource.title!);
    if (resourceFile != null && resourceFile.existsSync()) {
      String storedModifiedDateString =
          resourceFile.path.split("---").toList().last.replaceAll(".pdf", "");
      return storedModifiedDateString != resource.modified;
    } else {
      return false;
    }
  }

  Future<String> getFileSizeInMB(String title) async {
    File? resourceFile = await _getRecourceFileByTitle(title!);
    if (resourceFile != null && resourceFile.existsSync()) {
      String byteLength =
          '${(resourceFile.lengthSync() / 1000000).toStringAsFixed(2)} MB ';
      return byteLength;
    } else {
      return '';
    }
  }

  void deleteAndDownloadUpdatedFile(Resource libraryResource) async {
    await deletePdf(libraryResource.title!);
    await Future.delayed(Duration(milliseconds: 500));
    await downloadExternalLibrary(libraryResource);
  }
}
