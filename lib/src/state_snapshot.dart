import 'load_state.dart';

/// Immutable value object holding the current [LoadState] and optional payload.
class StateSnapshot<T> {
  final LoadState status;
  final T? data;
  final String? message;

  const StateSnapshot._({
    required this.status,
    this.data,
    this.message,
  });

  /// Creates an idle snapshot.
  const StateSnapshot.idle() : this._(status: LoadState.idle);

  /// Creates a loading snapshot.
  const StateSnapshot.loading() : this._(status: LoadState.loading);

  /// Creates an empty snapshot.
  const StateSnapshot.empty() : this._(status: LoadState.empty);

  /// Creates an error snapshot with an optional message.
  const StateSnapshot.error([String? message])
      : this._(
          status: LoadState.error,
          message: message,
        );

  /// Creates a success snapshot with resolved data.
  const StateSnapshot.success(T data)
      : this._(
          status: LoadState.success,
          data: data,
        );
}
