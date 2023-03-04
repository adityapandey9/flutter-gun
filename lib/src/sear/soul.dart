String pubFromSoul([String? soul]) {
  if (soul == null) {
    return '';
  }
  final tokens = soul.split('~');
  final last = tokens[tokens.length - 1];
  if (last.isEmpty) {
    return '';
  }
  final coords = last.split('.');
  if (coords.length < 2) {
    return '';
  }
  return coords.sublist(0, 2).join('.');
}
