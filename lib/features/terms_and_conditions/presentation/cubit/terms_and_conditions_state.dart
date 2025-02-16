part of 'terms_and_conditions_cubit.dart';

abstract class TermsAndConditionsState extends Equatable {
  const TermsAndConditionsState();

  @override
  List<Object?> get props => [];
}

class TermsAndConditionsInitial extends TermsAndConditionsState {}

class TermsAndConditionstIsLoading extends TermsAndConditionsState {
//   final bool? isfirst;
//   const TermsAndConditionstIsLoading({this.isfirst}); 
}

class TermsAndConditionsLoaded extends TermsAndConditionsState {
  final List<Content> content;
  const TermsAndConditionsLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}

class TermsAndConditionsError extends TermsAndConditionsState {
  final String? message;
  const TermsAndConditionsError({this.message});
  @override
  List<Object?> get props => [message];
}
