import 'dart:async';

import '../client/transports/web_socket_graph_connector.dart';

import '../crdt/index.dart';
import '../types/flutter_gun.dart';
import 'flutter_gun_link.dart';
import 'graph/gun_graph.dart';
import 'graph/gun_graph_utils.dart';
import 'interfaces.dart';

class FlutterGunOptions {
  late final List<String> peers;
  GunGraph? graph;

  merge(FlutterGunOptions flutterGunOptions) {
    peers = flutterGunOptions.peers;
    graph = flutterGunOptions.graph;
    // else {
    //   graph = GunGraph();
    // }
    // graph?.use(diffGunCRDT);
    // graph?.use(diffGunCRDT, kind: FlutterGunMiddlewareType.write);
  }
}

class FlutterGunClient {
  GunGraph? graph;
  late FlutterGunOptions _opt;
  FlutterGunLink? linkClass;

  FlutterGunClient({this.linkClass, FlutterGunOptions? flutterGunOptions}) {
    initializedClient(linkClass: linkClass, flutterGunOptions: flutterGunOptions);
  }

  initializedClient({linkClass, FlutterGunOptions? flutterGunOptions}) {
    if (flutterGunOptions?.peers == null) {
      return;
    }
    this.linkClass = linkClass;

    if (!isNull(flutterGunOptions) && !isNull(flutterGunOptions?.graph)) {
      graph = flutterGunOptions!.graph!;
    } else {
      graph = GunGraph();
      graph!.use(diffGunCRDT);
      graph!.use(diffGunCRDT, kind: FlutterGunMiddlewareType.write);
    }
    _opt = FlutterGunOptions();
    if (!isNull(flutterGunOptions)) {
      opt(flutterGunOptions!);
    }
  }

  /// Set FlutterGun configuration options
  ///
  /// @param options
  FlutterGunClient opt(FlutterGunOptions options) {
    _opt.merge(options);

    if (options.peers.isNotEmpty) {
      for (var peer in options.peers) {
        final connector = WebSocketGraphConnector(url: peer);
        connector.sendPutsFromGraph(graph!);
        connector.sendRequestsFromGraph(graph!);
        graph!.connect(connector);
      }
    }

    return this;
  }

  /// Traverse a location in the graph
  ///
  /// @param key Key to read data from
  /// @param cb
  /// @returns New flutter context corresponding to given key
  FlutterGunLink get(String soul, [GunMsgCb? cb]) {
    return linkClass = FlutterGunLink(key: soul, flutter: this);
  }

  /// Traverse a location in the graph and Return the data
  ///
  /// @param key Key to read data from
  /// @param cb
  /// @returns New flutter context corresponding to given key
  Future<dynamic> getValue(String soul, [GunMsgCb? cb]) async {
    final tempFlutterGunLink = FlutterGunLink(key: soul, flutter: this);
    var completer = Completer<dynamic>();
    tempFlutterGunLink.once((a, [b, c]) {
      completer.complete(a);
    });

    return completer.future;
  }
}
