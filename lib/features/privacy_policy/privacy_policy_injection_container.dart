import 'package:quran_app/features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import '../../injection_container.dart';
import 'data/datasources/privacy_policy_remote_data_source.dart';
import 'data/repositories/privacy_policy_impl.dart';
import 'domain/repositories/privacy_policy_repository.dart';
import 'domain/usecases/get_privacy_policy.dart';

void initPrivacyPolicyFeature() {
// Blocs
  getItInstance.registerFactory<PrivacyPolicyCubit>(
      () => PrivacyPolicyCubit(privacyPolicyUseCase: getItInstance()));

  // Use cases
  getItInstance.registerLazySingleton<GetPrivacyPolicy>(
      () => GetPrivacyPolicy(privacyPolicyStateRepository: getItInstance()));

  // Repository
  getItInstance.registerLazySingleton<PrivacyPolicyRepository>(
      () => PrivacyPolicyRepositoryImpl(remoteDataSource: getItInstance()));

  // Data sources
  getItInstance.registerLazySingleton<PrivacyPolicyRemoteDataSource>(
      () => PrivacyPolicyRemoteDataSourceImpl(apiConsumer: getItInstance()));
}
