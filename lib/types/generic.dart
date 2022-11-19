import 'dart:collection';

/// Custom tuple
class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple({
    required this.item1,
    required this.item2,
  });

  factory Tuple.fromJson(Map<String, dynamic> json) {
    return Tuple(
      item1: json['item1'],
      item2: json['item2'],
    );
  }
}

/// Custom Map Base Key, Value
class GenericCustomValueMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _map = HashMap.identity();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  Map<K, V> toMap() => _map;

  @override
  V? remove(Object? key) => _map.remove(key);

  void merge(dynamic mapData) => _map.addAll(Map.from(mapData));
}
