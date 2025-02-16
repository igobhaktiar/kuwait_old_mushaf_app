import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/content.dart';
import '../../../../core/responses/setting_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_about_app_content.dart';
part 'about_app_state.dart';

class AboutAppCubit extends Cubit<AboutAppState> {
  final GetAboutAppContent getAboutAppContent;
  AboutAppCubit({required this.getAboutAppContent}) : super(AboutAppInitial());

  List<Content> content = [];
  Future<void> getContentOfAboutApp() async {
    if (!(await InternetConnectionChecker.createInstance().hasConnection)) {
      emit(const AboutAppError());
      return;
    }
    emit(AboutAppContentIsLoading());
    Either<Failure, SettingResponse> response =
        await getAboutAppContent.call(NoParams());
    emit(response.fold((failure) => AboutAppError(message: failure.message),
        (content) {
      this.content = content.data;
      log(this.content.toString(), name: 'about app 2');
      return AboutAppContentLoaded(content: content.data);
    }));
  }
}
