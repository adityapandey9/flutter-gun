import '../../types/gun.dart';

import '../../types/chain_gun.dart';
import '../../types/gun_graph_adapter.dart';
import '../graph/gun_graph_utils.dart';
import 'gun_graph_wire_connector.dart';

NOOP() => null;

class GunGraphConnectorFromAdapter extends GunGraphWireConnector {
  late final GunGraphAdapter adapter;
  final String name;

  GunGraphConnectorFromAdapter(
      {required this.adapter, this.name = 'GunGraphConnectorFromAdapter'});

  @override
  VoidCallback get(ChainGunGet chainGunGet, [dynamic _, dynamic __]) {
    adapter.get(chainGunGet.soul).then((node) {
      GunGraphData gunGraphData = GunGraphData();
      gunGraphData[chainGunGet.soul] = node;
      return GunMsg(
          key: generateMessageId(),
          pos: chainGunGet.msgId ?? '',
          put: !isNull(node) ? gunGraphData : null);
    }).catchError((err) {
      print(err);

      return GunMsg(
          key: generateMessageId(),
          pos: chainGunGet.msgId ?? '',
          err: 'Error fetching node');
    }).then((msg) {
      ingest([msg]);
      if (!isNull(chainGunGet.cb)) {
        chainGunGet.cb!(msg);
      }
    });

    return NOOP;
  }

  @override
  VoidCallback put(ChainGunPut chainGunPut, [dynamic _, dynamic __]) {
    adapter
        .put(chainGunPut.graph)
        .then((node) => GunMsg(
            key: generateMessageId(),
            pos: chainGunPut.msgId ?? '',
            err: null,
            ok: true))
        .catchError((err) {
      print(err);

      return GunMsg(
          key: generateMessageId(),
          pos: chainGunPut.msgId ?? '',
          err: 'Error saving put',
          ok: false);
    }).then((msg) {
      ingest([msg]);
      if (!isNull(chainGunPut.cb)) {
        chainGunPut.cb!(msg);
      }
    });

    return NOOP;
  }
}
