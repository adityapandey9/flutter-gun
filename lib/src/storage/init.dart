import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';

class InitStorage {
  static const secureStorage = FlutterSecureStorage();
  static Box<dynamic>? hiveOpenBox;
  static const _internalKey = 'secure-encrypted-vaultBox-key';
  static const _internalHiveBoxKey = 'secure-vaultBox';

  Future<Uint8List> _getEncryptedKey([String? key]) async {
    // if key not exists return null
    final encryptionKeyString =
        await secureStorage.read(key: key ?? _internalKey);

    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: _internalKey,
        value: base64UrlEncode(key),
      );
    }

    final secureKey = await secureStorage.read(key: _internalKey);
    return base64Url.decode(secureKey!);
  }

  static Future<Box<dynamic>> getHiveBox({Uint8List? encryptionKeyUint8List, String? key}) async {
    return (hiveOpenBox = await Hive.openBox(_internalHiveBoxKey,
        encryptionCipher:
            HiveAesCipher(encryptionKeyUint8List ?? await InitStorage()._getEncryptedKey(key))));
  }
}

Future<void> initializeFlutterGun({Uint8List? encryptionKeyUint8List, String? key}) async {
  await Hive.initFlutter();
  await InitStorage.getHiveBox(encryptionKeyUint8List: encryptionKeyUint8List, key: key);
}
