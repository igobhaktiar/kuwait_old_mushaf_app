import 'package:dartz/dartz.dart';
import 'package:quran_app/features/terms_and_conditions/domain/repositories/terms_and_conditions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';
import '../../../../core/usecases/usecase.dart';

class GetTermsAndConditions implements UseCase<SettingResponse, NoParams> {
  final TermsAndConditionsRepository termsAndConditionsRepository;
  GetTermsAndConditions({required this.termsAndConditionsRepository});

  @override
  Future<Either<Failure, SettingResponse>> call(NoParams params) async =>
      await termsAndConditionsRepository.getTermsAndConditions();
}
