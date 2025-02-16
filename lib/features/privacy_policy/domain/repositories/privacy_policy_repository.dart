import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';

abstract class PrivacyPolicyRepository {
  Future<Either<Failure, SettingResponse>> getPriacyPolicy();
}
