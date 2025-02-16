part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {
  final String lastSearch;

  const SearchInitial(this.lastSearch);
}

class SearchResultsFoundState extends SearchState {
  List<AyahModel> ayatSearchResults;
  List<SurahFihrisModel> swarSearchResults;
  SearchResultsFoundState(
      {this.ayatSearchResults = const [], this.swarSearchResults = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultsFoundState &&
        listEquals(other.ayatSearchResults, ayatSearchResults) &&
        listEquals(other.swarSearchResults, swarSearchResults);
  }

  @override
  int get hashCode => ayatSearchResults.hashCode ^ swarSearchResults.hashCode;
}

class NoSearchResultsFoundState extends SearchState {}

class StartSearchState extends SearchState {}
