import '../../types/gun.dart';

class GunQueue<T extends GunMsg> {
  final String name;
  late final List<T> _queue;

  GunQueue({this.name = 'GunQueue'}) : _queue = [];

  num count() {
    return _queue.length;
  }

  bool has(T item) {
    return _queue.contains(item);
  }

  GunQueue<T> enqueue(T item) {
    if (has(item)) {
      return this;
    }

    _queue.insert(0, item);
    return this;
  }

  T? dequeue() {
    return _queue.removeLast();
  }

  GunQueue<T> enqueueMany(final List<T> items) {
    final filtered = items.where((item) => !has(item)).toList();
    final List<T> filteredListReverse = [];

    for (var i = filtered.length - 1; i >= 0; i--) {
      filteredListReverse.add(filtered[i]);
    }
    if (filtered.isNotEmpty) {
      _queue.insertAll(0, filteredListReverse);
    }

    return this;
  }
}
