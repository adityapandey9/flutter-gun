import '../../types/gun.dart';

import '../../types/flutter_gun.dart';
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
  VoidCallback get(FlutterGunGet flutterGunGet, [dynamic _, dynamic __]) {
    adapter.get(flutterGunGet.soul).then((node) {
      GunGraphData gunGraphData = GunGraphData();
      gunGraphData[flutterGunGet.soul] = node;
      return GunMsg(
          key: generateMessageId(),
          pos: flutterGunGet.msgId ?? '',
          put: !isNull(node) ? gunGraphData : null);
    }).catchError((err) {
      print(err);

      return GunMsg(
          key: generateMessageId(),
          pos: flutterGunGet.msgId ?? '',
          err: 'Error fetching node');
    }).then((msg) {
      ingest([msg]);
      if (!isNull(flutterGunGet.cb)) {
        flutterGunGet.cb!(msg);
      }
    });

    return NOOP;
  }

  @override
  VoidCallback put(FlutterGunPut flutterGunPut, [dynamic _, dynamic __]) {
    adapter
        .put(flutterGunPut.graph)
        .then((node) => GunMsg(
            key: generateMessageId(),
            pos: flutterGunPut.msgId ?? '',
            err: null,
            ok: true))
        .catchError((err) {
      print(err);

      return GunMsg(
          key: generateMessageId(),
          pos: flutterGunPut.msgId ?? '',
          err: 'Error saving put',
          ok: false);
    }).then((msg) {
      ingest([msg]);
      if (!isNull(flutterGunPut.cb)) {
        flutterGunPut.cb!(msg);
      }
    });

    return NOOP;
  }
}
