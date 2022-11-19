/// WARNING! In the future, on machines that are D times faster than 2016AD machines, you will want to increase D by another several orders of magnitude so the processing speed never out paces the decimal resolution (increasing an integer effects the state accuracy).
var NI = double.negativeInfinity.toInt(), N = 0, D = 999, last = NI, u;

class State {
  static var drift = 0;

  create() {
    var t = DateTime.now().millisecondsSinceEpoch;
    if (last < t) {
      return [N = 0, last = t + State.drift];
    }
    return last = t + (N += 1) ~/ D + State.drift;
  }

  /// convenience function to get the state on a key on a node and return it.
  is_([n, k, o]) {
    var tmp = (k && n && n['_']) ? n['_']['>'] : o;
    if (tmp == null) {
      return tmp;
    }
    return ((tmp = tmp[k]) is num) ? tmp : NI;
  }

  /// put a key's state on a node.
  ify([n, k, s, v, soul]) {
    (n = n ?? {})['_'] = n['_'] ?? {}; // safety check or init.
    if(soul != null){ n['_']['#'] = soul; } // set a soul if specified.
    var tmp = n['_']['>'] ?? (n['_']['>'] = {}); // grab the states data.
    if(u != k && k != '_'){
      if(s is num){ tmp[k] = s; } // add the valid state.
      if(u != v){ n[k] = v; } // Note: Not its job to check for valid values!
    }
    return n;
  }
}
