import 'dart:convert';

import '../types/sear/types.dart';
import 'sign.dart' show sign;

final DefaultCertifyOPTType DEFAULT_OPTS = DefaultCertifyOPTType.from();

Future certify(dynamic certificants, dynamic policy, PairReturnType authority,
    [DefaultCertifyOPTType? opt]) async {
  opt ??= DEFAULT_OPTS;

  certificants = getCertificants(certificants);

  if (certificants == null) {
    throw ("No certificant found.");
  }

  final expiry = opt.expiry;

  final readPolicy = policy is CertifyPolicyType ? policy.read : null;

  final writePolicy = policy is CertifyPolicyType
      ? policy.write
      : (policy is String ||
              policy is List) || (policy.runtimeType == {}.runtimeType &&
      (policy.containsKey("+") ||
          policy.containsKey("#") ||
          policy.containsKey(".") ||
          policy.containsKey("=") ||
          policy.containsKey("*") ||
          policy.containsKey(">") ||
          policy.containsKey("<")))
          ? policy
          : null;

  final block = opt.block;
  final readBlock = (block == {}.runtimeType && block!.containsKey('read')) &&
          (block!['read'] is String ||
              (block!['read'].runtimeType == {}.runtimeType &&
                  block!['read'].containsKey('#')))
      ? block!['read']
      : null;

  final writeBlock = block is String
      ? block
      : (block.runtimeType == {}.runtimeType && block!.containsKey('write')) &&
              (block!['write'] is String ||
                  (block!['write'].runtimeType == {}.runtimeType &&
                      block!['write'].containsKey('#')))
          ? block!['write']
          : null;

  if (readPolicy == null && writePolicy == null) {
    throw ("No policy found.");
  }

  final data = jsonEncode({
    'c': certificants,
    ...(expiry != null ? {'e': expiry} : {}),
    // inject expiry if possible
    ...(readPolicy != null ? {'r': readPolicy} : {}),
    // "r" stands for read, which means read permission.
    ...(writePolicy != null ? {'w': writePolicy} : {}),
    // "w" stands for write, which means write permission.
    ...(readBlock != null ? {'rb': readBlock} : {}),
    // inject READ block if possible
    ...(writeBlock != null ? {'wb': writeBlock} : {}),
    // inject WRITE block if possible
  });

  final certificate =
      await sign(data, authority, DefaultOptSignType.from(raw: true));

  if (opt.raw != null && opt.raw!) {
    return certificate;
  }

  return "SEA${jsonEncode(certificate)}";
}

dynamic getCertificants(dynamic certificants) {
  var data = [];

  if (certificants != null) {
    if ((certificants is String ||
            certificants.runtimeType == <String>[].runtimeType) &&
        certificants.indexOf("*") > -1) {
      return "*";
    }

    if (certificants is String) {
      return certificants;
    }

    if (certificants is List) {
      if (certificants.length == 1 && certificants[0] != null) {
        if (certificants[0] is PairReturnType) {
          return certificants[0].pub;
        } else if (certificants[0] is String) {
          return certificants[0];
        } else {
          return null;
        }
      }

      certificants.map((certificant) {
        if (certificant is String) {
          data.add(certificant);
        } else if (certificant is PairReturnType) {
          data.add(certificant.pub);
        }

        return certificant;
      });
    }

    if (certificants is PairReturnType) {
      return certificants.pub;
    }
  }

  return data.isNotEmpty ? data : null;
}
