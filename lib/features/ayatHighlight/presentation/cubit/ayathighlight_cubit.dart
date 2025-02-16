import 'dart:convert' show json;
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';
import '../../data/models/ahyah_segs_model.dart';

part 'ayathighlight_state.dart';

class AyatHighlightCubit extends Cubit<AyatHighlightState> {
  AyatHighlightCubit() : super(PageHighlightsChanged(const []));
  static AyatHighlightCubit get(context) => BlocProvider.of(context);

  int currentPage = 1;
  List<AyahSegsModel> currentHighlits = [];

  Future<void> init() async {
    await loadAyatSegs(1);
  }

  loadCurrentPageAyatSeg() async {
    loadAyatSegs(currentPage);
  }

  Future<void> loadAyatSegs(int page) async {
    currentPage = page;
    log("Highlight page# $page", name: "HIGHLIGHTS");
    String jsonString = await rootBundle
        .loadString("assets/json/page_$page.json"); //1,2,3 ...etc
    List jsonSegs = json.decode(jsonString);
    List<AyahSegsModel> ayatSegsList =
        jsonSegs.map((e) => AyahSegsModel.fromJson(e)).toList();
    // log("ayatSegsList.length= ${ayatSegsList.length}", name: "HIGHLIGHTS");
    currentHighlits = ayatSegsList;
    emit(PageHighlightsChanged(ayatSegsList));
  }

  Future<void> highlightAyah(AyahModel targetAyahToHighlight,
      {bool releaseAfterPeriod = true}) async {
    if (state is PageHighlightsChanged) {
      await Future.delayed(const Duration(milliseconds: 200));
      emit(HighlightTarget(state.highlights,
          currentlyHighlight: targetAyahToHighlight));
      if (releaseAfterPeriod == true) {
        Future.delayed(const Duration(seconds: 3), () {
          emit(PageHighlightsChanged(state.highlights,
              currentlyHighlight: null));
        });
      }
    }
  }

  Future<void> highlightPlayingAyah(AyahModel targetAyahToHighlight) async {
    // loadCurrentPageAyatSeg();
    // if (state is PageHighlightsChanged) {
    await Future.delayed(const Duration(milliseconds: 100));
    // emit(HighlightTarget(state.highlights,
    emit(
      HighlightTarget(currentHighlits,
          currentlyHighlight: targetAyahToHighlight),
    );
    // }
  }

  void refreshHighlights() {
    loadCurrentPageAyatSeg();
  }
}
