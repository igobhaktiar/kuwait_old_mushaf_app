part of 'theme_cubit.dart';

abstract class ThemeState extends Equatable {
  final Brightness brightness;
  final Color pageBgcolor;
  const ThemeState(
      {required this.brightness, this.pageBgcolor = const Color(0xffffffff)});

  @override
  List<Object> get props => [brightness, pageBgcolor];
}

class AppThemeState extends ThemeState {
  @override
  // ignore: overridden_fields
  final Brightness brightness;
  @override
  // ignore: overridden_fields
  final Color pageBgcolor;
  const AppThemeState(
      {required this.brightness, this.pageBgcolor = Colors.white})
      : super(brightness: brightness, pageBgcolor: pageBgcolor);
}
