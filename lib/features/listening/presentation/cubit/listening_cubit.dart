// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_single_cascade_in_expression_statements

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/encode_arabic_digits.dart';
import 'package:quran_app/features/listening/data/datasources/available_reciters.dart';
import 'package:quran_app/features/listening/data/models/Ayah_sound_model.dart';
import 'package:quran_app/features/listening/data/models/reciter_model.dart';
import 'package:quran_app/features/listening/presentation/screens/section_repeat_enum%7B.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/data_sources/all_ayat_without_tashkeel.dart';
import '../../../../core/utils/audio_handler.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';

part 'listening_state.dart';

class ListeningCubit extends Cubit<ListeningState> {
  ListeningCubit(
      {required this.dioConsumer,
      required this.player,
      required this.playerHandler,
      required this.sharedPreferences,
      required this.internetConnectionChecker})
      : super(ListeningInitial());
  static ListeningCubit get(context) => BlocProvider.of(context);
  DioConsumer dioConsumer;
  AudioPlayer player;
  final AudioPlayerHandler playerHandler;
  final SharedPreferences sharedPreferences;
  final InternetConnectionChecker internetConnectionChecker;

  List<AyahModel> get allAyat => allAyatWithoutTashkelMapList
      .map((ayah) => AyahModel.fromJson(ayah))
      .toList();
  bool isToChooseRepeat = false;
  bool isToChooseSheikh = false;
  int currentPage = 1;
  int pageBeingCached = 1;
  List<int> downloadingZipFilesListForSheikh = [];
  List<String> zipFilesDownloadProgress = [];

  bool isDownloading = false;
  bool allowContinuousListening = false;

  String? appDirectory;
  late File logFile;
  late String currentReciterFolderPath;
  List<ReciterModel> recitersList = availableReciters
      .map((reciter) => ReciterModel.fromJson(reciter))
      .toList();
  ReciterModel? currentReciter;
  List<AyahModel> ayatPlayList = [];
  bool enablePlayInBackground = true;

  //* Methods

  Future<void> init() async {
    // player = AudioPlayer();
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    appDirectory = dir!.path;
    logFile = File("$appDirectory/download_log.txt")..createSync();
    var savedReciterId = sharedPreferences.getInt(AppStrings.savedReciterKey);
    if (savedReciterId != null) {
      currentReciter = availableReciters
          .map((reciter) => ReciterModel.fromJson(reciter))
          .toList()
          .where((element) => element.id == savedReciterId)
          .toList()
          .first;
    } else {
      currentReciter = availableReciters
          .map((reciter) => ReciterModel.fromJson(reciter))
          .toList()
          .first;
    }

    emit(ChangeCurrentReciterState(currentReciter!));
    currentReciterFolderPath =
        "${appDirectory!}/${encodeArabbicCharToEn(currentReciter!.nameEnglish.toString())}/";
    await Directory(currentReciterFolderPath).create();
    log("appDirectory=$appDirectory");
    log("defaultReciterFolderPath=$currentReciterFolderPath");
    setEnablePlayInBackground(
        sharedPreferences.getBool(AppStrings.enablePlayInBackgroundKey) ??
            true);
    _listenToPlayerIndex();
    _listenToPlayerState();
  }

  _listenToPlayerIndex() {
    player.currentIndexStream.listen((currentIndex) async {
      if (currentIndex != null) {
        if (ayatPlayList.isNotEmpty) {
          if (ayatPlayList[currentIndex].page != currentPage &&
              allowContinuousListening == false) {
            await _navigateToCurrentAyahPage(ayatPlayList[currentIndex].page ??
                ayatPlayList[currentIndex + 1].page!);
            await Future.delayed(Duration(seconds: 1));
          }
          if (allowContinuousListening && pageBeingCached == currentPage) {
            pageBeingCached = currentPage + 1;
            _startCachingNextPage(pageBeingCached);
          }

          //todo: emit a state containing the current playing ayah
          await addAyahToMediaItem(ayah: ayatPlayList[currentIndex]);
          emit(ChangeHighlightedAyah(ayatPlayList[currentIndex]));
        }
      }
    });
  }

  _listenToPlayerState() {
    player.playerStateStream.distinct().listen((currentPlayerState) {
      log("🎵playerStateStream: playing=${currentPlayerState.playing}, proccessState=${currentPlayerState.processingState}");
      if ([ProcessingState.idle].contains(currentPlayerState.processingState)) {
        emit(PlayerStopped());
      } else if (currentPlayerState.processingState ==
          ProcessingState.completed) {
        if (allowContinuousListening &&
            state is! AudioDownloading &&
            state is! ChangeCurrentPageState &&
            state is! NavigateToCurrentAyahPageState) {
          _navigateToCurrentAyahPage(currentPage + 1);
          Future.delayed(const Duration(seconds: 0), () {
            listenToCurrentPage(repeatType: SectionRepeatType.continuous);
          });
          return;
        }
        player.stop();
      }
    });
  }

  Future<void> forceStopPlayer() async {
    await player.stop();
    emit(PlayerStopped());
  }

  void returnToControllersView() {
    emit(ListeningInitial());
    isToChooseRepeat = false;
    isToChooseSheikh = false;
  }

  void showChooseShiekh() {
    emit(ListeningInitial());
    isToChooseRepeat = false;
    isToChooseSheikh = true;
    emit(ShowShiekhViewState());
  }

  void showChooseRepeat() {
    emit(ListeningInitial());
    isToChooseSheikh = false;
    isToChooseRepeat = true;
    emit(ShowShiekhViewState());
  }

  Future<void> changeCurrentPage(int newPage) async {
    currentPage = newPage;
    pageBeingCached = newPage;
    emit(ChangeCurrentPageState(currentPage));
    log("ListeningCubit=> currentPage=$currentPage");

    // player.setLoopMode(LoopMode.all);
  }

  //* methods to handle downloading undownloaded files yet

  Future<Response?> downloadAyahMp3FileForDefaultReciter(
      {required AyahModel ayahModel}) async {
    return await dioConsumer
        .get(
            "${EndPoints.defualtReciterAyahFile}${ayahModel.surahNumber}/${ayahModel.numberInSurah}")
        .then((response) async {
      log("📩ListeningCubit=> get ${ayahModel.surahNumber}:${ayahModel.numberInSurah} metadata responseData= ${response.data}");
      if (response.statusCode == 200) {
        //todo: when success start downloading the file
        AyahSoundModel ayahSoundModel =
            AyahSoundModel.fromJson(jsonDecode(response.data));
        await downloadAyahFile(
            ayahModel: ayahModel,
            remoteFilePath: ayahSoundModel.file!,
            shiekhFolderPath: currentReciterFolderPath);
      } else {
        //todo: network error orr file path is not correct
      }
      return null;
    });
  }

  Future<File> downloadZipFile(
      String url, String reciterFolderPath, int reciterId) async {
    var dio = Dio();
    var dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    var zipFileName = '$reciterId' + url.split(RegExp(r'/')).last;
    File zipFile = File('${dir!.path}/$zipFileName');
    if (await zipFile.exists()) {
      debugPrint("File already downloaded");
      await zipFile.delete();
    }
    downloadingZipFilesListForSheikh.add(reciterId);
    zipFilesDownloadProgress.add("0 %");
    emit(AudioDownloading(value: "$reciterId"));
    var response = await dio.download(url, zipFile.path,
        onReceiveProgress: (received, total) {
      var percentage = (received / total * 100);
      zipFilesDownloadProgress[downloadingZipFilesListForSheikh
          .indexOf(reciterId)] = "${percentage.toStringAsFixed(2)} %";
      if (percentage == 100) {
        //todo: show unzipping icon [enhancement]
      }
      emit(AudioDownloading(value: "$percentage%$reciterId"));
      debugPrint("Downloading: $reciterId-${percentage.toStringAsFixed(2)}%");
    });
    await extractZipFile(zipFile, reciterFolderPath, reciterId);
    return zipFile;
  }

  Future<List<File>> extractZipFile(
    File zipFile,
    String reciterFolderPath,
    int? reciterId,
  ) async {
    try {
      var archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
      var mp3Files = <File>[];
      var dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      var fileName = zipFile.path
          .split(RegExp(r'/'))
          .last
          .split('.')[0]; // get the zip file name
      var zipFolder = Directory(reciterFolderPath)
        ..createSync(
            recursive: true); // create the folder to store extracted files

      for (var file in archive) {
        if (file.isFile) {
          if (file.name.endsWith('.mp3')) {
            var fileName = file.name;
            var content = file.content;
            var newFile = File('${zipFolder.path}/$fileName');
            var parent = newFile.parent;
            if (!await parent.exists()) {
              await parent.create(recursive: true);
            }
            await newFile.writeAsBytes(content);
            mp3Files.add(newFile);
            debugPrint("📥ListeningCubit=> file extracted: ${newFile.path}");
          }
        } else if (await AppConstants.isDirectory(file.name)) {
          var dirName = file.name;
          var newDir = Directory('${zipFolder.path}/$dirName');
          if (!await newDir.exists()) {
            await newDir.create(recursive: true);
          }
        }
      }
      zipFilesDownloadProgress
          .removeAt(downloadingZipFilesListForSheikh.indexOf(reciterId!));
      downloadingZipFilesListForSheikh.remove(reciterId);
      emit(AudioDownloadSuccess(msg: "$reciterId"));
      zipFile..deleteSync(); //delete zip file after extracting
      return mp3Files;
    } catch (e) {
      debugPrint(e.toString());
      zipFilesDownloadProgress
          .removeAt(downloadingZipFilesListForSheikh.indexOf(reciterId!));
      downloadingZipFilesListForSheikh.remove(reciterId);
      emit(AudioDownloadError());
      throw Exception('Error extracting zip file: $e');
    }
  }

  Future<Response?> downloadAyahFile(
      {required AyahModel ayahModel,
      required String remoteFilePath,
      required String shiekhFolderPath,
      bool isPreCacheMode = false,
      bool isToEmitDownloading = true,
      bool isToEmitNoInternet = true}) async {
    String storagePath =
        "$shiekhFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayahModel)}";
    if (File(storagePath).existsSync()) {
      return null;
    }
    if (!isPreCacheMode) {
      isDownloading = true;
    }
    emit(const AudioDownloading());
    Dio dio = Dio();
    final DioConsumer downloadConsumer = DioConsumer(client: dio);

    return downloadConsumer
        .download(
            remoteUrl: remoteFilePath,
            storagePath: storagePath,
            onRecieveProgress: (received, total) {
              if (total != -1 && isToEmitDownloading == true) {
                emit(AudioDownloading(value: (received / total).toString()));
                if ((received / total) == 1) {
                  String contents = logFile.readAsStringSync();
                  contents += '\n$storagePath';
                  logFile.writeAsStringSync(contents);
                  emit(AudioDownloadSuccess());
                }
              }
            })
        .onError((e, _) {
      throw e!;
    }).catchError((e) {
      isDownloading = false;
      if (!isPreCacheMode) {
        forceStopPlayer();
      }
      if (isToEmitNoInternet) {
        emit(CheckYourNetworkConnectionState());
      }
      return Response(requestOptions: RequestOptions(path: remoteFilePath));
    });
  }

  String encodeCorrectAyahFileNameToStoreLocally(AyahModel ayahModel) {
    // todo: complete this to be like 001-002.mp3 for surah #1 and ayah #2
    String surahString = numberTo3DigitString(ayahModel.surahNumber!);
    String ayahString = numberTo3DigitString(ayahModel.numberInSurah!);
    return "$surahString/$surahString-$ayahString.mp3";
  }

  String numberTo3DigitString(num input) {
    String buffer = input.toInt().toString();
    buffer = buffer.length == 1
        ? "00$buffer"
        : buffer.length == 2
            ? "0$buffer"
            : buffer;
    return buffer;
  }

  String encodeRemoteMp3FilePath(AyahModel ayahModel,
      {int reciterId = 1, ReciterModel? reciter}) {
    String surahString = numberTo3DigitString(ayahModel.surahNumber!);
    String ayahString = numberTo3DigitString(ayahModel.numberInSurah!);
    return "${EndPoints.recitersMp3RemoteFolder}/${reciter != null ? reciter.id! : currentReciter!.id}/$surahString/$surahString-$ayahString.mp3";
  }

  bool isAllFilesDownloaded(List<AyahModel> ayatInCurrentSection) {
    return ayatInCurrentSection.every((ayah) {
      String pathToCheck = File(
              "$currentReciterFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayah)}")
          .path;
      return File(pathToCheck).existsSync();
    });
  }

  void setCurrentReciter(ReciterModel newReciter) async {
    emit(ListeningInitial());
    currentReciter = newReciter;
    sharedPreferences.setInt(AppStrings.savedReciterKey, newReciter.id!);
    currentReciterFolderPath =
        "${appDirectory!}/${encodeArabbicCharToEn(newReciter.nameEnglish.toString())}/";
    Directory(currentReciterFolderPath).createSync();
    player.stop();

    returnToControllersView();
    emit(ChangeCurrentReciterState(newReciter));
    await FirebaseAnalytics.instance.logEvent(
        name: "selectReciter", parameters: {'name': newReciter.nameArabic!});
  }

  String getReciterFolderPath(reciterModel) {
    if (appDirectory != null) {
      return "${appDirectory!}/${encodeArabbicCharToEn(reciterModel.nameEnglish.toString())}/";
    } else {
      return '';
    }
  }

  void deleteAllFilesForReciter(
      {required ReciterModel reciterModel, required String reciterFolderPath}) {
    try {
      if (!Directory(reciterFolderPath).existsSync()) {
        emit(ReciterFilesDeleteError());
        emit(ListeningInitial());
        return;
      }
      if (currentReciter!.id == reciterModel!.id) {
        player.stop();
      }
      Directory(reciterFolderPath).deleteSync(recursive: true);
      String contents = logFile.readAsStringSync();
      contents =
          contents.replaceAll(RegExp(r'' + reciterFolderPath + r'.*'), '');
      logFile.writeAsString(contents);
      emit(ReciterFilesDeletedSuccessfully(
          reciterFolderPath: reciterFolderPath));
      FirebaseAnalytics.instance.logEvent(
          name: AppStrings.analytcsEventShiekhFilesDeleted,
          parameters: {"name": reciterModel.nameArabic!});
    } catch (e) {
      emit(ReciterFilesDeleteError());
      emit(ListeningInitial());
    }
  }

  void downloadFullQuranForReciter(ReciterModel reciterModel) {}

  void listenToAyah({required AyahModel ayah}) {
    returnToControllersView();
    emit(ChangeHighlightedAyah(ayah));
    listenToCurrentPage(ayatForCustomRange: [ayah.number, ayah.number]);
  }

  void startListenFromAyah({required AyahModel ayah}) {
    emit(ChangeHighlightedAyah(ayah));
    listenToCurrentPage(
        repeatType: SectionRepeatType.continuous,
        ayatForCustomRange: [ayah.number, null]);
  }

  setEnablePlayInBackground(bool enabled) {
    enablePlayInBackground = enabled;
    sharedPreferences.setBool(AppStrings.enablePlayInBackgroundKey, enabled);
    log("enablePlayInBackground=$enablePlayInBackground");
    if (!enabled) {
    } else {}
    emit(ChangeEnablePlayInBackgroundState(enabled: enabled));
  }

  Future<void> addAyahToMediaItem({required AyahModel ayah}) async {
    if (!enablePlayInBackground) {
      playerHandler.mediaItem.close();

      return;
    }
    playerHandler.mediaItem.add(
      MediaItem(
          id: '',
          title:
              '${ayah.surah ?? ayatPlayList[ayatPlayList.indexOf(ayah) + 1].surah}',
          artist: "${currentReciter!.nameArabic}",
          artUri: await getImageFileFromAssets(AppAssets.appIcon)),
    );
  }

  void listenAccordingToType(
      {SectionRepeatType repeatType = SectionRepeatType.custom,
      int? sectionValue,
      List<int?> ayatForCustomRange = const [],
      int sectionRepeatCount = 1,
      int ayahRepeatCount = 1}) {}

  Future<void> listenToCurrentPage(
      {SectionRepeatType repeatType = SectionRepeatType.custom,
      int? sectionValue,
      List<int?> ayatForCustomRange = const [null, null],
      int? sectionRepeatCount = 1,
      int? ayahRepeatCount = 1}) async {
    List<AyahModel> ayatRange = [];
    List<int> indeciesList = [];
    allowContinuousListening = false;

    if (repeatType == SectionRepeatType.custom) {
      int start =
          allAyat.indexWhere((ayah) => ayah.number == ayatForCustomRange.first);
      int end =
          allAyat.indexWhere((ayah) => ayah.number == ayatForCustomRange.last) +
              1;
      ayatRange = allAyat.getRange(start, end).toList();
    } else if (repeatType == SectionRepeatType.page) {
      ayatRange =
          allAyat.where((element) => element.page == sectionValue).toList();
    } else if (repeatType == SectionRepeatType.surah) {
      ayatRange = allAyat
          .where((element) => element.surahNumber == sectionValue)
          .toList();
    } else if (repeatType == SectionRepeatType.hizb) {
      List<int> qurtersInHizb = findQurtersInHizb(sectionValue!);
      ayatRange = allAyat
          .where((element) => qurtersInHizb.contains(element.hizbQuarter))
          .toList();
    } else if (repeatType == SectionRepeatType.juz) {
      ayatRange =
          allAyat.where((element) => element.juz == sectionValue).toList();
    } else if (repeatType == SectionRepeatType.continuous) {
      allowContinuousListening = true;
      ayahRepeatCount = null;
      sectionRepeatCount = null;

      if (ayatForCustomRange.first != null) {
        ayatRange = allAyat
            .where((element) =>
                element.page == currentPage &&
                element.number! >= ayatForCustomRange.first!)
            .toList();
      } else {
        ayatRange =
            allAyat.where((element) => element.page == currentPage).toList();
      }
    }

    log("ListeningCubit=> we have ${ayatRange.length} ayahs in current page");

    if (ayatRange.any((ayah1) =>
        ayah1.numberInSurah == 1 && ![1, 9].contains(ayah1.surahNumber))) {
      for (int i = 0; i < ayatRange.length; i++) {
        if (ayatRange[i].numberInSurah == 1 &&
            ![1, 9].contains(ayatRange[i]..surahNumber)) {
          indeciesList.add(i);
        }
      }

      for (int occIndex in indeciesList) {
        ayatRange.insert(
            occIndex + indeciesList.indexOf(occIndex),
            AyahModel(
              number: 1,
              numberInSurah: 1,
              surahNumber: 1,
            ));
      }
    }
    await _navigateToCurrentAyahPage(
        ayatRange.first.page ?? ayatRange[1].page!);

    ///todos:
    ///1-first check if the file exists already if YES add to the playList, else download it and then add it to the playList
    ///2- after you made sure that all files are existing then play the playList

    log("⌚ListeningCubit=> still not all the files found");
    bool isFilesDownloaded = isAllFilesDownloaded(ayatRange);

    if (!isFilesDownloaded) {
      if (!await internetConnectionChecker.hasConnection) {
        isDownloading = false;
        forceStopPlayer();
        print("no internet connection");
        emit(CheckYourNetworkConnectionState());
        return;
      }
      await Future.forEach(ayatRange, (ayah) async {
        await downloadAyahFile(
            ayahModel: ayah as AyahModel,
            remoteFilePath: encodeRemoteMp3FilePath(ayah as AyahModel),
            shiekhFolderPath: currentReciterFolderPath);
      });
    }

    isFilesDownloaded = isAllFilesDownloaded(ayatRange);

    late ConcatenatingAudioSource playList;

    if (isFilesDownloaded) {
      isDownloading = false;
      //* repeat  ayat
      if (ayahRepeatCount != null) {
        List<AyahModel> repeatedAyatList = [];
        for (final ayah in ayatRange) {
          if (ayah.page == null) {
            repeatedAyatList.add(ayah);
            continue;
          }
          for (int i = 0; i < ayahRepeatCount; i++) {
            repeatedAyatList.add(ayah);
          }
        }
        ayatRange = repeatedAyatList;
      }

      //* repeat  section
      if (sectionRepeatCount != null) {
        List<AyahModel> repeatedSectionsList = [];
        for (int i = 0; i < sectionRepeatCount; i++) {
          repeatedSectionsList.addAll(ayatRange);
        }

        ayatRange = repeatedSectionsList;
      }

      ayatPlayList = ayatRange;
      playList = ConcatenatingAudioSource(
        useLazyPreparation: false,
        children: [
          for (AyahModel ayah in ayatRange)
            AudioSource.uri(
              File("$currentReciterFolderPath${encodeCorrectAyahFileNameToStoreLocally(ayah)}")
                  .uri,
            ),
        ],
      );

      emit(ChangeHighlightedAyah(ayatRange[0]));
      addAyahToMediaItem(ayah: ayatPlayList[0]);
      await player.setAudioSource(playList, preload: true);
      if (ayatRange.first.page != currentPage) {
        await _navigateToCurrentAyahPage(
            ayatRange.first.page ?? ayatRange[1].page!);
      }
      await player.play();
      FirebaseAnalytics.instance.logEvent(
          name: "Repeat Feature", parameters: {"type": repeatType.toString()});
    } else {
      log("😭Not all files downloaded yet");
    }
  }

  List<int> findQurtersInHizb(int hizb) {
    int firstQuarterInHizb = hizb * 4 - 4 + 1;
    List<int> qurters =
        List<int>.generate(4, (index) => index + firstQuarterInHizb);
    return qurters;
  }

  _navigateToCurrentAyahPage(int ayahPage) async {
    emit(NavigateToCurrentAyahPageState(page: ayahPage));
    await Future.delayed(const Duration(seconds: 1));
  }

  void _startCachingNextPage(int pageToCache) async {
    if (pageToCache > 604) {
      return;
    } else {
      List<AyahModel> ayatInPageToCache =
          allAyat.where((element) => element.page == pageToCache).toList();
      log("caching started on page=$pageToCache");

      await Future.forEach(ayatInPageToCache, (ayah) async {
        if (!await internetConnectionChecker.hasConnection) {
          isDownloading = false;

          return;
        }
        await downloadAyahFile(
          ayahModel: ayah as AyahModel,
          remoteFilePath: encodeRemoteMp3FilePath(ayah as AyahModel),
          shiekhFolderPath: currentReciterFolderPath,
          isPreCacheMode: true,
        );
      });
    }
  }

  Future<Uri> getImageFileFromAssets(String assetArt) async {
    final byteData = await rootBundle.load('$assetArt');
    final buffer = byteData.buffer;
    Directory tempDir = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath +
        '/audio-icon.png'; // file_01.tmp is dump file, can be anything
    if (File(filePath).existsSync()) {
      return File(filePath).uri;
    } else {
      return (await File(filePath).writeAsBytes(buffer.asUint8List(
              byteData.offsetInBytes, byteData.lengthInBytes)))
          .uri;
    }
  }

  Future<bool?>? downloadReciterMp3sPageByPage(
      ReciterModel reciterModel, String reciterFolderPath) async {
    if (downloadingZipFilesListForSheikh.isNotEmpty) {
      emit(WaitUntilDownloadFininsh());
      emit(ListeningInitial());
      return false;
    }
    if (!await internetConnectionChecker.hasConnection) {
      isDownloading = false;
      forceStopPlayer();
      downloadingZipFilesListForSheikh.clear();
      zipFilesDownloadProgress.clear();
      emit(CheckYourNetworkConnectionState());
      return false;
    } else {
      downloadingZipFilesListForSheikh.add(reciterModel.id!);
      zipFilesDownloadProgress.add("0");
      int? data = sharedPreferences.getInt((reciterModel?.id ?? 1).toString());
      int page = data ?? 0;

      List<int> pages = List<int>.generate(605 - page, (index) => index + page);

      for (int pageCounter in pages) {
        if (!await internetConnectionChecker.hasConnection) {
          isDownloading = false;

          downloadingZipFilesListForSheikh.clear;
          zipFilesDownloadProgress.clear();
          emit(CheckYourNetworkConnectionState());
          pages = [];
          await Future.delayed(Duration(seconds: 1));
          break;
        }
        if (downloadingZipFilesListForSheikh.isNotEmpty &&
            zipFilesDownloadProgress.isNotEmpty) {
          zipFilesDownloadProgress[downloadingZipFilesListForSheikh
              .indexOf(reciterModel.id!)] = "$pageCounter";
        }
        await sharedPreferences.setInt(
            (reciterModel?.id ?? 0).toString(), pageCounter);
        List<AyahModel> ayatForPage =
            allAyat.where((element) => element.page == pageCounter).toList();
        List<AyahModel> copyAyatForPage = List<AyahModel>.from(ayatForPage);
        for (int i = 0; i < copyAyatForPage.length; i++) {
          String storagePath =
              "$reciterFolderPath${encodeCorrectAyahFileNameToStoreLocally(copyAyatForPage[i])}";
          String url = encodeRemoteMp3FilePath(copyAyatForPage[i],
              reciter: reciterModel);
          var response = await Dio().get(url);
          int fileLength = int.tryParse(
                  (response.headers["content-length"])?.first ?? "0") ??
              0;
          if (File(storagePath).existsSync()) {
            if (File(storagePath).lengthSync() >= fileLength) {
              ayatForPage.removeWhere((element) =>
                  element.numberInSurah == copyAyatForPage[i].numberInSurah);
            } else {
              File(storagePath).deleteSync();
            }
          }
        }
        if (ayatForPage.length == 0) {
          continue;
        }
        emit(ShiekhMp3PageDownloadCounterChanged(pageCounter as int));

        await Future.wait([
          for (var ayah in ayatForPage)
            downloadAyahFile(
                ayahModel: ayah,
                remoteFilePath:
                    encodeRemoteMp3FilePath(ayah, reciter: reciterModel),
                shiekhFolderPath: reciterFolderPath,
                isToEmitDownloading: false,
                isToEmitNoInternet: false,
                isPreCacheMode: true),
        ]);
        await Future.delayed(const Duration(seconds: 1));
      }

      log("completed name ${reciterModel.nameEnglish}");
      zipFilesDownloadProgress.clear();
      downloadingZipFilesListForSheikh.clear();

      emit(ShiekhMp3PageDownloadCounterChanged(605));
      await FirebaseAnalytics.instance.logEvent(
          name: AppStrings.analytcsEventShiekhFilesDeleted,
          parameters: {'name': reciterModel.nameArabic!});
    }
  }

  void pausePlayer() async {
    if (player.playing) {
      player.pause();
      await Future.delayed(Duration(milliseconds: 300));
    }
  }
}
