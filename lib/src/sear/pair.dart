import 'package:webcrypto/webcrypto.dart' as crypto;

import '../types/sear/types.dart';

Future<PairReturnType> pair([opt]) async {
  final signKeys = await crypto.EcdsaPrivateKey.generateKey(crypto.EllipticCurve.p256);

  final signPub = await signKeys.publicKey.exportJsonWebKey();
  final signPri = await signKeys.privateKey.exportJsonWebKey();

  final sa = {
    'priv': signPri['d'],
    'pub': "${signPub["x"]}.${signPub["y"]}",
  };

  final cryptKeys = await crypto.EcdhPrivateKey.generateKey(crypto.EllipticCurve.p256);

  final cryptPub = await cryptKeys.publicKey.exportJsonWebKey();
  final cryptPri = await cryptKeys.privateKey.exportJsonWebKey();

  final dh = {
    'epriv': cryptPri['d'],
    'epub': "${cryptPub["x"]}.${cryptPub["y"]}",
  };

  return PairReturnType.from(
      epriv: dh['epriv'] ?? '',
      epub: dh['epub'] ?? '',
      priv: sa['priv'] ?? '',
      pub: sa['pub']
  );
}