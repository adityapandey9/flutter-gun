import 'dart:convert';

import 'import_aes_key.dart' show importAesKey;
import 'shims.dart';

import '../types/sear/types.dart';

final DefaultAESEncryptKey DEFAULT_OPTS = DefaultAESEncryptKey.from(encode: 'base64', name: 'AES-GCM');

Future<dynamic> encrypt(dynamic data, dynamic pair, [DefaultAESEncryptKey? opt]) async {

  if (data == null) {
    throw ("`null` not allowed.");
  }
  opt ??= DEFAULT_OPTS;

  final key = pair is PairReturnType ? pair.epriv : pair;

  final msg = data is String ? data : jsonEncode(data);

  final rand = { 's': Shims.random(9), 'iv': Shims.random(15) }; // consider making this 9 and 15 or 18 or 12 to reduce == padding.
  
  final aesKey = await importAesKey(key, rand['s']?.buffer, DefaultAESKey.from(name: opt.name));

  final ct = await aesKey.encryptBytes(Shims.textEncoder(msg), rand['iv']!);

  final r = {
    'ct': base64Encode(ct),
    'iv': base64Encode(rand['iv']!),
    's': base64Encode(rand['s']!),
  };

  if (opt.raw != null && opt.raw!) {
    return r;
  }

  return "SEA${jsonEncode(r)}";
}