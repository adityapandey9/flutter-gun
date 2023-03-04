import 'dart:collection';

import 'package:uuid/uuid.dart';

import '../../crdt/index.dart';
import '../../types/gun.dart';
import '../flutter_gun_link.dart';
import '../interfaces.dart';
import 'gun_graph_node.dart';

String generateMessageId() {
  return const Uuid().v4();
}

List<List<String>> diffSets(
    final List<String> initial, final List<String> updated) {
  return [
    updated.where((key) => !initial.contains(key)).toList(),
    initial.where((key) => !updated.contains(key)).toList()
  ];
}

bool isObject(Object? node) {
  return !(node is int ||
      node is String ||
      node is num ||
      num is double ||
      node is bool ||
      node == null);
}

bool isArray(Object? node) {
  return !(node == null || node is! List);
}

bool isMap(Object? node) {
  return !(node == null || node is! Map || node is! MapBase);
}

bool isNull(Object? node) {
  return node == null;
}

GunGraphData nodeToGraph(GunNode node) {
  final modified = {...node};
  GunGraphData nodes = GunGraphData();
  final nodeSoul = node.nodeMetaData?.key;

  for (final key in node.keys) {
    final val = node[key];
    if (!isObject(val) || val == null) {
      continue;
    }

    if (val is GunGraphNode) {
      if (val.soul.isNotEmpty) {
        final edge = {'#': val.soul};
        modified[key] = edge;

        continue;
      }
    }

    String soul = '';

    if (val is GunNode) {
      soul = val.nodeMetaData!.key!;
    }

    if (val is FlutterGunLink && val.soul != null && val.soul!.isNotEmpty) {
      soul = val.soul!;
    }

    if (soul.isNotEmpty) {
      final edge = {'#': soul};
      modified[key] = edge;
      final graph = addMissingState(nodeToGraph(val));
      final diff = diffGunCRDT(graph, nodes);
      nodes = !isNull(diff) ? mergeGraph(nodes, diff!) : nodes;
    }
  }

  // print('SD:: ${modified.toString()} $nodeSoul');

  GunGraphData raw = GunGraphData();
  raw[nodeSoul!] = GunNode.fromJson(modified);
  final withMissingState = addMissingState(raw);
  final graphDiff = diffGunCRDT(withMissingState, nodes);
  nodes = !isNull(graphDiff) ? mergeGraph(nodes, graphDiff!) : nodes;

  return nodes;
}

GunGraphData flattenGraphData(GunGraphData data) {
  final List<GunGraphData> graphs = [];
  GunGraphData flatGraph = GunGraphData();

  for (final soul in data.keys) {
    final node = data[soul];
    if (!isNull(node)) {
      graphs.add(nodeToGraph(node!));
    }
  }

  for (final graph in graphs) {
    final diff = diffGunCRDT(graph, flatGraph);
    flatGraph = !isNull(diff) ? mergeGraph(flatGraph, diff!) : flatGraph;
  }

  return flatGraph;
}

PathData getPathData(List<String> keys, GunGraphData graph) {
  final lastKey = keys[keys.length - 1];

  if (keys.length == 1) {
    return PathData(
        souls: keys,
        complete: graph.containsKey(lastKey),
        value: graph[lastKey]);
  }

  PathData getPathDataParent =
      getPathData(keys.sublist(0, keys.length - 1), graph);

  if (!isObject(getPathDataParent.value)) {
    return PathData(
        souls: getPathDataParent.souls,
        complete: getPathDataParent.complete || !isNull(getPathDataParent.value),
        value: null);
  }

  final value = getPathDataParent.value[lastKey];

  if (isNull(value)) {
    return PathData(
        souls: getPathDataParent.souls, complete: true, value: value);
  }

  var edgeSoul;

  if (isObject(value)) {
    edgeSoul = value['#'];
  }

  if (!isNull(edgeSoul)) {
    return PathData(
        souls: [...getPathDataParent.souls, edgeSoul],
        complete: graph.containsKey(edgeSoul),
        value: graph[edgeSoul]);
  }

  return PathData(souls: getPathDataParent.souls, complete: true, value: value);
}

