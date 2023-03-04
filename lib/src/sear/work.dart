import 'dart:convert';

import 'shims.dart';
import 'package:webcrypto/webcrypto.dart' as crypto;

import 'settings.dart' show pbkdf2;

import '../types/sear/types.dart';

final DefaultWorkFn DEFAULT_OPTS =
    DefaultWorkFn.from(encode: 'base64', name: 'PBKDF2', hash: pbkdf2['hash']);

Future<String> work(String data, PairReturnType pair, [DefaultWorkFn? opt]) async {
  opt ??= DEFAULT_OPTS;

  final salt = pair.epub;

  final key =
      await crypto.Pbkdf2SecretKey.importRawKey(Shims.textEncoder(data));

  final res = await key.deriveBits(
      opt.length ?? pbkdf2['ks'] * 8,
      opt.hash ?? DEFAULT_OPTS.hash!,
      Shims.textEncoder(salt),
      opt.iterations ?? pbkdf2['iter']);

  return base64Encode(res.toList());
}
