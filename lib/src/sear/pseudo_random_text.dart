import 'dart:math' as math;

String pseudoRandomText([
  l = 24,
  c = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXZabcdefghijklmnopqrstuvwxyz'
]) {
  var s = '';

  while (l > 0) {
    s += c[math.Random().nextInt(c.length - 1)];
    l--;
  }

  return s;
}