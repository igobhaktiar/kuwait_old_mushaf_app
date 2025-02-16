import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/responses/setting_response.dart';
import '../../domain/repositories/about_app_repository.dart';
import '../datasources/about_app_remote_data_source.dart';

class AboutAppRepositoryImpl implements AboutAppRepository {
  final AboutAppRemoteDataSource aboutAppRemoteDataSource;

  AboutAppRepositoryImpl({
    required this.aboutAppRemoteDataSource,
  });
  @override
  Future<Either<Failure, SettingResponse>> getContentOfAboutApp() async {
    try {
      final response = await aboutAppRemoteDataSource.getContentOfAboutApp();
      return Right(response);
    } on ServerException catch (exception) {
      return Left(ServerFailure(message: exception.message));
    }
  }
}
