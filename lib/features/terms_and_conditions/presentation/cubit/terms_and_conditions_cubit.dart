import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quran_app/core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/content.dart';
import '../../../../core/responses/setting_response.dart';
import '../../domain/usecases/get_terms_and_conditions.dart';
part 'terms_and_conditions_state.dart';

class TermsAndConditionsCubit extends Cubit<TermsAndConditionsState> {
  final GetTermsAndConditions useCase;
  TermsAndConditionsCubit({required this.useCase})
      : super(TermsAndConditionsInitial());

  List<Content> content = [];
  Future<void> getTermsAndConditions() async {
    if (!(await InternetConnectionChecker.createInstance().hasConnection)) {
      emit(const TermsAndConditionsError());
      return;
    }
    emit(TermsAndConditionstIsLoading());
    Either<Failure, SettingResponse> response = await useCase.call(NoParams());
    emit(response
        .fold((failure) => TermsAndConditionsError(message: failure.message),
            (content) {
      this.content = content.data;
      return TermsAndConditionsLoaded(content: content.data);
    }));
  }
}
