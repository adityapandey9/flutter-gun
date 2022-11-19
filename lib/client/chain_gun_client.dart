import 'package:flutter_gundb/client/transports/web_socket_graph_connector.dart';

import '../crdt/index.dart';
import '../types/chain_gun.dart';
import 'chain_gun_link.dart';
import 'graph/gun_graph.dart';
import 'graph/gun_graph_utils.dart';
import 'interfaces.dart';

class ChainGunOptions {
  late final List<String> peers;
  GunGraph? graph;

  merge(ChainGunOptions chainGunOptions) {
    peers = chainGunOptions.peers;
    graph = chainGunOptions.graph;
    // else {
    //   graph = GunGraph();
    // }
    // graph?.use(diffGunCRDT);
    // graph?.use(diffGunCRDT, kind: ChainGunMiddlewareType.write);
  }
}

class ChainGunClient {
  late final GunGraph graph;
  late final ChainGunOptions _opt;
  ChainGunLink? linkClass;

  ChainGunClient({this.linkClass, ChainGunOptions? chainGunOptions}) {
    if (!isNull(chainGunOptions) && !isNull(chainGunOptions?.graph)) {
      graph = chainGunOptions!.graph!;
    } else {
      graph = GunGraph();
      graph.use(diffGunCRDT);
      graph.use(diffGunCRDT, kind: ChainGunMiddlewareType.write);
    }
    _opt = ChainGunOptions();
    if (!isNull(chainGunOptions)) {
      opt(chainGunOptions!);
    }
  }

  /// Set ChainGun configuration options
  ///
  /// @param options
  ChainGunClient opt(ChainGunOptions options) {
    _opt.merge(options);

    if (options.peers.isNotEmpty) {
      for (var peer in options.peers) {
        final connector = WebSocketGraphConnector(url: peer);
        connector.sendPutsFromGraph(graph);
        connector.sendRequestsFromGraph(graph);
        graph.connect(connector);
      }
    }

    return this;
  }

  /// Traverse a location in the graph
  ///
  /// @param key Key to read data from
  /// @param cb
  /// @returns New chain context corresponding to given key
  ChainGunLink get(String soul, [GunMsgCb? cb]) {
    return linkClass = ChainGunLink(key: soul, chain: this);
  }
}
