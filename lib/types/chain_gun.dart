import 'gun.dart';

typedef GunMsgCb = void Function(GunMsg msg);
typedef LexicalFunc = dynamic Function(GunValue x);

/// How puts are communicated to ChainGun connectors
class ChainGunPut {
  late GunGraphData graph;
  String? msgId;
  String? replyTo;
  GunMsgCb? cb;

  ChainGunPut({ required this.graph, this.msgId, this.replyTo, this.cb });
}

/// How gets are communicated to ChainGun connectors
class ChainGunGet {
  late String soul;
  String? msgId;
  String? key;
  GunMsgCb? cb;
  ChainGunGet({ required this.soul, this.msgId, this.key, this.cb });
}

class CrdtOption {
  num? machineState;
  num? futureGrace;
  LexicalFunc? lexical;

  CrdtOption({this.machineState, this.futureGrace, this.lexical});
}
