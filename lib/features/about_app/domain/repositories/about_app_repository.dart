import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';

abstract class AboutAppRepository {
  Future<Either<Failure, SettingResponse>> getContentOfAboutApp();
}
