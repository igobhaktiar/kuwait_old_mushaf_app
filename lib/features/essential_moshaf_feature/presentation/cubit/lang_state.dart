part of 'lang_cubit.dart';

abstract class LangState extends Equatable {
  final Locale locale;

  const LangState(this.locale);

  @override
  List<Object> get props => [locale];
}

class LangChanged extends LangState {
  const LangChanged(Locale selectedLocale) : super(selectedLocale);
}
