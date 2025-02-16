import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';

abstract class TermsAndConditionsRepository {
  Future<Either<Failure, SettingResponse>> getTermsAndConditions();
}
