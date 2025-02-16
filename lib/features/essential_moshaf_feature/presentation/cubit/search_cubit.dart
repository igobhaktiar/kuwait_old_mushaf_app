import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data_sources/all_ayat_without_tashkeel.dart';
import '../../../../core/data_sources/swar_fihris.dart';
import '../../../../core/utils/app_strings.dart';
import '../../data/models/ayat_swar_models.dart';
import '../../data/models/fihris_models.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.sharedPreferences}) : super(const SearchInitial(""));
  final SharedPreferences sharedPreferences;

  //*getters
  String lastSearch = '';
  static SearchCubit get(context) => BlocProvider.of(context);
  List<AyahModel> get allAyatWithoutTashkeel =>
      allAyatWithoutTashkelMapList.map((e) => AyahModel.fromJson(e)).toList();
  List<SurahFihrisModel> get swarListForFihris =>
      swarFihrisJson.map((e) => SurahFihrisModel.fromJson(e)).toList();

  //*methods
  searchFor(String searchWord) {
    log("searching for '$searchWord'");
    sharedPreferences.setString(AppStrings.lastSearch, searchWord);
    lastSearch = searchWord;
    print("lastSearch: $lastSearch");
    List<AyahModel> ayatSearchResultsList = allAyatWithoutTashkeel
        .where((element) => element.text!.contains(searchWord))
        .toList();
    List<SurahFihrisModel> swarSearchResultsList = swarListForFihris
        .where((element) =>
            element.name!.contains(searchWord) ||
            element.englishName!.toLowerCase().contains(searchWord))
        .toList();
    log("ayatSearchResultsList length=${ayatSearchResultsList.length}");
    log("swarSearchResultsList length=${swarSearchResultsList.length}");
    if (ayatSearchResultsList.isEmpty && swarSearchResultsList.isEmpty) {
      emit(NoSearchResultsFoundState());
    } else {
      emit(SearchResultsFoundState(
          ayatSearchResults: ayatSearchResultsList,
          swarSearchResults: swarSearchResultsList));
    }
  }

  clearSearch() {
    sharedPreferences.setString(AppStrings.lastSearch, '');
    lastSearch = '';
    emit(StartSearchState());
  }

  getLastSearch() {
    lastSearch = sharedPreferences.getString(AppStrings.lastSearch) ?? '';
    if (lastSearch.isNotEmpty) {
      searchFor(lastSearch);
    } else {
      clearSearch();
    }
  }
}
