import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'shims.dart';

import '../types/gun.dart';
import '../types/sear/types.dart';
import 'settings.dart' show parse;

import 'import_aes_key.dart';

final DefaultAESDecryptKey DEFAULT_OPTS =
    DefaultAESDecryptKey.from(encode: 'base64', name: 'AES-GCM');

Future<GunValue> decrypt(dynamic data, dynamic pair,
    [DefaultAESDecryptKey? opt]) async {
  opt ??= DEFAULT_OPTS;
  final json = parse(data);
  final encoding = opt.encode ?? DEFAULT_OPTS.encode;

  final key = pair is PairReturnType ?  pair.epriv : pair;

  try {
    final aeskey = await importAesKey(key, base64Decode(json['s']).buffer,
        DefaultAESKey.from(name: opt.name));

    final encrypted = base64Decode(json['ct']);

    final iv = base64Decode(json['iv']);
    final ct = await aeskey.decryptBytes(encrypted, iv, tagLength: 128);
    return parse(Shims.textDecoder(ct));
  } catch (e) {
    if (kDebugMode) {
      print('decrypt error: ${e.toString()}');
    }
    if (opt.fallback == null || encoding == opt.fallback) {
      throw ('Could not decrypt');
    }
    return decrypt(
        data,
        pair,
        DefaultAESDecryptKey.from(
            encode: opt.fallback, name: opt.name, fallback: opt.fallback));
  }
}
