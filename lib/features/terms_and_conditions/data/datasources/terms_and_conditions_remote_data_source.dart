import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/core/responses/setting_response.dart';

import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/models/content.dart';
import '../../../../core/utils/app_strings.dart';

abstract class TermsAndConditionsRemoteDataSource {
  Future<SettingResponse> getTermsAndConditions();
}

class TermsAndConditionsRemoteDataSourceImpl
    implements TermsAndConditionsRemoteDataSource {
  final DioConsumer apiConsumer;
  TermsAndConditionsRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<SettingResponse> getTermsAndConditions() async {
    final response = await apiConsumer.get(
      EndPoints.settings,
    );
    SettingResponse settingResponse = SettingResponse();
    final responseJson = jsonDecode(response.toString());

    Iterable iterable = responseJson[AppStrings.termsAndConditions];
    settingResponse.data =
        iterable.map((model) => Content.fromJson(model)).toList();
    Hive.box(AppStrings.termsAndConditions)
        .put(AppStrings.termsAndConditionsBoxKey, settingResponse.data);
    return settingResponse;
  }
}
