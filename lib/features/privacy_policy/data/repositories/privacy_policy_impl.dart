import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';
import '../../domain/repositories/privacy_policy_repository.dart';
import '../datasources/privacy_policy_remote_data_source.dart';

class PrivacyPolicyRepositoryImpl implements PrivacyPolicyRepository {
  final PrivacyPolicyRemoteDataSource remoteDataSource;

  PrivacyPolicyRepositoryImpl({
    required this.remoteDataSource,
  });
  @override
  Future<Either<Failure, SettingResponse>> getPriacyPolicy() async {
    try {
      final response =
          await remoteDataSource.getPriacyPolicy();
      return Right(response);
    } on ServerException catch (exception) {
      return Left(ServerFailure(message: exception.message));
    }
  }
}

// class TermsAndConditionsRepositoryImpl implements TermsAndConditionsRepository {
//   final TermsAndConditionsRemoteDataSource termsAndConditionsRemoteDataSource;

//   TermsAndConditionsRepositoryImpl({
//     required this.termsAndConditionsRemoteDataSource,
//   });
//   @override
//   Future<Either<Failure, String>> getTermsAndConditions() async {
//     try {
//       final response =
//           await termsAndConditionsRemoteDataSource.getTermsAndConditions();
//       return Right(response);
//     } on ServerException catch (exception) {
//       return Left(ServerFailure(message: exception.message));
//     }
//   }
// }