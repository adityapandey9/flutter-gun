import 'dart:convert';

import '../../flutter_gundb.dart';
import 'pair.dart' as create_pair;

import '../types/gun.dart';
import '../types/sear/types.dart';

Future<CreateUserReturnType> createUser(
    ChainGunSeaClient chaingun, String alias, String password) async {
  final aliasSoul = "~@$alias";

  // "pseudo-randomly create a salt, then use PBKDF2 function to extend the password with it."
  final salt = pseudoRandomText(64);

  final proof = await work(password, PairReturnType.from(epriv: "", epub: salt, priv: "", pub: ""));
  final pair = await create_pair.pair();
  final pubSoul = "~${pair.pub}";

  final ek = await encrypt(
      jsonEncode({'priv': pair.priv, 'epriv': pair.epriv}),
      PairReturnType.from(epriv: proof, epub: "", priv: "", pub: ""),
      DefaultAESEncryptKey.from(raw: true));

  final auth = jsonEncode({'ek': ek, 's': salt});
  final data = {
    'alias': alias,
    'auth': auth,
    'epub': pair.epub,
    'pub': pair.pub
  };

  final now = DateTime.now().millisecondsSinceEpoch;

  final GunGraphData tempGraph = GunGraphData();
  final Map<String, num> tempForwardGraph = {};

  for (var innerKey in data.keys) {
    tempForwardGraph[innerKey] = now;
  }

  tempGraph[pubSoul] = GunNode.fromJson({
    '_': {'#': pubSoul, '>': tempForwardGraph},
    ...data
  });

  final graph = await signGraph(tempGraph, pair);

  await () async {
    final tempNodePut = chaingun.get(pubSoul);
    tempNodePut.put(graph[pubSoul]);
    final tempPut = chaingun.get(aliasSoul);
    tempPut.put({'#': pubSoul});
  }();

  return CreateUserReturnType.fromJson(
      {...data, 'epriv': pair.epriv, 'priv': pair.priv, 'pub': pair.pub});
}
