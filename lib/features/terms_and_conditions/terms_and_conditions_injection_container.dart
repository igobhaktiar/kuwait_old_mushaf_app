import 'package:quran_app/features/terms_and_conditions/data/datasources/terms_and_conditions_remote_data_source.dart';
import 'package:quran_app/features/terms_and_conditions/domain/repositories/terms_and_conditions_repository.dart';
import 'package:quran_app/features/terms_and_conditions/presentation/cubit/terms_and_conditions_cubit.dart';
import '../../injection_container.dart';
import 'data/repositories/terms_and_conditions_repository_impl.dart';
import 'domain/usecases/get_terms_and_conditions.dart';

void initTermsAndConditionsFeature() {
// Blocs
  getItInstance.registerFactory<TermsAndConditionsCubit>(
      () => TermsAndConditionsCubit(useCase: getItInstance()));

  // Use cases
  getItInstance.registerLazySingleton<GetTermsAndConditions>(() =>
      GetTermsAndConditions(termsAndConditionsRepository: getItInstance()));

  // Repository
  getItInstance.registerLazySingleton<TermsAndConditionsRepository>(() =>
      TermsAndConditionsRepositoryImpl(
          termsAndConditionsRemoteDataSource: getItInstance()));

  // Data sources
  getItInstance.registerLazySingleton<TermsAndConditionsRemoteDataSource>(() =>
      TermsAndConditionsRemoteDataSourceImpl(apiConsumer: getItInstance()));
}
