import 'dart:collection';
import 'dart:typed_data';

import '../sear/base64.dart';

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

class GenericCustomList<T extends int> extends ListBase<T> {
  @override
  late int length;

  @override
  T operator [](int index) => this[index];

  String toCustomString([String? enc, int? start, int? end]) {
    enc ??= 'utf8';
    start ??= 0;
    final length = this.length;
    if (enc == 'hex') {
      final buf = Uint8List.fromList(this);
      final num = ((end != null ? end + 1 : null) ?? length) - start;
      var res = '';
      for (var i = 0; i < num; i++) {
        res += buf[i + start].toRadixString(16).padLeft(2, '0');
      }
      return res;
    }
    if (enc == 'utf8') {
      final num = (end ?? length) - start;
      var res = '';
      for (var i = 0; i < num; i++) {
        res += String.fromCharCode(this[i + start]);
      }
      return res;
    }
    if (enc == 'base64') {
      return SearBase64.btob(this);
    }
    return "";
  }

  @override
  void operator []=(int index, T value) => add(value);
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
