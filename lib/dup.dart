import 'package:flutter/foundation.dart';

typedef DupFnType = dynamic Function([dynamic]);

DupFn([opt]) {
  Map<String, dynamic> dup = {'s': {} as Map<String, dynamic>}, s = dup['s'];
  opt = opt ?? {'max': 999, 'age': 1000 * 9}; //*/ 1000 * 9 * 3};
  drop([age]) {
    dup['to'] = null;
    dup['now'] = DateTime.now().millisecondsSinceEpoch;
    var l = s.keys.toList();
    if (kDebugMode) {
      print(
          'dup drop keys ${dup['now']} ${DateTime.now().millisecondsSinceEpoch - dup['now']}');
    }
    // TODO: check if it will work or not Gun logic not clear
    Future.forEach(l, (id) {
      var it = s[id]; // TODO: .keys( is slow?
      if (it != null && (age ?? opt['age']) > (dup['now'] - it['was'])) {
        return null;
      }
      s.remove(id);
    });
  }

  dup['drop'] = drop;
  dt([id]) {
    Map<String, dynamic> it = s[id] ?? (s[id] = {} as Map<String, dynamic>);
    it['was'] = dup['now'] = DateTime.now().millisecondsSinceEpoch;
    if (dup['to'] == null) {
      dup['to'] =
          Future.delayed(Duration(milliseconds: opt['age'] + 9), dup['drop']);
    }
    return it;
  }

  dup['track'] = dt;
  check([id]) {
    if (s[id] == null) {
      return false;
    }
    return dt(id);
  }

  dup['check'] = check;

  return dup;
}
