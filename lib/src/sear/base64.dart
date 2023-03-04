import 'dart:convert';
import 'dart:typed_data';

import '../types/generic.dart';

class SearBase64 extends GenericCustomValueMap<String, dynamic> {

  static String btob(List<int> any) {
    return base64Encode(any);
  }

  static Uint8List atob(String base64Data) {
    return base64Decode(base64Data);
  }

}


