import 'package:quran_app/features/about_app/presentation/cubit/about_app_cubit.dart';

import '../../injection_container.dart';
import 'data/datasources/about_app_remote_data_source.dart';
import 'data/repositories/about_app_repository_impl.dart';
import 'domain/repositories/about_app_repository.dart';
import 'domain/usecases/get_about_app_content.dart';

void initAboutAppFeature() {
// Blocs
  getItInstance.registerFactory<AboutAppCubit>(
      () => AboutAppCubit(getAboutAppContent: getItInstance()));

  // Use cases
  getItInstance.registerLazySingleton<GetAboutAppContent>(
      () => GetAboutAppContent(aboutAppRepository: getItInstance()));

  // Repository
  getItInstance.registerLazySingleton<AboutAppRepository>(
      () => AboutAppRepositoryImpl(aboutAppRemoteDataSource: getItInstance()));

  // Data sources
  getItInstance.registerLazySingleton<AboutAppRemoteDataSource>(
      () => AboutAppRemoteDataSourceImpl(apiConsumer: getItInstance()));
}
