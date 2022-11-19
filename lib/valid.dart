typedef validFnType = bool Function(dynamic v);
bool validFn(v) {
  return v == null ||
      v is String ||
      v is bool ||
      (v is num &&
          v != double.infinity &&
          v != double.negativeInfinity &&
          v == v) ||
      (!!v &&
          v is Map &&
          v['#'] is String &&
          (v).length == 1 &&
          v['#'] != null);
}
