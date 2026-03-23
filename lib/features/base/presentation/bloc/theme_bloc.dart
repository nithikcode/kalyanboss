// theme_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'theme_event.dart';
part 'theme_state.dart';


class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  // Assuming you have a helper to save preferences
  // final ThemeLocalDataSource localDataSource;

  ThemeBloc() : super(ThemeState.initial()) {
    on<LoadTheme>((event, emit) async {
      // Logic to fetch saved theme from SharedPreferences would go here
      // final savedTheme = await localDataSource.getCachedTheme();
      // emit(ThemeState(savedTheme));
    });

    on<ThemeChanged>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });
  }
}