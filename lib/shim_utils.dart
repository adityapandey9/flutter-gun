import 'dart:async';
import 'dart:math';

extension ComparisonOperators on String {
  operator <=(String other) => codeUnits.first <= other.codeUnits.first;

  operator <(String other) => codeUnits.first < other.codeUnits.first;

  operator >=(String other) => codeUnits.first >= other.codeUnits.first;

  operator >(String other) => codeUnits.first > other.codeUnits.first;

  bool parseBool() {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    } else {
      return false;
    }
  }

  String random(
      [num len = 24,
      String sample_chars =
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXZabcdefghijklmnopqrstuvwxyz']) {
    String s = '';
    var rng = Random();
    while (len-- > 0) {
      s += sample_chars[(rng.nextDouble() * sample_chars.length).floor()];
    }
    return s;
  }

  bool match([t, o]) {
    var tmp, u;
    if (t is! String) {
      return false;
    }
    if (o is String) {
      o = {'=': o};
    }
    o = o ?? {};
    tmp = (o['='] ?? o['*'] ?? o['>'] ?? o['<']);
    if (t == tmp) {
      return true;
    }
    if (u != o['=']) {
      return false;
    }
    tmp = (o['*'] || o['>']);
    if (t.substring(0, (tmp ?? '').length) == tmp) {
      return true;
    }
    if (u != o['*']) {
      return false;
    }
    if (u != o['>'] && u != o['<']) {
      return (t >= o['>'] && t <= o['<']) ? true : false;
    }
    if (u != o['>'] && t >= o['>']) {
      return true;
    }
    if (u != o['<'] && t <= o['<']) {
      return true;
    }

    return false;
  }

  num? hash([s, c]) {
    if (s is! String) {
      return null;
    }
    var n;
    c = c ?? 0; // CPU schedule hashing by
    if (s.isEmpty) {
      return c;
    }
    for (var i = 0, l = s.length; i < l; ++i) {
      n = s.codeUnitAt(i);
      c = ((c << 5) - c) + n;
      c |= 0;
    }
    return c;
  }
}

class setTimeout {
  static var hold = 9; // half a frame benchmarks faster than < 1ms?

  setTimeout([function, intLimit]) {
    Future.delayed(Duration(milliseconds: intLimit), function);
  }

  static each(Iterable elements, FutureOr Function(dynamic) action) {
    Future.forEach(elements, action);
  }

  static poll(Function action) {
    var l = 0, c = 0;
    if ((setTimeout.hold >= (DateTime.now().millisecondsSinceEpoch - l)) &&
        c++ < 3333) {
      action();
      return null;
    }
    Timer(Duration.zero, () {
      l = DateTime.now().millisecondsSinceEpoch;
      action();
    });
  }

  static turn(Function action) {
    var s = [], p = setTimeout.poll, i = 0, f;
    T() {
      if (f = s[i++]) {
        if (f is Function) {
          f();
        }
      }
      if (i == s.length || 99 == i) {
        s = s.sublist(i);
        i = 0;
      }
      if (s.isNotEmpty) {
        p(T);
      }
    }

    t(f) {
      s.add(f);
      s.length == 1 && p(T);
    }

    t(action);
  }
}

// extension EachFuture on Future {
//   each() {
//
//   }
// }
