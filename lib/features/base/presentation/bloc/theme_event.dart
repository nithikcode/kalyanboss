// theme_event.dart
part of "theme_bloc.dart";
abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  ThemeChanged(this.themeMode);
}

class LoadTheme extends ThemeEvent {} // To load from SharedPreferences on start