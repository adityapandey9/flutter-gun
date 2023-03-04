import 'dart:async';

import '../types/gun.dart';
import 'control_flow/gun_event.dart';

typedef FutureOrStringFunc = FutureOr<String> Function(List<String> path);

class GunChainOptions {
   FutureOrStringFunc? uuid;
}

typedef GunOnCb = EventCb<dynamic, String?, dynamic>;
typedef GunNodeListenCb = EventCb<GunNode?, dynamic, dynamic>;

class PathData {
   final List<String> souls;
   final GunValue value;
   final bool complete;

   PathData({ required this.souls, this.value, this.complete = false });
}

typedef ChainGunMiddleware = FutureOr<GunGraphData?> Function(GunGraphData updates, GunGraphData existingGraph);

enum ChainGunMiddlewareType {
   read,
   write
}