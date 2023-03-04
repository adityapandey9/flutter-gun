import 'dart:convert';
import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart' as crypto;

import '../types/sear/types.dart';

const shuffleAttackCutoff = 1672511400000; // Jan 1, 2023

const Map<String, dynamic> pbkdf2 = {
  'hash': crypto.Hash.sha256,
  'iter': 100000,
  'ks': 64
};

const ecdsa = {
  'pair': {'name': 'ECDSA', 'namedCurve': 'P-256'},
  'sign': {
    'name': 'ECDSA',
    'hash': {'name': 'SHA-256'}
  }
};

const ecdh = {'name': 'ECDH', 'namedCurve': 'P-256'};

JWK jwk(String pub, [String? d]) {
  final coords = pub.split('.');
  final data = JWK.from(
    crv: 'P-256',
    kty: 'EC',
    x: coords[0],
    y: coords[1],
    d: d ?? "",
    ext: true,
    key_opts: d != null ? ['sign'] : ['verify'],
  );
  return data;
}

KeyToJwk keyToJwk(ByteBuffer keyBytes) {
  final keyB64 = base64Encode(keyBytes.asUint8List());
  final k =
      keyB64.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  return KeyToJwk.from(kty: 'oct', k: k, ext: false, alg: 'A256GCM');
}

bool check(dynamic t) {
  return t is String && 'SEA{' == t.substring(0, 4);
}

dynamic parse(dynamic t) {
  try {
    final yes = t is String;
    if (yes && 'SEA{' == t.substring(0, 4)) {
      t = t.substring(3);
    }
    return yes ? jsonDecode(t) : t;
  } catch (_e) {}
  return t;
}
