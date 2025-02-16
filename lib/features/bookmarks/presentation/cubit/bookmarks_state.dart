part of 'bookmarks_cubit.dart';

abstract class BookmarksState extends Equatable {
  const BookmarksState();

  @override
  List<Object> get props => [];
}

class BookmarksInitial extends BookmarksState {}

class ShowBookmarksOnStartState extends BookmarksState {}
