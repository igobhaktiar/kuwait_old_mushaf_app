import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/models/content.dart';
import '../../../../core/responses/setting_response.dart';
import '../../../../core/utils/app_strings.dart';

abstract class AboutAppRemoteDataSource {
  Future<SettingResponse> getContentOfAboutApp();
}

class AboutAppRemoteDataSourceImpl implements AboutAppRemoteDataSource {
  final DioConsumer apiConsumer;
  AboutAppRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<SettingResponse> getContentOfAboutApp() async {
    final response = await apiConsumer.get(
      EndPoints.settings,
    );
    SettingResponse settingResponse = SettingResponse();
    final responseJson = jsonDecode(response.toString());
    Iterable iterable = responseJson[AppStrings.aboutApp];
    settingResponse.data =
        iterable.map((model) => Content.fromJson(model)).toList();
    Hive.box(AppStrings.aboutApp)
        .put(AppStrings.aboutAppBoxKey, settingResponse.data);
    log('about app data: ${settingResponse.data}');
    log('about app box: ${Hive.box(AppStrings.aboutApp).get(AppStrings.aboutAppBoxKey)}');

    return settingResponse;
  }
}
