import 'dart:convert' show utf8;
import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart' as crypto;
import 'safe_buffer.dart';

class Shims {

  static Uint8List random(int len) {
    final bytes = SafeBuffer.alloc(len);
    crypto.fillRandomBytes(bytes);
    return bytes;
  }

  static String textDecoder(List<int> encoded) {
    return utf8.decode(encoded);
  }

  static List<int> textEncoder(String encoded) {
    return utf8.encode(encoded);
  }

}