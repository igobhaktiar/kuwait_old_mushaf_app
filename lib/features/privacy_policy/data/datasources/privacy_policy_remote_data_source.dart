import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/core/responses/setting_response.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/models/content.dart';
import '../../../../core/utils/app_strings.dart';

abstract class PrivacyPolicyRemoteDataSource {
  Future<SettingResponse> getPriacyPolicy();
}

class PrivacyPolicyRemoteDataSourceImpl
    implements PrivacyPolicyRemoteDataSource {
  final DioConsumer apiConsumer;
  PrivacyPolicyRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<SettingResponse> getPriacyPolicy() async {
    final response = await apiConsumer.get(
      EndPoints.settings,
    );
    SettingResponse settingResponse = SettingResponse();
    final responseJson = jsonDecode(response.toString());
    Iterable iterable = responseJson[AppStrings.privacyPolicy];
    settingResponse.data =
        iterable.map((model) => Content.fromJson(model)).toList();
    Hive.box(AppStrings.privacyPolicy)
        .put(AppStrings.privacyPolicyBoxKey, settingResponse.data);
    return settingResponse;
  }
}
