import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quran_app/core/usecases/usecase.dart';
import '../../../../core/models/content.dart';
import '../../domain/usecases/get_privacy_policy.dart';
part 'privacy_policy_state.dart';

class PrivacyPolicyCubit extends Cubit<PrivacyPolicyState> {
  final GetPrivacyPolicy privacyPolicyUseCase;
  PrivacyPolicyCubit({required this.privacyPolicyUseCase})
      : super(PrivacyPolicyStateInitial());

  List<Content> content = [];
  Future<void> getPrivacyPolicy() async {
    if (!(await InternetConnectionChecker.createInstance().hasConnection)) {
      emit(const PrivacyPolicyStateError());
      return;
    }
    emit(PrivacyPolicyStateIsLoading());
    final result = await privacyPolicyUseCase(NoParams());
    result.fold((failure) {
      emit(PrivacyPolicyStateError(message: failure.message));
    }, (content) {
      this.content = content.data;
      emit(PrivacyPolicyStateLoaded(content: content.data));
    });
  }
}
