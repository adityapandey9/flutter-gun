import 'dart:async';

import 'package:mutex/mutex.dart';

typedef EventCb<T, U, V> = FutureOr<void> Function(T a, [U? b, V? c]);

/// Generic event/listener system
class GunEvent<T, U, V> {
  late final String name;
  final List<EventCb<T, U, V>> _listeners;
  final mut = Mutex();

  GunEvent({required this.name}) : _listeners = [];

  /// @returns number of currently subscribed listeners
  num listenerCount() {
    return _listeners.length;
  }

  void _mutexAcquire(Function fn) {
    mut.acquire().then((_) => fn()).then((value) => mut.release());
  }

  /// Register a listener on this event
  ///
  /// @param cb the callback to subscribe
  GunEvent<T, U, V> on(EventCb<T, U, V> cb) {
    _mutexAcquire(() {
      if (_listeners.contains(cb)) {
        return;
      }
      _listeners.add(cb);
    });
    return this;
  }

  /// Unregister a listener on this event
  /// @param cb the callback to unsubscribe
  GunEvent<T, U, V> off(EventCb<T, U, V> cb) {
    _mutexAcquire(() {
      final idx = _listeners.indexOf(cb);
      if (idx != -1) {
        _listeners.removeAt(idx);
      }
    });
    return this;
  }

  /// Unregister all listeners on this event
  GunEvent<T, U, V> reset() {
    _mutexAcquire(() {
      _listeners.clear();
    });
    return this;
  }

  /// Trigger this event
  GunEvent<T, U, V> trigger(T a, [U? b, V? c]) {
    _mutexAcquire(() {
      Future.forEach(_listeners, (EventCb<T, U, V> cb) => cb(a, b, c));
    });
    return this;
  }
}
