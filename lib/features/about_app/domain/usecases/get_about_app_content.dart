import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/about_app_repository.dart';

class GetAboutAppContent implements UseCase<SettingResponse, NoParams> {
  final AboutAppRepository aboutAppRepository;
  GetAboutAppContent({required this.aboutAppRepository});

  @override
  Future<Either<Failure, SettingResponse>> call(NoParams params) async =>
      await aboutAppRepository.getContentOfAboutApp();
}
