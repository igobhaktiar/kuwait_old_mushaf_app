part of 'privacy_policy_cubit.dart';

abstract class PrivacyPolicyState extends Equatable {
  const PrivacyPolicyState();

  @override
  List<Object?> get props => [];
}

class PrivacyPolicyStateInitial extends PrivacyPolicyState {}

class PrivacyPolicyStateIsLoading extends PrivacyPolicyState {}

class PrivacyPolicyStateLoaded extends PrivacyPolicyState {
  final  List<Content> content;
  const PrivacyPolicyStateLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}

class PrivacyPolicyStateError extends PrivacyPolicyState {
  final String? message;
  const PrivacyPolicyStateError({this.message});
  @override
  List<Object?> get props => [message];
}
