
import 'dart:convert';
import 'dart:typed_data';

import 'settings.dart' show jwk, parse;
import 'sha256.dart' show sha256;

import 'package:webcrypto/webcrypto.dart' as crypto;

import '../types/sear/types.dart';


final DefaultOptVerifyType DEFAULT_OPTS = DefaultOptVerifyType.from(encode: 'base64');


Future<crypto.EcdsaPublicKey> importKey(String pub, [PairReturnType? d]) {
  final token = jwk(pub, d?.priv);
  return crypto.EcdsaPublicKey.importJsonWebKey(token.toJson(), crypto.EllipticCurve.p256);
}

Future<bool> verifyHashSignature(Uint8List hash, String signature, String pub, [PairReturnType? d, DefaultOptVerifyType? opt]) async {
  opt ??= DEFAULT_OPTS;

  final key = await importKey(pub);

  final sig = base64Decode(signature);

  if (await key.verifyBytes(sig, hash, crypto.Hash.sha256)) {
    return true;
  }

  return false;
}


Future<bool> verifySignature(dynamic data, String signature, String pub, [PairReturnType? d, DefaultOptVerifyType? opt]) async {
  opt ??= DEFAULT_OPTS;

  final hash = await sha256(data);

  return verifyHashSignature(hash.asUint8List(), signature, pub, d, opt);
}

Future<dynamic> verify(dynamic data, dynamic pair, [DefaultOptVerifyType? opt]) async {

  if (data == null) {
    throw ("data `null` not allowed.");
  }

  opt ??= DEFAULT_OPTS;

  final json = parse(data);

  final pub = pair is PairReturnType ? pair.pub : pair;

  if (await verifySignature(json['m'] ?? json[':'], json['s'] ?? json['~'], pub, pair, opt)) {
    return json['m'] ?? json[':'];
  }

  if (opt.fallback != null && opt.fallback!) {
    return oldVerify(data, pub, opt);
  }

  return null;
}

Future<bool> oldVerify(dynamic _data, String _pub, [DefaultOptVerifyType? _opt]) async {
  throw ('Legacy fallback validation not yet supported');
}
