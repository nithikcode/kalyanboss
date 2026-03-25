part of 'base_bloc.dart';
abstract class BaseEvent {}
class TabChangedEvent extends BaseEvent {
  final int index;
  TabChangedEvent(this.index);
}