import '../../types/gun_graph_adapter.dart';

import '../../types/gun.dart';
import '../control_flow/gun_event.dart';
import '../interfaces.dart';
import 'gun_graph.dart';

typedef UpdateGraphFunc = void Function(GunGraphData data,
    [String? id, String? replyToId]);

class GunGraphNode {
  final String soul;

  late final GunEvent<GunNode?, dynamic, dynamic> _data;
  late final GunGraph _graph;
  VoidCallback? _endCurQuery;
  late final UpdateGraphFunc _updateGraph;

  GunGraphNode(
      {required this.soul,
      required GunGraph graph,
      required UpdateGraphFunc updateGraph}) {
    _graph = graph;
    _updateGraph = updateGraph;
    _data = GunEvent<GunNode?, dynamic, dynamic>(name: '<GunGraphNode $soul>');
  }

  num listenerCount() {
    return _data.listenerCount();
  }

  GunGraphNode get(GunNodeListenCb? cb) {
    if (cb != null) {
      on(cb);
    }
    _ask();
    return this;
  }

  GunGraphNode on(GunNodeListenCb cb) {
    _data.on(cb);
    return this;
  }

  GunGraphNode off([GunNodeListenCb? cb]) {
    if (cb != null) {
      _data.off(cb);
    } else {
      _data.reset();
    }

    if (_endCurQuery != null && _data.listenerCount() == 0) {
      _endCurQuery!();
      _endCurQuery = null;
    }

    return this;
  }

  GunGraphNode receive(GunNode? data) {
    _data.trigger(data, soul);
    return this;
  }

  GunGraphNode _ask() {
    if (_endCurQuery != null) {
      return this;
    }

    _graph.get(soul, _onDirectQueryReply);
    return this;
  }

  void _onDirectQueryReply(GunMsg msg) {
    if (msg.put == null) {
      GunGraphData gunGraphData = GunGraphData();
      gunGraphData[soul] = null;
      _updateGraph(gunGraphData, msg.pos);
    }
  }
}
