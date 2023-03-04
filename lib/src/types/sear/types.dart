import 'dart:async';
import 'dart:convert';

import 'package:webcrypto/webcrypto.dart' as crypto;

import '../gun.dart';

class JWK {
  String crv;
  String? d;
  bool? ext = false;
  List<String>? key_opts = [];
  String kty = "";
  String x = "";
  String y = "";

  JWK.from({
    required this.kty,
    required this.x,
    required this.y,
    required this.crv,
    this.d,
    this.ext,
    this.key_opts,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'kty': kty,
      'crv': crv,
      'x': x,
      'y': y,
    };

    if (d != null && d!.isNotEmpty) {
      data['d'] = d;
    }
    if (ext != null) {
      data['ext'] = ext;
    }
    if (key_opts != null && key_opts!.isNotEmpty) {
      data['key_opts'] = key_opts;
    }

    return data;
  }
}

class KeyToJwk {
  String k = "";
  String kty = "";
  bool ext = false;
  String alg = "";

  KeyToJwk.from(
      {required this.k,
      required this.kty,
      required this.ext,
      required this.alg});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'k': k, 'kty': kty, 'ext': ext, 'alg': alg};
}

class DefaultAESKey {
  String? name;

  DefaultAESKey.from({this.name});
}

class DefaultAESDecryptKey {
  String? name;
  String? encode;
  String? fallback;

  DefaultAESDecryptKey.from({this.name, this.encode, this.fallback});
}

class DefaultAESWorkKey {
  String? name;
  String? encode;
  Map<String, dynamic>? hash;

  DefaultAESWorkKey.from({this.name, this.encode, this.hash});
}

class DefaultWorkFn {
  String? name;
  String? encode;
  num? iterations;
  num? length;
  crypto.Hash? hash;

  DefaultWorkFn.from(
      {this.name, this.encode, this.hash, this.iterations, this.length});
}

class AuthenticateReturnDataType {
  String alias;
  String epriv;
  String epub;
  String priv;
  String pub;

  AuthenticateReturnDataType.from(
      {required this.alias,
      required this.epriv,
      required this.epub,
      required this.priv,
      required this.pub});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'alias': alias,
    'epub': epub,
    'pub': pub,
    'epriv': epriv,
    'priv': priv,
  };

  factory AuthenticateReturnDataType.fromJson(Map<String, dynamic> parsedJson) {
    return AuthenticateReturnDataType.from(
        alias: parsedJson['alias'],
        epub: parsedJson['epub'],
        pub: parsedJson['pub'],
        epriv: parsedJson['epriv'],
        priv: parsedJson['priv']
    );
  }
}

class DefaultAESEncryptKey {
  String? name;
  String? encode;
  bool? raw;

  DefaultAESEncryptKey.from({this.name, this.encode, this.raw});
}

class EncryptFnReturnType {
  String ct;
  String iv;
  String s;

  EncryptFnReturnType.from(
      {required this.ct, required this.iv, required this.s});
}

class PairReturnType {
  String epriv;
  String epub;
  String priv;
  String pub;

  PairReturnType.from(
      {required this.epriv,
      required this.epub,
      required this.priv,
      required this.pub});
}

class DefaultOptVerifyCheckType {
  dynamic m;
  String s;

  DefaultOptVerifyCheckType.from({required this.m, required this.s});
}

class DefaultOptVerifyType {
  bool? fallback;
  String? encode;
  bool? raw;
  DefaultOptVerifyCheckType? check;

  DefaultOptVerifyType.from({this.fallback, this.encode, this.raw, this.check});
}

class DefaultOptSignType {
  String? encode;
  bool? raw;
  DefaultOptVerifyCheckType? check;

  DefaultOptSignType.from({this.encode, this.raw, this.check});
}

class PrepReturnType {
  String key; // #
  String dot; // .
  dynamic col; // :
  num forward; // >

  PrepReturnType.from(
      {required this.key,
      required this.dot,
      required this.col,
      required this.forward});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'#': key, '.': dot, ':': col, '>': forward};
}

class KeyPair {
  String pub;
  String priv;

  KeyPair.from({required this.pub, required this.priv});
}

class SignNodeValueReturnType {
  GunValue col; // :
  String tilde; // ~

  SignNodeValueReturnType.from({required this.col, required this.tilde});

  Map<String, dynamic> toJson() => <String, dynamic>{
        ':': col,
        '~': tilde,
      };

  factory SignNodeValueReturnType.fromJson(Map<String, dynamic> parsedJson) {
    return SignNodeValueReturnType.from(
        col: parsedJson[':'] ?? parsedJson['m'], tilde: parsedJson['~'] ?? parsedJson['s']);
  }
}

typedef GraphSinger = FutureOr<GunGraphData> Function(GunGraphData graph, GunGraphData _graph);

class CreateUserReturnType {
  String alias;
  String auth;
  String epub;
  String pub;
  String epriv;
  String priv;

  CreateUserReturnType.from(
      {required this.alias,
      required this.auth,
      required this.epub,
      required this.pub,
      required this.epriv,
      required this.priv});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'alias': alias,
    'auth': auth,
    'epub': epub,
    'pub': pub,
    'epriv': epriv,
    'priv': priv,
  };

  factory CreateUserReturnType.fromJson(Map<String, dynamic> parsedJson) {
    return CreateUserReturnType.from(
        alias: parsedJson['alias'],
        auth: parsedJson['auth'],
        epub: parsedJson['epub'],
        pub: parsedJson['pub'],
        epriv: parsedJson['epriv'],
        priv: parsedJson['priv']
    );
  }
}

class DefaultCertifyOPTType {
  num? expiry;
  bool? raw;

  dynamic block;

  DefaultCertifyOPTType.from({this.expiry, this.raw, this.block});
}

class CertifyPolicyType {
  dynamic read;
  dynamic write;

  CertifyPolicyType.from({this.read, this.write});
}