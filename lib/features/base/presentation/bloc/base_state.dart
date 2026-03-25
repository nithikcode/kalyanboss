part of 'base_bloc.dart';
class BaseState {
  final int currentIndex;
  BaseState({this.currentIndex = 0});

  BaseState copyWith({int? currentIndex}) {
    return BaseState(currentIndex: currentIndex ?? this.currentIndex);
  }
}