// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'tafseer_cubit.dart';

abstract class TafseerState extends Equatable {
  const TafseerState();

  @override
  List<Object> get props => [];
}

class TafseerInitial extends TafseerState {}

class PageTafseersLoaded extends TafseerState {
  List<AyahTafseerModel> tafseers;
  PageTafseersLoaded({this.tafseers = const []});

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is PageTafseersLoaded && listEquals(other.tafseers, tafseers);
  }

  @override
  int get hashCode => tafseers.hashCode;
}

class PageTafseersError extends TafseerState {}
