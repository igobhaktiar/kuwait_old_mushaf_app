part of 'about_app_cubit.dart';

abstract class AboutAppState extends Equatable {
  const AboutAppState();

  @override
  List<Object?> get props => [];
}

class AboutAppInitial extends AboutAppState {}

class AboutAppContentIsLoading extends AboutAppState {}

class AboutAppContentLoaded extends AboutAppState {
  final List<Content> content;
  const AboutAppContentLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}

class AboutAppError extends AboutAppState {
  final String? message;
  const AboutAppError({this.message});
  @override
  List<Object?> get props => [message];
}
