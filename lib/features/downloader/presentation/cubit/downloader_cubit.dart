import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/core/api/dio_consumer.dart';
import 'package:quran_app/core/api/end_points.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'downloader_state.dart';

class DownloaderCubit extends Cubit<DownloaderState> {
  DownloaderCubit({required this.dioConsumer, required this.sharedPreferences})
      : super(DownloaderInitial());
  static DownloaderCubit get(context) => BlocProvider.of(context);
  DioConsumer dioConsumer;
  SharedPreferences sharedPreferences;

  //* variables
  late String appDirectory;
  //* Getters

  init() async {
    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    appDirectory = dir!.path;
    log("appDirectory=$appDirectory");
    int lastDefaultPageDowloaded =
        sharedPreferences.getInt(AppStrings.lastDefaultPageDowloaded) ?? -1;
    sharedPreferences.remove(AppStrings.token);
    String? token = sharedPreferences.getString(AppStrings.token);

    // if (token == null) {
    try {
      dioConsumer.post(EndPoints.obtainToken, body: {
        "username": AppStrings.userName,
        "password": AppStrings.password
      }).then((response) {
        if (response.statusCode == 200) {
          String token =
              (jsonDecode(response.data) as Map<String, dynamic>)["token"];
          sharedPreferences.setString(AppStrings.token, token);
          log("saved token: ${sharedPreferences.getString(AppStrings.token)}");
        }
      });
    } catch (e) {
      print("error obtaining token");
    }
    // }
  }

  downloadTenQeraatPages() async {
    String remoteFilePath =
        "https://quranapp.mykuwaitnet.net/media/quran_ten_img/None/P_001_Rd8pV40.png";
    String storagePath =
        "$appDirectory${AppStrings.coloredPages}${extractFileNameFromUrl(remoteFilePath)}";

    if (!File(storagePath).existsSync()) {
      emit(DownloadStarted());
      dioConsumer.download(
          remoteUrl: remoteFilePath,
          storagePath: storagePath,
          onRecieveProgress: (received, total) {
            if (total != -1) {
              emit(DownloadingState(value: (received / total).toString()));
              if ((received / total) == 1) {
                emit(DownloadStoped());
              }
            }
          });
    }
    // Timer timer = Timer.periodic(Duration(seconds: 1), (tm) {
    //   if (tm.tick == 10) {
    //     tm.cancel();
    //     emit(DownloadStoped());
    //   }
    //   log("tick=${tm.tick}");
    //   emit(DownloadingState(value: tm.tick.toString()));
    // });
  }

  String extractFileNameFromUrl(String fileUrl) {
    List<String> urlSegments = fileUrl.split('/').toList();
    if (urlSegments.isEmpty) {
      return "unknkown_file";
    } else {
      return urlSegments.last;
    }
  }
}
