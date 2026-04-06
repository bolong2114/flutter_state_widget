import 'package:flutter/foundation.dart';

import 'load_state.dart';
import 'state_snapshot.dart';

/// Controller for driving [StateWidget] without manually managing ValueNotifier.
class StateWidgetController<T> extends ChangeNotifier {
  StateSnapshot<T> _value;
  bool _isDisposed = false;

  StateWidgetController(
    StateSnapshot<T> initialValue,
  ) : _value = initialValue;

  StateWidgetController.idle() : this(const StateSnapshot.idle());

  StateWidgetController.loading() : this(const StateSnapshot.loading());

  StateWidgetController.empty() : this(const StateSnapshot.empty());

  StateWidgetController.error([String? message])
      : this(StateSnapshot.error(message));

  StateWidgetController.success(T data) : this(StateSnapshot.success(data));

  StateSnapshot<T> get value => _value;

  LoadState get status => _value.status;

  T? get data => _value.data;

  String? get message => _value.message;

  bool get isDisposed => _isDisposed;

  void update(StateSnapshot<T> snapshot) {
    _setValue(snapshot);
  }

  void idle() {
    _setValue(const StateSnapshot.idle());
  }

  void loading() {
    _setValue(const StateSnapshot.loading());
  }

  void empty() {
    _setValue(const StateSnapshot.empty());
  }

  void error([String? message]) {
    _setValue(StateSnapshot.error(message));
  }

  void success(T data) {
    _setValue(StateSnapshot.success(data));
  }

  void _setValue(StateSnapshot<T> snapshot) {
    if (_isDisposed) {
      return;
    }
    _value = snapshot;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
