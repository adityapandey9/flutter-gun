import 'dart:async';

class MiddlewareSystem<T, U, V> {
  final String name;
  late final List<FutureOr<T?> Function(T a, [U? b, V? c])> _middlewareFunctions;

  MiddlewareSystem({this.name = 'MiddlewareSystem'})
      : _middlewareFunctions = [];

  /// Register middleware function
  ///
  /// @param middleware The middleware function to add
  MiddlewareSystem<T, U, V> use(
      FutureOr<T?> Function(T a, [U? b, V? c]) middleware) {
    if (_middlewareFunctions.contains(middleware)) {
      return this;
    }

    _middlewareFunctions.add(middleware);
    return this;
  }

  /// Unregister middleware function
  ///
  /// @param middleware The middleware function to remove
  MiddlewareSystem<T, U, V> unuse(T? Function(T a, [U? b, V? c]) middleware) {
    final idx = _middlewareFunctions.indexOf(middleware);
    if (idx != -1) {
      _middlewareFunctions.removeAt(idx);
    }

    return this;
  }

  /// Process values through this middleware
  /// @param a Required, this is the value modified/passed through each middleware fn
  /// @param b Optional extra argument passed to each middleware function
  /// @param c Optional extra argument passed to each middleware function
  Future<T?> process(T a, [U? b, V? c]) async {
    T? val = a;

    for (final fn in _middlewareFunctions) {
      if (val == null) {
        return null;
      }

      val = await fn(val, b, c);
    }

    return val;
  }
}
