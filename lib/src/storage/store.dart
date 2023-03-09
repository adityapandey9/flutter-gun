import 'dart:convert';

import '../crdt/index.dart' show mergeGunNodes;

import '../types/gun.dart';
import 'init.dart';

GunGraphData getStoreData(GunGraphData graph, [num activeConnectors = 0]) {

  if (InitStorage.hiveOpenBox == null || InitStorage.hiveOpenBox!.isOpen == false) {
    throw ("Initiate Flutter Gun using: `await initializeFlutterGun()`");
  }

  if (activeConnectors > 0) {
    return graph;
  }

  final GunGraphData unpackedGraph = graph;

  for (final soul in graph.keys) {
    GunNode? node;
    if (InitStorage.hiveOpenBox!.containsKey(soul)) {
      GunNode tempNode = GunNode.fromJson(jsonDecode(InitStorage.hiveOpenBox?.get(soul)));
      node = mergeGunNodes(tempNode, graph[soul]);
      node?.nodeMetaData = graph[soul]?.nodeMetaData;
    } else {
      node = graph[soul];
    }

    unpackedGraph[soul] = node;
  }

  return unpackedGraph;
}


GunGraphData setStoreData(GunGraphData graph) {

  if (InitStorage.hiveOpenBox == null || InitStorage.hiveOpenBox!.isOpen == false) {
    throw ("Initiate Flutter Gun using: `await initializeFlutterGun()`");
  }

  final GunGraphData unpackedGraph = graph;

  for (final soul in graph.keys) {
    GunNode? node;
    if (InitStorage.hiveOpenBox!.containsKey(soul)) {
      GunNode tempNode = GunNode.fromJson(jsonDecode(InitStorage.hiveOpenBox?.get(soul)));
      node = mergeGunNodes(tempNode, graph[soul]);
      node?.nodeMetaData = graph[soul]?.nodeMetaData;
    } else {
      node = graph[soul];
    }

    InitStorage.hiveOpenBox?.put(soul, jsonEncode(node));

    unpackedGraph[soul] = node;
  }

  return unpackedGraph;
}
