import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart' as crypto;

import 'settings.dart' show keyToJwk;
import 'sha256.dart';

import 'shims.dart';
import '../types/sear/types.dart';

final DefaultAESKey DEFAULT_OPTS = DefaultAESKey.from(name: 'AES-GCM');

Future<crypto.AesGcmSecretKey> importAesKey(String key, [ByteBuffer? salt, DefaultAESKey? _opt]) async {
  _opt ??= DEFAULT_OPTS;

  final combo = key + (salt?.asUint8List() ?? Shims.random(8)).toString();
  final hash = await sha256(combo);
  final jwkKey = keyToJwk(hash);
  return crypto.AesGcmSecretKey.importJsonWebKey(jwkKey.toJson());
}