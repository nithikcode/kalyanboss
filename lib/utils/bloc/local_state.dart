/// A generic state wrapper for local data that does NOT come from an API.
///
/// Mirrors the shape and API of [ApiState] so the two feel identical to use.
/// Use this anywhere you manage in-memory / locally-computed state that still
/// needs loading, success, error, and refresh phases.
///
/// Example:
/// ```dart
/// LocalState<GameReadyState> gameState = LocalState.initial();
/// gameState = LocalState.loading();
/// gameState = LocalState.success(readyState);
/// gameState = LocalState.error('Something went wrong');
/// ```
sealed class LocalState<T> {
  const LocalState();

  // ── Factories ────────────────────────────────────────────────────────────────

  /// Before any work has started.
  const factory LocalState.initial() = _Initial<T>;

  /// Work is in progress (e.g. parsing, computing).
  const factory LocalState.loading() = _Loading<T>;

  /// Work completed — carries the result.
  const factory LocalState.success(T data) = _Success<T>;

  /// Work failed — carries a human-readable message and an optional code.
  const factory LocalState.error(String message, [int? code]) = _Error<T>;

  /// Re-computing with stale data still available (e.g. pull-to-refresh).
  const factory LocalState.refreshing(T? oldData) = _Refreshing<T>;

  // ── Pattern matching ─────────────────────────────────────────────────────────

  /// Exhaustive match — every branch must be provided.
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, int? code) error,
    required R Function(T? oldData) refreshing,
  }) {
    return switch (this) {
      _Initial<T>() => initial(),
      _Loading<T>() => loading(),
      _Success<T>(data: final d) => success(d),
      _Error<T>(message: final m, code: final c) => error(m, c),
      _Refreshing<T>(oldData: final o) => refreshing(o),
    };
  }

  /// Non-exhaustive match — supply only the branches you care about.
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message, int? code)? error,
    R Function(T? oldData)? refreshing,
    required R Function() orElse,
  }) {
    return switch (this) {
      _Initial<T>() => initial != null ? initial() : orElse(),
      _Loading<T>() => loading != null ? loading() : orElse(),
      _Success<T>(data: final d) => success != null ? success(d) : orElse(),
      _Error<T>(message: final m, code: final c) =>
      error != null ? error(m, c) : orElse(),
      _Refreshing<T>(oldData: final o) =>
      refreshing != null ? refreshing(o) : orElse(),
    };
  }

  /// Like [maybeWhen] but returns null instead of calling [orElse].
  R? whenOrNull<R>({
    R? Function()? initial,
    R? Function()? loading,
    R? Function(T data)? success,
    R? Function(String message, int? code)? error,
    R? Function(T? oldData)? refreshing,
  }) {
    return switch (this) {
      _Initial<T>() => initial?.call(),
      _Loading<T>() => loading?.call(),
      _Success<T>(data: final d) => success?.call(d),
      _Error<T>(message: final m, code: final c) => error?.call(m, c),
      _Refreshing<T>(oldData: final o) => refreshing?.call(o),
    };
  }

  // ── Convenience getters ──────────────────────────────────────────────────────

  bool get isInitial => this is _Initial<T>;
  bool get isLoading => this is _Loading<T>;
  bool get isSuccess => this is _Success<T>;
  bool get isError => this is _Error<T>;
  bool get isRefreshing => this is _Refreshing<T>;

  /// Returns the success data, or null in any other state.
  T? get dataOrNull => whenOrNull(success: (d) => d);

  /// Returns the error message, or null in any other state.
  String? get errorOrNull => whenOrNull(error: (m, _) => m);
}

// ── Private variants ─────────────────────────────────────────────────────────

final class _Initial<T> extends LocalState<T> {
  const _Initial();
}

final class _Loading<T> extends LocalState<T> {
  const _Loading();
}

final class _Success<T> extends LocalState<T> {
  final T data;
  const _Success(this.data);
}

final class _Error<T> extends LocalState<T> {
  final String message;
  final int? code;
  const _Error(this.message, [this.code]);
}

final class _Refreshing<T> extends LocalState<T> {
  final T? oldData;
  const _Refreshing(this.oldData);
}