import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../flutter_gundb.dart';

import '../types/sear/types.dart';

const Map<String, dynamic> DEFAULT_OPTS = {};

Future<AuthenticateReturnDataType?> authenticateAccount(
    dynamic ident, String password,
    [String encoding = 'base64']) async {
  if (ident == null || (ident is Map && !ident.containsKey('auth'))) {
    return null;
  }

  var decrypted;

  try {
    final proof = await work(password, ident['auth']['s'], DefaultWorkFn.from(encode: encoding));
    decrypted = await decrypt(ident['auth']['ek'], PairReturnType.from(epriv: proof, epub: "", priv: "", pub: ""), DefaultAESDecryptKey.from(encode: encoding));
  } catch(e) {
    final proof = await work(password, ident['auth']['s'], DefaultWorkFn.from(encode: encoding));
    decrypted = await decrypt(ident['auth']['ek'], PairReturnType.from(epriv: proof, epub: "", priv: "", pub: ""), DefaultAESDecryptKey.from(encode: encoding));
  }

  if (decrypted == null) {
    return null;
  }

  return AuthenticateReturnDataType.from(
      alias: ident['alias'],
      epriv: decrypted['epriv'],
      epub: ident['epub'],
      priv: decrypted['priv'],
      pub: ident['pub']
  );
}

Future<AuthenticateReturnDataType?> authenticateIdentity(
    FlutterGunSeaClient fluttergun,
    String soul,
    String password,
    [String encoding = 'base64']
    ) async {
  final ident = await fluttergun.getValue(soul);
  print('\n\n\n:: authenticateIdentity:::: ${jsonEncode(ident)} \n');
  return authenticateAccount(ident, password, encoding);
}

Future<AuthenticateReturnDataType> authenticate(
    FlutterGunSeaClient fluttergun,
    String alias,
    String password,
    [Map<String, dynamic> _opt = DEFAULT_OPTS]
    ) async {
  final aliasSoul = "~@$alias";
  final idents = await fluttergun.getValue(aliasSoul);

  print('\n----\nIndent:: ${jsonEncode(idents)}');

  for (var soul in (idents is Map ? idents : {}).keys) {
    if (soul == '_') {
      continue;
    }

    var pair;

    // soul = "$aliasSoul/$soul";

    print("Soul:: $soul");

    try {
      pair = await authenticateIdentity(fluttergun, soul, password);
    } catch (e) {
      if (kDebugMode) {
        print("Error During authenticate: ${e.toString()}");
      }
    }

    if (pair != null) {
      return pair;
    }
  }

  throw ('Wrong alias or password.');
}