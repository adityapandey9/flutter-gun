import 'dart:typed_data';

import 'sea_array.dart';

import '../types/generic.dart';
import 'base64.dart';

class SafeBuffer extends GenericCustomList<int> {
  static SafeBuffer from(dynamic input, [String? enc]) {
    enc ??= 'utf-8';
    SafeBuffer buf = SafeBuffer();

    if (input is String) {
      if (enc == 'hex') {
        final bytes = RegExp(r"([\da-fA-F]{2})")
            .allMatches(input)
            .map((match) => int.parse(match.group(0)!, radix: 16))
            .toList();
        if (bytes.isEmpty) {
          throw ("Invalid first argument for type 'hex'.");
        }
        buf = SeaArray.from(bytes);
      } else if (enc == 'utf8') {
        final length = input.length;
        final words = Uint16List(length);
        for (var i = 0; i < length; i++) {
          words[i] = input.codeUnitAt(i);
        }
        buf = SeaArray.from(words);
      } else if (enc == 'base64') {
        final dec = SearBase64.atob(input);
        // final length = dec.length;
        // final bytes = Uint8List(length);
        // for (var i = 0; i < length; i++) {
        //   bytes[i] = dec[i];
        // }
        buf = SeaArray.from(dec);
      } else if (enc == 'binary') {
        buf = SeaArray.from(input);
      } else {
        throw ('SafeBuffer.from unknown encoding: $enc');
      }
      return buf;
    }
    final length = input.byteLength ? input.byteLength : input.length;
    if (length > 0) {
      var buff;
      if (input is ByteBuffer) {
        buff = input.asUint8List();
      }
      return SeaArray.from(buff ?? input);
    }
    return buf;
  }

  // This is 'safe-buffer.alloc' sans encoding support
  static Uint8List alloc(int length, [fill = 0]) {
    return Uint8List.fromList(List.filled(length, fill));
  }

  // This is normal UNSAFE 'buffer.alloc' or 'new Buffer(length)' - don't use!
  static allocUnsafe(int length) {
    return SeaArray.from(Uint8List.fromList(List.filled(length, 0)));
  }

  // This puts together array of array like members
  static concat(List arr) {
    // octet array
    // if (!(arr is List)) {
    //   throw ('First argument must be Array containing ArrayBuffer or Uint8Array instances.');
    // }
    return SeaArray.from(
        arr.reduce((ret, item) => ret.concat(List.from(item))));
  }
}
