import 'dart:convert';
import 'dart:typed_data';
import 'package:webcrypto/webcrypto.dart' as crypto;

import 'settings.dart' show jwk, parse;
import 'sha256.dart' show sha256;
import 'soul.dart' show pubFromSoul;
import 'verify.dart' show verify;
import '../types/gun.dart';

import '../types/sear/types.dart';

final DefaultOptSignType DEFAULT_OPTS =
    DefaultOptSignType.from(encode: 'base64');

PrepReturnType prep(dynamic val, String key, GunNode node, String soul) {
  return PrepReturnType.from(
    key: soul,
    dot: key,
    col: parse(val),
    forward: node.nodeMetaData != null
        ? node.nodeMetaData!.forward != null
            ? node.nodeMetaData!.forward![key] ?? 0
            : 0
        : 0,
  );
}

Future<Uint8List> hashForSignature(dynamic prepped) async {
  final hash = await sha256(prepped);

  return hash.asUint8List();
}

Future<Uint8List> hashNodeKey(GunNode node, String key) {
  final val = node[key];

  final parsed = parse(val);
  final soul = node.nodeMetaData != null ? node.nodeMetaData!.key! : "";
  final prepped = prep(parsed, key, node, soul);

  return hashForSignature(prepped.toJson());
}

Future<String> signHash(Uint8List hash, PairReturnType pair, [String? encoding]) async {
  encoding ??= DEFAULT_OPTS.encode;

  final token = jwk(pair.pub, pair.priv);

  final signKey = await crypto.EcdsaPrivateKey.importJsonWebKey(token.toJson(), crypto.EllipticCurve.p256);

  final sig = await signKey.signBytes(hash, crypto.Hash.sha256);
  return base64Encode(sig);
}

Future<dynamic> sign(dynamic data, PairReturnType pair, [DefaultOptSignType? opt]) async {
  opt ??= DEFAULT_OPTS;

  final json = parse(data);

  final encoding = opt.encode ?? DEFAULT_OPTS.encode;

  final checkData = opt.check ?? json;

  if (json != null &&
      (json.runtimeType == {}.runtimeType &&
          ((json.containsKey('s') && json.containsKey('m')) ||
              (json.containsKey(':') && json.containsKey('~')))) &&
      (await verify(data, pair) != null)
  ) {
    final parsed = parse(checkData);
    if (opt.raw != null && opt.raw!) {
      return parsed;
    }

    return 'SEA${jsonEncode(parsed)}';
  }

  final hash = await hashForSignature(json);

  final sig = await signHash(hash, pair, encoding);

  final r = {
    'm': json,
    's': sig
  };
  if (opt.raw != null && opt.raw!) {
    return r;
  }

  return 'SEA${jsonEncode(r)}';
}

Future<SignNodeValueReturnType> signNodeValue(GunNode node, String key, PairReturnType pair, [String? _encoding]) async {
  _encoding ??= DEFAULT_OPTS.encode;

  final data = node[key];
  final json = parse(data);

  if (data != null && json != null && json is Map<String, dynamic> && ((json.containsKey('s') && json.containsKey('m')) || (json.containsKey(':') && json.containsKey('~')))) {
    // already signed
    return SignNodeValueReturnType.fromJson(json);
  }

  final hash = await hashNodeKey(node, key);
  // final hash = await hashForSignature(json);
  final sig = await signHash(hash, pair);

  return SignNodeValueReturnType.fromJson({
    ':': json,
    '~': sig
  });
}

Future<GunNode> signNode(GunNode node, PairReturnType pair, [String? encoding]) async {
  encoding ??= DEFAULT_OPTS.encode;

  final GunNode signedNode = GunNode.fromJson({
    '_': node.nodeMetaData?.toJson()
  });

  final soul = node.nodeMetaData?.key;

  for (final key in node.keys) {
    if (key == 'pub' /*|| key === "alias"*/ && soul == "~${pair.pub}") {
      signedNode[key] = node[key];
      continue;
    }

    signedNode[key] = jsonEncode(await signNodeValue(node, key, pair, encoding));
  }

  return signedNode;
}


Future<GunGraphData> signGraph(GunGraphData graph, PairReturnType pair, [String? encoding]) async {

  encoding ??= DEFAULT_OPTS.encode;

  final modifiedGraph = graph;
  for (final soul in graph.keys) {
    final soulPub = pubFromSoul(soul);

    if (soulPub != pair.pub) {
      continue;
    }

    final node = graph[soul];

    if (node == null) {
      continue;
    }

    modifiedGraph[soul] = await signNode(node, pair, encoding);
  }
  return modifiedGraph;
}


GraphSinger graphSigner(PairReturnType pair, [String? encoding]) {
  encoding ??= DEFAULT_OPTS.encode;

  return (GunGraphData graph, GunGraphData _) {
    return signGraph(graph, pair, encoding);
  };
}
