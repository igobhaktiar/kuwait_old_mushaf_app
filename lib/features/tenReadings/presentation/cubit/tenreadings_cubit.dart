// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/core/api/dio_consumer.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/features/tenReadings/data/models/khelafia_word_model.dart' show FullPageTenReadingsResoursesModel, HwamishModel, KhelafiaWordModel, OsoulModel, ShwahidDalalatGroupModel, SingleQeraaModel;
import 'package:quran_app/features/tenReadings/data/models/last_modified_content_model.dart' show LastModifiedPages;

import '../../../../kqa_platform_service.dart';

part 'tenreadings_state.dart';

class TenReadingsCubit extends Cubit<TenReadingsState> {
  TenReadingsCubit({required this.dioConsumer, required this.player, required this.internetConnectionChecker}) : super(TenreadingsInitial());
  //*Fields
  final DioConsumer dioConsumer;
  final AudioPlayer player;
  final InternetConnectionChecker internetConnectionChecker;

  //* Variables
  int currentPage = 1;
  bool isDownloadingAssets = false;
  bool isNeedUpdateDialogShown = false;

  /// A list of currently being done
  List<int> currentlyDownloadingPages = [];
  String coloredImagesSubFolderPath = '';
  int maxWait = 10;
  Timer? timer;
  SingleQeraaModel? currentQeraaPlaying;
  TenreadingsServicesLoaded? lastServicesStateLoaded;

  //* Gettters
  Future<Directory> get getAppStorageDirectory async => (Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!;

  Future<Directory> get getTenReadingsFolder async => Directory("${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/Ten_Readings")..createSync(recursive: true);

  Future<File> loadImageAssetAsFile(String assetPath) async {
    // print ("5254 Waleed loadImageAssetAsFile assetPath: $assetPath");
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Get a temporary directory (you could choose a different directory)
    final Directory tempDir = await getTemporaryDirectory();
    // final String filePath = '${tempDir.path}/temppage1.png';
    String fileName = path.basename(assetPath);
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
    print("5254------- Waleed OrdinaryMoshafImage filename: $filename");
    Uint8List? data = await PlatformService.getAssetFile(packageName, filename);
    return data!;
  }

  Future<File> loadAudioAssetPackAsFile(String filename, String tempFilename) async {
    const packageName = 'kw.gov.qsa.quranapp';
    // const filename = 'assets/images/example.png'; // Example asset file path in the other app
    // const tempFilename = 'example_temp.png'; // Temporary filename in your app
    // print ("5254------- Waleed OrdinaryMoshafImage filename: $filename");
    File? file = await PlatformService.getAssetFileAudio(packageName, filename, tempFilename);
    return file!;
  }

  Future<dynamic> loadJsonFromAssets(String path) async {
    // Load the JSON file as a string
    String jsonString = await rootBundle.loadString(path);

    // Decode the JSON string into a Dart object
    final jsonResponse = json.decode(jsonString);

    // Return the decoded JSON object
    return jsonResponse;
  }

  Future<File> get getLogFile async {
    return File("${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/Ten_Readings/ten_log.txt")..createSync(recursive: true);
  }

  Future<File> get getLastModifiedFile async {
    return File("${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/Ten_Readings/last_modified.json");
  }

//* Methods
  init() {
    _listenToPlayerState();
    checkForContentUpdates();
  }

  void _listenToPlayerState() {
    player.playerStateStream.listen((currentPlayerState) {
      if ([ProcessingState.idle, ProcessingState.completed].contains(currentPlayerState.processingState) && lastServicesStateLoaded != null) {
        emit(lastServicesStateLoaded!);
      }
    });
  }

  // Future<void> getDynamicFont() async {
  //   const url =
  //       'https://d1sc0qtrfa4gsu.cloudfront.net/static/custom_fonts/kn_quran_1.ttf';
  //   final canLoad = await DynamicCachedFonts.canLoadFont(url);

  //   if (canLoad) {
  //     DynamicCachedFonts dynamicCachedFont =
  //         DynamicCachedFonts(fontFamily: AppStrings.knQuran, url: url);
  //     await dynamicCachedFont.load();
  //   } else {
  //     await DynamicCachedFonts.cacheFont(url);
  //     await DynamicCachedFonts.loadCachedFont(url,
  //         fontFamily: AppStrings.knQuran);
  //   }
  // }

  checkForContentUpdates() async {
    //*Steps:
    //*1-check if last_modified.json exists, if not Return [that means that user didn't activate 10readings option yet]
    //*2-else the file is found then read it and compare modified date for every page when it not equals the response add this page to currrently downloading pages
    File lastModifiedFile = await getLastModifiedFile;
    if (!lastModifiedFile.existsSync()) {
      return;
    } else {
      if (!await internetConnectionChecker.hasConnection) {
        return;
      }

      final response = await dioConsumer.get(EndPoints.getLastModifiedContent);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        final LastModifiedPages serverLastModifiedContent = LastModifiedPages.fromJson(jsonResponse);
        if (serverLastModifiedContent.quran10 == null) {
          return;
        }
        //stored lastContent
        final jsonStoredLastModifiedContent = jsonDecode(lastModifiedFile.readAsStringSync());
        final LastModifiedPages storedLastModifiedContentModel = LastModifiedPages.fromJson(jsonStoredLastModifiedContent);
        //compare last modified date in page objects
        bool userNeedsUpates = false;
        List<int> pagesNeedToUpdate = [];
        final lastReadyPage = (await _getLastReadyPage(emitLoading: false)) ?? 0;

        for (int i = 0; i < serverLastModifiedContent.quran10!.length; i++) {
          if (serverLastModifiedContent.quran10![i].modified.toString() != storedLastModifiedContentModel.quran10![i].modified.toString()) {
            if (serverLastModifiedContent.quran10![i].pageNumber! <= lastReadyPage) {
              userNeedsUpates = true;
              pagesNeedToUpdate.add(serverLastModifiedContent.quran10![i].pageNumber!);
            }
          }
        }
        // await getDynamicFont();

        if (userNeedsUpates) {
          emit(TenReadingCheckingForUpdates());
          // store the new serverlastModifiedContent in the local file
          lastModifiedFile.createSync(recursive: true);
          lastModifiedFile.writeAsStringSync(jsonEncode(serverLastModifiedContent.toJson()));
          // npw we can update pages needed update one by one
          log("pagesNeedToUpdate.length=${pagesNeedToUpdate.length}");
          log("pagesNeedToUpdate=$pagesNeedToUpdate");

          await Future.wait([for (final page in pagesNeedToUpdate) downloadTenResourcesForPage(pageNumber: page)]);
        }
      }
    }
  }

  Future<void> getlastUpdateContentAndStoreItLocally() async {
    if (!await internetConnectionChecker.hasConnection) {
      return;
    }

    // await getDynamicFont();
    try {
      final response = await dioConsumer.get(EndPoints.getLastModifiedContent);
      log("getlastUpdateContentAndStoreItLocally: response.statusCode=${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        final LastModifiedPages serverLastModifiedContent = LastModifiedPages.fromJson(jsonResponse);
        if (serverLastModifiedContent.quran10 == null) {
          return;
        }
        File lastModifiedFile = await getLastModifiedFile;
        lastModifiedFile.createSync(recursive: true);
        lastModifiedFile.writeAsStringSync(jsonEncode(serverLastModifiedContent.toJson()));
      }
    } catch (e) {
      emit(TenReadingCheckingForUpdatesError());
    }
  }

  /// Method to decide that the current page's files are being downloaded or not
  bool checkIfCurrentPageIsBeingDownloaded() => currentlyDownloadingPages.contains(currentPage);

  ///* Method to get Ten Readings files for single page
  Future fetchQeraatFilesThenDownload({
    int pageNumber = 1,
  }) async {
    File logFile = (await getLogFile);
    final response = await dioConsumer.get("${EndPoints.getTenReadingsServicesForSinglePage}/$pageNumber");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.data);
      final fullPageResourcesModel = FullPageTenReadingsResoursesModel.fromJson(jsonDecode(response.data));

      Future.wait([
        // downloadTenReadingsImage(fullPageResourcesModel),
        downloadMp3Files(fullPageResourcesModel),
        // downloadQeraatJson(fullPageResourcesModel, logFile),
        // downloadOsoulJson(jsonResponse, fullPageResourcesModel, logFile),
        // downloadShwahedJson(jsonResponse, fullPageResourcesModel, logFile),
        // downloadHwameshJson(jsonResponse, fullPageResourcesModel, logFile),
      ]);
    } else if (response.statusCode == 400 && !isNeedUpdateDialogShown) {
      // } else if (response.statusCode == 400) {
      if (!isNeedUpdateDialogShown) {
        emit(UpdateAppToBenefitFromNewFeatursState());
        setIsNeedUpdateDialogShown();
      }
    }
  }

  Future<void> downloadHwameshJson(jsonResponse, FullPageTenReadingsResoursesModel fullPageResourcesModel, File logFile) async {
    if (jsonResponse["hawamesh"] != null) {
      if (!Directory((await getTenReadingsFolder).path).existsSync()) {
        Directory((await getTenReadingsFolder).path).createSync(recursive: true);
      }
      String fullTenFolder = (await getTenReadingsFolder).path;
      File hawameshFile = File('$fullTenFolder/json/Hawamesh_${fullPageResourcesModel.pageNumber}.json')..createSync(recursive: true);
      hawameshFile.writeAsStringSync(jsonEncode(jsonResponse["hawamesh"]), mode: FileMode.writeOnly);
      final contents = '${hawameshFile.path}\n';
      logFile.writeAsStringSync(contents, mode: FileMode.writeOnlyAppend);
    }
  }

  Future<void> downloadShwahedJson(
    jsonResponse,
    FullPageTenReadingsResoursesModel fullPageResourcesModel,
    File logFile,
  ) async {
    if (jsonResponse["shawahed"] != null) {
      if (!Directory((await getTenReadingsFolder).path).existsSync()) {
        Directory((await getTenReadingsFolder).path).createSync(recursive: true);
      }

      final String fullTenFolder = (await getTenReadingsFolder).path;

      final File shawahedFile = File('$fullTenFolder/json/Shawahed_${fullPageResourcesModel.pageNumber}.json')..createSync(recursive: true);

      shawahedFile.writeAsStringSync(jsonEncode(jsonResponse["shawahed"]), mode: FileMode.writeOnly);

      final contents = '${shawahedFile.path}\n';
      logFile.writeAsStringSync(contents, mode: FileMode.writeOnlyAppend);
    }
  }

  Future<void> downloadOsoulJson(jsonResponse, FullPageTenReadingsResoursesModel fullPageResourcesModel, File logFile) async {
    if (jsonResponse["osoul"] != null) {
      if (!Directory((await getTenReadingsFolder).path).existsSync()) {
        Directory((await getTenReadingsFolder).path).createSync(recursive: true);
      }

      String fullTenFolder = (await getTenReadingsFolder).path;

      File osoulFile = File('$fullTenFolder/json/Osoul_${fullPageResourcesModel.pageNumber}.json')..createSync(recursive: true);

      osoulFile.writeAsStringSync(jsonEncode(jsonResponse["osoul"]), mode: FileMode.writeOnly);

      final contents = '${osoulFile.path}\n';
      logFile.writeAsStringSync(contents, mode: FileMode.writeOnlyAppend);
    }
  }

  Future<void> downloadQeraatJson(FullPageTenReadingsResoursesModel fullPageResourcesModel, File logFile) async {
    if (fullPageResourcesModel.quranTenPageWord != null) {
      if (!Directory((await getTenReadingsFolder).path).existsSync()) {
        Directory((await getTenReadingsFolder).path).createSync(recursive: true);
      }
      String fullTenFolder = (await getTenReadingsFolder).path;

      List jsonFullKhelfiaWordsList = [];
      jsonFullKhelfiaWordsList = fullPageResourcesModel.quranTenPageWord!.map((wordWithQeraat) => jsonEncode(wordWithQeraat.toJson())).toList();
      if (!Directory((await getTenReadingsFolder).path).existsSync()) {
        Directory((await getTenReadingsFolder).path).createSync(recursive: true);
      }

      File wordsFile = File('$fullTenFolder/json/Qeraat_${fullPageResourcesModel.pageNumber}.json')..createSync(recursive: true);

      wordsFile.writeAsStringSync(jsonFullKhelfiaWordsList.toString().replaceAll(RegExp(r'' + '${EndPoints.qeraatMp3RemoteFolder}|${EndPoints.awsQeraatMp3RemoteFolder}' + ''), '$fullTenFolder/sounds/'), mode: FileMode.writeOnly);

      final contents = '${wordsFile.path}\n';
      logFile.writeAsStringSync(contents, mode: FileMode.writeOnlyAppend);
    }
  }

  Future<void> downloadTenReadingsImage(FullPageTenReadingsResoursesModel fullPageResourcesModel) async {
    if (fullPageResourcesModel.coloredImagePath != null) {
      await downloadTenReadingsFile(remoteFileUrl: fullPageResourcesModel.coloredImagePath);
    }
  }

  Future<void> downloadMp3Files(
    FullPageTenReadingsResoursesModel fullPageResourcesModel,
  ) async {
    if (fullPageResourcesModel.quranTenPageWord != null) {
      for (final khelafiaWord in fullPageResourcesModel.quranTenPageWord!) {
        for (final singleQeraa in khelafiaWord.qeraat!) {
          if (singleQeraa.file != null) {
            await downloadTenReadingsFile(remoteFileUrl: singleQeraa.file);
          }
        }
      }
    }
  }

  //* Method to download Ten Resources For Page [pageNumber]
  Future<void> downloadTenResourcesForPage({required int pageNumber}) async {
    await downloadFilesForPageRange(start: pageNumber, end: pageNumber, withStartToast: false);
  }

  ///* method to download a range of pages at once
  Future<void> downloadFilesForPageRange({int start = 1, int end = 1, bool withStartToast = true, bool withNeedUpdateMsg = false}) async {
    await getlastUpdateContentAndStoreItLocally();
    isDownloadingAssets = true;
    if (withStartToast) {
      emit(TenreadingsStartedDownloadingAssets());
    }
    maxWait = 10;
    await Future.wait(
      List.generate(
        end - start + 1,
        (int index) async {
          currentlyDownloadingPages.add(index + start);
          return await fetchQeraatFilesThenDownload(
            pageNumber: index + start,
          );
        },
      ),
    );
  }

  ///* Mehod to download ten Qeraat single file and store it in the correct place
  Future downloadTenReadingsFile({required remoteFileUrl}) async {
    Directory downloadsFolder = (await getTenReadingsFolder)..createSync(recursive: true);

    final File logFile = await getLogFile;
    final String urlPath = "$remoteFileUrl";
    final String receivedFileName = urlPath.split('/').toList().last;
    final String innerFolderPath = setFolderPath(receivedFileName, downloadsFolder);
    final String receivedFileFullPath = "$innerFolderPath/$receivedFileName";

    /// Will be @depricated soon
    if (File(receivedFileFullPath).existsSync()) {
      log("file already exits! and will delete it to update => $receivedFileName");
      File(receivedFileFullPath).deleteSync(recursive: true);
    }

    log("file not found! =>$receivedFileName");

    _startTimer();

    await dioConsumer.download(
        remoteUrl: urlPath,
        storagePath: receivedFileFullPath,
        onRecieveProgress: (int received, int total) {
          if (total != -1) {
            if (timer != null) {}
            emit(TenreadingsDownloading("${(received / total) * 100}%"));
            log("progress:${(received / total) * 100}%");
            if ((received / total) == 1) {
              timer!.cancel();
              final contents = '$receivedFileFullPath\n';
              logFile.writeAsStringSync(contents, mode: FileMode.writeOnlyAppend);
              emit(TenreadingsDownloadComplete());
              _resetTimer();
            }
          }
        });
  }

  String setFolderPath(
    String receivedFileName,
    Directory downloadsFolder,
  ) {
    var path = "";
    if (receivedFileName.contains('.png')) {
      path = '${downloadsFolder.path}/colored';
      Directory(path).createSync(recursive: true);
    } else if (receivedFileName.contains('.mp3')) {
      path = '${downloadsFolder.path}/sounds';
      Directory(path).createSync(recursive: true);
    } else {
      path = downloadsFolder.path;
    }
    return path;
  }

  ///* Method to load ten Qeraat json files stored on the device and emit them in a state
  void readDownloadedJsonFilesForCurrrentPage() async {
    emit(TenreadingsInitial());

    if (!await checkIfFilesAreFound()) {
      checkAndEmitResult();
      return;
    }

    const String jsonSubFolderPath = 'assets/json/';
    Directory jsonSubFolder = Directory(jsonSubFolderPath);

    coloredImagesSubFolderPath = 'assets/colored/';
    String currentColoredImagePath = AppStrings.getColoredImageFileName(currentPage);
    File? coloredImageFile;
    List<KhelafiaWordModel>? khelafiaWords;
    List<OsoulModel>? osoul;
    List<ShwahidDalalatGroupModel>? shwahedDalalatGroups;
    List<HwamishModel>? hwamish;

    try {
      var jsonOsoulList = await PlatformService.getAssetsJson("kw.gov.qsa.quranapp", "readings_json/Osoul_$currentPage.json");
      if (jsonOsoulList != null) {
        osoul = (jsonOsoulList as List<dynamic>).map((jsonElement) => OsoulModel.fromJson(jsonDecode(jsonEncode(jsonElement)))).toList();
      } else {
        osoul = [];
      }

      var jsonShwahedList = await PlatformService.getAssetsJson("kw.gov.qsa.quranapp", "readings_json/Shawahed_$currentPage.json");
      if (jsonShwahedList != null) {
        shwahedDalalatGroups = (jsonShwahedList as List<dynamic>).map((jsonElement) => ShwahidDalalatGroupModel.fromJson(jsonElement)).toList();
      } else {
        shwahedDalalatGroups = [];
      }

      var jsonHwamishList = await PlatformService.getAssetsJson("kw.gov.qsa.quranapp", "readings_json/Hawamesh_$currentPage.json");
      if (jsonHwamishList != null) {
        hwamish = (jsonHwamishList as List<dynamic>).map((jsonElement) => HwamishModel.fromJson(jsonElement)).toList();
      } else {
        hwamish = [];
      }

      var jsonQeraatWithCordinationsList = await PlatformService.getAssetsJson("kw.gov.qsa.quranapp", "readings_json/Qeraat_$currentPage.json");
      if (jsonQeraatWithCordinationsList != null) {
        khelafiaWords = (jsonQeraatWithCordinationsList as List<dynamic>).map((jsonElement) => KhelafiaWordModel.fromJson(jsonElement)).toList();
      } else {
        khelafiaWords = [];
      }
    } catch (e) {
      print("Error loading assets: $e");
      emit(TenreadingsServicesError());
      return;
    }

    if (kDebugMode) {
      print("we have ${osoul?.length ?? 0} osoul");
      print("we have ${shwahedDalalatGroups?.length ?? 0} shwahed");
      print("we have ${hwamish?.length ?? 0} hwamish");
      print("we have ${khelafiaWords?.length ?? 0} khelafiaWords");
    }

    lastServicesStateLoaded = TenreadingsServicesLoaded(khelfiaWords: khelafiaWords, osoul: osoul, shwahidDalalatGroups: shwahedDalalatGroups, hwamishModel: hwamish, coloredImageFile: coloredImageFile, now: DateTime.now());

    emit(lastServicesStateLoaded ?? TenreadingsServicesLoaded());
  }

  ///* Mehtod to check if the current page resources had beed downloaded
  /// if they are found we should load them, Else download them first
  Future<bool> checkIfFilesAreFound() async {
    File logFile = await getLogFile;
    String contents = logFile.readAsStringSync();

    bool isAllJsonFilesDownloaded = (contents.contains("Hawamesh_$currentPage.json") && contents.contains("Osoul_$currentPage.json") && contents.contains("Qeraat_$currentPage.json") && contents.contains("Shawahed_$currentPage.json"));

    if (!isAllJsonFilesDownloaded) {
      return false;
    } else {
      final String wordsFilePath = "${(await getTenReadingsFolder).path}/json/Qeraat_$currentPage.json";

      final wordsFileRawContents = File((wordsFilePath)).readAsStringSync();

      List<KhelafiaWordModel> wordsModelsList = (jsonDecode(wordsFileRawContents) as List<dynamic>).map((word) => KhelafiaWordModel.fromJson(word)).toList();

      for (final word in wordsModelsList) {
        for (final qeraa in word.qeraat!) {
          if (qeraa.file != null) {
            if (!contents.contains(qeraa.file!)) {
              return false;
            }
          }
        }
      }
      return true;
    }
  }

  checkAndEmitResult() async {
    if (!await checkIfFilesAreFound()) {
      //TODO: get the last ready page then decide to show which alert
      final appNeedsUpdate = await checkIfAppNeedsUpadateToShowPage();
      if (appNeedsUpdate && !isNeedUpdateDialogShown) {
        emit(UpdateAppToBenefitFromNewFeatursState());
        return;
      }
      final lastReadyPage = await _getLastReadyPage();
      if (lastReadyPage != null) {
        if (currentPage <= lastReadyPage!) {
          emit(TenreadingsFilesMustBeDownloadedFirstPromptState());
          return;
        } else {
          emit(ContentNotAvailableState());
          return;
        }
      }
    }
  }

  Future<int?> _getLastReadyPage({bool emitLoading = true}) async {
    if (!await internetConnectionChecker.hasConnection) {
      emit(CheckYourInternetConnection(showAlertDialog: true));
      emit(TenreadingsInitial());
      return null;
    } else {
      if (emitLoading) {
        emit(TenreadingLoading());
      }
      final response = await dioConsumer.get(EndPoints.getLastModifiedContent);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.data);
        final LastModifiedPages serverLastModifiedContent = LastModifiedPages.fromJson(jsonResponse);
        return serverLastModifiedContent.lastReadyPage;
      } else {
        emit(TenreadingError());
        return null;
      }
    }
  }

  void changeCurrentPage(int newPage) {
    currentPage = newPage;
    emit(TenReadingsChangeCurrentPage(newPage));
  }

  ///* Method to play qeraa file mp3
  Future<void> playQeraaFile(SingleQeraaModel qeraa) async {
    await player.stop();
    currentQeraaPlaying = qeraa;
    String audioFile = qeraa.file!.split("/").last;
    /*ByteData audioData = await rootBundle.load("$soundsAssetsPath/$audioFile");
    List<int> bytes = audioData.buffer
        .asUint8List(audioData.offsetInBytes, audioData.lengthInBytes);
    Uri uri = Uri.dataFromBytes(bytes);*/
    Duration? releaseAfter = await player.setAudioSource(AudioSource.asset("$soundsAssetsPath/$audioFile"));
    /*Duration? releaseAfter = await player.setAudioSource(AudioSource.uri(uri));
    await player.setAudioSource(AudioSource.uri((File(qeraa.file!).uri)));*/
    player.play();
    emit(ChangeCurrentPlayingQeraaFileState(qeraa));
    await FirebaseAnalytics.instance.logEvent(name: AppStrings.analytcsEventPlayQeraaMp3, parameters: {'qeraa': qeraa.file!});

    if (releaseAfter != null) {
      Future.delayed(releaseAfter, () {
        currentQeraaPlaying = null;
        player.stop();
        emit(ChangeCurrentPlayingQeraaFileState(null));
      });
    }
  }

  ///* Method to filter the qeraat list for the clicked item only
  filterQeraatListOnHighlightClicked(
    KhelafiaWordModel target,
    List<KhelafiaWordModel> allKalemat,
  ) {
    final currentState = state;
    if (currentState is TenreadingsServicesLoaded) {
      final List<KhelafiaWordModel> filteredList = [allKalemat.where((compare) => compare.wordOrder == target.wordOrder).toList().first];

      log("filterQeraatListOnHighlightClicked: look allKalemat.length=${allKalemat.length}");
      lastServicesStateLoaded =
          TenreadingsServicesLoaded(khelfiaWords: allKalemat, clickedWord: filteredList, osoul: currentState.osoul, hwamishModel: currentState.hwamishModel, shwahidDalalatGroups: currentState.shwahidDalalatGroups, coloredImageFile: currentState.coloredImageFile, now: DateTime.now());
      emit(lastServicesStateLoaded!);
    }
  }

  void playWordQeraat(KhelafiaWordModel khelafiaWord) async {
    var playList = ConcatenatingAudioSource(children: [
      for (var qeraa in khelafiaWord.qeraat!) AudioSource.uri(File(qeraa.file!).uri),
    ]);
    try {
      await player.setAudioSource(playList, preload: true).then((value) {
        if (value != null) {
          player.play();
          Future.delayed(value, () => emit(lastServicesStateLoaded!));
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error with audio source");
      }
    }
  }

  ///* methods to handle completing download
  _resetTimer() {
    if (timer != null) {
      timer!.cancel();
      maxWait = 10;
      emit(TimerTickState(maxWait));
      timer = Timer.periodic(const Duration(seconds: 1), (tm) {
        if (maxWait > 0) {
          {
            maxWait--;
            emit(TimerTickState(maxWait));
          }
        } else {
          timer!.cancel();
          emit(TimerTickState(100));
          maxWait = 10;
          isDownloadingAssets = false;
          currentlyDownloadingPages = [];
          readDownloadedJsonFilesForCurrrentPage();
          log("timer finished");
        }
      });
      log("timer resetted");
    }
  }

  _startTimer() {
    log("timer started");
    if (timer != null && timer!.isActive) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (tm) {
      if (maxWait > 0) {
        maxWait--;
        emit(TimerTickState(maxWait));
      } else {
        timer!.cancel();
        emit(TimerTickState(100));
        maxWait = 10;
        readDownloadedJsonFilesForCurrrentPage();
        log("timer finished");
      }
    });
  }

  void deleteAllTenFilesFiles() async {
    try {
      var dir = await getTenReadingsFolder;
      dir.deleteSync(recursive: true);
      emit(TenReadingsFilesDeletedSuccessfully());
    } catch (e) {
      emit(TenReadingsFilesDeleteError());
      FirebaseAnalytics.instance.logEvent(name: AppStrings.analytcsEventTenReadingsFilesDeleted);
    }
  }

  void downloadFullQuranTenReadingsFiles() async {
    final lastReadyPage = await _getLastReadyPage();
    if (lastReadyPage != null) {
      downloadFilesForPageRange(start: 1, end: lastReadyPage);
    }
  }

  checkIfAppNeedsUpadateToShowPage() async {
    emit(TenreadingLoading());
    final response = await dioConsumer.get("${EndPoints.getTenReadingsServicesForSinglePage}/$currentPage");

    if (response.statusCode == 400) {
      return true;
    } else {
      return false;
    }
  }

  /// methods to set or reset [isNeedUpdateDialogShown] flag
  setIsNeedUpdateDialogShown() {
    isNeedUpdateDialogShown = true;
    emit(SetIsNeedUpdateDialogShownState());
  }

  resetIsNeedUpdateDialogShown() {
    isNeedUpdateDialogShown = false;
    emit(ResetIsNeedUpdateDialogShownState());
  }
}
