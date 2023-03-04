import 'dart:convert';

import '../types/flutter_gun.dart';
import '../types/enum.dart';
import '../types/gun.dart';

GunGraphData addMissingState(GunGraphData graphData) {
  final updatedGraphData = graphData;
  final now = DateTime.now().millisecondsSinceEpoch;

  for (final soul in graphData.entries) {
    if (soul.value == null) {
      continue;
    }

    var node = soul.value;

    var meta = (node?.nodeMetaData = node.nodeMetaData ?? GunNodeMeta());
    meta?.key = soul.key;
    var state = (meta?.forward = meta.forward ?? GunNodeState());

    for (final key in node!.keys) {
      if (key == '_') {
        continue;
      }
      state?[key] = state[key] ?? now;
    }
    updatedGraphData[soul.key] = node;
  }

  return updatedGraphData;
}

GunGraphData? diffGunCRDT(GunGraphData updatedGraph, GunGraphData existingGraph,
    {CrdtOption? opts}) {
  opts ??= CrdtOption(lexical: jsonEncode, futureGrace: 10 * 60 * 1000);

  var machineState = DateTime.now().millisecondsSinceEpoch,
      futureGrace = opts.futureGrace,
      lexical = opts.lexical!;

  final maxState = machineState + futureGrace!;

  final GunGraphData allUpdates = GunGraphData();

  for (final soul in updatedGraph.entries) {
    final GunNode? existing = existingGraph[soul.key];
    final GunNode? updated = soul.value;

    final GunNodeState existingState =
        existing?.nodeMetaData?.forward ?? GunNodeState();
    final GunNodeState updatedState =
        updated?.nodeMetaData?.forward ?? GunNodeState();

    if (updated == null) {
      if (existing == null) {
        allUpdates[soul.key] = updated;
      }
      continue;
    }

    var hasUpdates = false;

    final GunNode updates = GunNode(
        nodeMetaData: GunNodeMeta(key: soul.key, forward: GunNodeState()));

    for (final key in updatedState.keys) {
      final existingKeyState = existingState[key];
      final updatedKeyState = updatedState[key];

      if (updatedKeyState == null || updatedKeyState > maxState) {
        continue;
      }
      if (existingKeyState != null && existingKeyState >= updatedKeyState) {
        continue;
      }

      if (existingKeyState == updatedKeyState) {
        final existingVal = existing?[key];
        final updatedVal = updated[key];
        // This is based on Gun's logic
        if (lexical(updatedVal) <= lexical(existingVal)) {
          continue;
        }
      }

      updates[key] = updated[key];
      updates.nodeMetaData?.forward![key] = updatedKeyState;
      hasUpdates = true;
    }

    if (hasUpdates) {
      allUpdates[soul.key] = updates;
    }
  }

  return allUpdates.isNotEmpty ? allUpdates : null;
}

GunNode? mergeGunNodes(GunNode? existing, GunNode? updates,
    {MutableEnum mut = MutableEnum.immutable}) {
  if (existing == null) {
    return updates;
  }
  if (updates == null) {
    return existing;
  }
  final existingMeta = existing.nodeMetaData ?? GunNodeMeta();
  final existingState = existingMeta.forward ?? GunNodeState();
  final updatedMeta = updates.nodeMetaData ?? GunNodeMeta();
  final updatedState = updatedMeta.forward ?? GunNodeState();

  if (mut == MutableEnum.mutable) {
    existingMeta.forward = existingState;
    existing.nodeMetaData = existingMeta;

    for (final key in updatedState.keys) {
      existing[key] = updates[key];
      existingState[key] = updatedState[key]!;
    }

    return existing;
  }

  return GunNode.fromJson({
    ...existing,
    ...updates,
    "_": {
      "#": existingMeta.key,
      ">": {
        ...?existingMeta.forward,
        ...?updates.nodeMetaData?.forward
      }
    }
  });
}

GunGraphData mergeGraph(GunGraphData existing, GunGraphData diff,
    {MutableEnum mut = MutableEnum.immutable}) {
  final GunGraphData result = existing;
  for (final soul in diff.keys) {
    result[soul] = mergeGunNodes(existing[soul], diff[soul], mut: mut);
  }

  return result;
}
