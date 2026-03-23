import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_state.freezed.dart';

/// Generic state for any API call
@freezed
class ApiState<T> with _$ApiState<T> {
  /// Initial state — before any call is made
  const factory ApiState.initial() = _Initial<T>;

  /// Loading state — request in progress
  const factory ApiState.loading() = _Loading<T>;

  /// Data received successfully
  const factory ApiState.success(T data) = _Success<T>;

  /// API returned an error or failed
  const factory ApiState.error(String message, [int? code]) = _Error<T>;

  /// Useful when you want to trigger UI refresh (like pull-to-refresh)
  const factory ApiState.refreshing(T? oldData) = _Refreshing<T>;
}
