import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:quran_app/features/tafseer/data/models/tafseer_model.dart';

import '../../data/datasources/tafseer_list.dart';

part 'tafseer_state.dart';

class TafseerCubit extends Cubit<TafseerState> {
  TafseerCubit() : super(TafseerInitial());

  //* getters
  List<AyahTafseerModel> get allQuranTafseer =>
      tafseerList.map((e) => AyahTafseerModel.fromJson(e)).toList();

  //*methods

  init() => loadCurrentPageTafseer(1);

  loadCurrentPageTafseer(int currentPage) {
    List<AyahTafseerModel> tafseersInCurrentPage = allQuranTafseer
        .where((element) => element.page == currentPage)
        .toList();
    emit(PageTafseersLoaded(tafseers: tafseersInCurrentPage));
  }
}
