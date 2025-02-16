import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/privacy_policy_repository.dart';

class GetPrivacyPolicy implements UseCase<SettingResponse, NoParams> {
  final PrivacyPolicyRepository privacyPolicyStateRepository;
  GetPrivacyPolicy({required this.privacyPolicyStateRepository});

  @override
  Future<Either<Failure, SettingResponse>> call(NoParams params) async =>
      await privacyPolicyStateRepository.getPriacyPolicy();
}
