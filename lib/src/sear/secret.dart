import 'package:webcrypto/webcrypto.dart' as crypto;

import '../types/sear/types.dart';
import 'settings.dart' show jwk;

final DefaultWorkFn DEFAULT_OPTS = DefaultWorkFn.from(encode: 'base64');

Future<dynamic> secret(String key, PairReturnType pair, [DefaultWorkFn? opt]) async {
  opt ??= DEFAULT_OPTS;

  final pub = key;
  final epub = pair.epub;
  final epriv = pair.epriv;

  final pubKeyData = jwk(pub);

  final props = await crypto.EcdhPublicKey.importJsonWebKey(pubKeyData.toJson(), crypto.EllipticCurve.p256);

  final privKeyData = jwk(epub, epriv);

  final privKey = await crypto.EcdhPrivateKey.importJsonWebKey(privKeyData.toJson(), crypto.EllipticCurve.p256);

  final derivedBits = await privKey.deriveBits(256, props);
  final derivedKey = await crypto.AesGcmSecretKey.importRawKey(derivedBits);
  final derived = await derivedKey.exportJsonWebKey();

  return derived['k'];
}