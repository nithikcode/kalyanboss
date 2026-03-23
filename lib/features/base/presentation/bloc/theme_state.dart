// theme_state.dart
part of 'theme_bloc.dart';


class ThemeState {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);

  // Initial state (defaults to light or system)
  factory ThemeState.initial() => const ThemeState(ThemeMode.light);

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode ?? this.themeMode);
  }
}