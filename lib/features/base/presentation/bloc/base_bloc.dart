import 'package:flutter_bloc/flutter_bloc.dart';
part 'base_events.dart';
part 'base_state.dart';
class BaseBloc extends Bloc<BaseEvent, BaseState> {
  BaseBloc() : super(BaseState()) {
    on<TabChangedEvent>((event, emit) => emit(state.copyWith(currentIndex: event.index)));
  }
}