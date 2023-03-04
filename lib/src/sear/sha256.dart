import 'dart:convert';
import 'dart:typed_data';
import 'shims.dart';
import 'package:webcrypto/webcrypto.dart' as crypto;

Future<ByteBuffer> sha256(dynamic input, [String name = 'SHA-256']) async {
  final inp = input is String ? input : jsonEncode(input);
  final encoded = Shims.textEncoder(inp);
  final hash = await crypto.Hash.sha256.digestBytes(encoded);
  return hash.buffer;
}