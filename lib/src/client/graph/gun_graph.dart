import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import '../../crdt/index.dart';
import '../../types/flutter_gun.dart';
import '../../types/enum.dart';
import '../../types/generic.dart';
import '../../types/gun.dart';
import '../../types/gun_graph_adapter.dart';
import '../control_flow/gun_event.dart';
import '../interfaces.dart';
import '../transports/gun_graph_connector.dart';
import 'gun_graph_node.dart';
import 'gun_graph_utils.dart';

class GunGraphOptions {
  MutableEnum? mutable;
}

typedef UUIDFuncType = FutureOr<String> Function(List<String> path);
typedef GraphConnectorFuncType = void Function(GunGraphConnector connector);

class GunGraphEvent {
  final GunEvent<GunGraphData, String?, String?> graphData;

  final GunEvent<FlutterGunPut, dynamic, dynamic> put;
  final GunEvent<FlutterGunGet, dynamic, dynamic> get;
  final GunEvent<String, dynamic, dynamic> off;

  GunGraphEvent(
      {required this.graphData,
      required this.put,
      required this.get,
      required this.off});
}

class GunGraphNodeMap extends GenericCustomValueMap<String, GunGraphNode> {}

class GunGraph {
  late final String id;

  late final GunGraphEvent events;

  late num activeConnectors;

  late final GunGraphOptions _opt;

  late final List<GunGraphConnector> _connectors;

  late final List<FlutterGunMiddleware> _readMiddleware;

  late final List<FlutterGunMiddleware> _writeMiddleware;

  late final GunGraphData _graph;

  late final GunGraphNodeMap _nodes;

  GunGraph() {
    id = generateMessageId();
    activeConnectors = 0;
    events = GunGraphEvent(
      graphData: GunEvent<GunGraphData, String?, String?>(name: 'graph data'),
      get: GunEvent<FlutterGunGet, dynamic, dynamic>(name: 'request soul'),
      off: GunEvent<String, dynamic, dynamic>(name: 'off event'),
      put: GunEvent<FlutterGunPut, dynamic, dynamic>(name: 'put data'),
    );
    _opt = GunGraphOptions();
    _opt.mutable = MutableEnum.immutable;
    _graph = GunGraphData();
    _nodes = GunGraphNodeMap();
    _connectors = [];
    _readMiddleware = [];
    _writeMiddleware = [];
  }

  /// Configure graph options
  ///
  /// Currently unused
  ///
  /// @param options
  GunGraph opt(GunGraphOptions options) {
    _opt = options;
    return this;
  }

  GunGraphOptions getOpt() {
    return _opt;
  }

  /// Connect to a source/destination for graph data
  ///
  /// @param connector the source or destination for graph data
  GunGraph connect(GunGraphConnector connector) {
    if (_connectors.contains(connector)) {
      return this;
    }
    _connectors.add(connector.connectToGraph(this));

    connector.events.connection.on(__onConnectorStatus);
    connector.events.graphData.on(_receiveGraphData);

    if (connector.isConnected) {
      activeConnectors++;
    }
    return this;
  }

  /// Disconnect from a source/destination for graph data
  ///
  /// @param connector the source or destination for graph data
  GunGraph disconnect(GunGraphConnector connector) {
    final idx = _connectors.indexOf(connector);
    connector.events.graphData.off(_receiveGraphData);
    connector.events.connection.off(__onConnectorStatus);
    if (idx != -1) {
      _connectors.removeAt(idx);
    }
    // TODO CHECK IF isConnected is true for the disconnect or not
    if (connector.isConnected) {
      activeConnectors--;
    }
    return this;
  }

  /// Register graph middleware
  ///
  /// @param middleware The middleware function to add
  /// @param kind Optionaly register write middleware instead of read by passing "write"
  GunGraph use(FlutterGunMiddleware middleware,
      {FlutterGunMiddlewareType kind = FlutterGunMiddlewareType.read}) {
    if (kind == FlutterGunMiddlewareType.read) {
      _readMiddleware.add(middleware);
    } else if (kind == FlutterGunMiddlewareType.write) {
      _writeMiddleware.add(middleware);
    }
    return this;
  }

  /// Unregister graph middleware
  ///
  /// @param middleware The middleware function to remove
  /// @param kind Optionaly unregister write middleware instead of read by passing "write"
  GunGraph unuse(FlutterGunMiddleware middleware,
      {FlutterGunMiddlewareType kind = FlutterGunMiddlewareType.read}) {
    if (kind == FlutterGunMiddlewareType.read) {
      final idx = _readMiddleware.indexOf(middleware);
      if (idx != -1) {
        _readMiddleware.removeAt(idx);
      }
    } else if (kind == FlutterGunMiddlewareType.write) {
      final idx = _writeMiddleware.indexOf(middleware);
      if (idx != -1) {
        _writeMiddleware.removeAt(idx);
      }
    }

    return this;
  }

  /// Read a potentially multi-level deep path from the graph
  ///
  /// @param path The path to read
  /// @param cb The callback to invoke with results
  /// @returns a cleanup function to after done with query
  VoidCallback query(List<String> path, GunOnCb cb) {
    List<String> lastSouls = [];
    GunValue currentValue;

    updateQuery(GunNode? _, [dynamic __, dynamic ___]) {
      PathData getPathDateList = getPathData(path, _graph);

      List<String> souls = getPathDateList.souls;
      GunValue value = getPathDateList.value;
      bool complete = getPathDateList.complete;

      final diffSetsList = diffSets(lastSouls, souls);

      List<String> added = diffSetsList[0];
      List<String> removed = diffSetsList[1];

      if ((complete && currentValue == null) ||
          (value != null && value != currentValue)) {
        currentValue = value;
        cb(value, path[path.length - 1]);
      }

      for (final soul in added) {
        _requestSoul(soul, updateQuery);
      }

      for (final soul in removed) {
        _unlistenSoul(soul, updateQuery);
      }

      lastSouls = souls;
    }

    updateQuery(null);

    return () {
      for (final soul in lastSouls) {
        _unlistenSoul(soul, updateQuery);
      }
    };
  }

  FutureOr<String> _internalUUIdFn(List<String> path) {
      return path.join('/');
  }

  GunGraphData _getPutPathGunGraph(List<String> souls, GunValue data) {
    // Create a new Map for the converted JSON
    GunGraphData data2 = GunGraphData();
    var data1 = {};
    var temp = data1;
    for (var i = 0; i < souls.length; i++) {
      if (i != souls.length - 1) {
        temp[souls[i]] = {};
        temp = temp[souls[i]];
      } else {
        temp[souls[i]] = data;
      }
    }

    // Create a queue to store the keys and values that need to be processed
    var queue = Queue();
    var pathQueue = Queue();

    // Add the root data to the queue
    queue.addAll(data1.entries);
    for (var i = 0; i < data1.entries.length; i++) {
      pathQueue.add("");
    }

    // Keep processing the keys and values in the queue until it is empty
    while (queue.isNotEmpty) {
      // Get the next key and value from the queue
      var entry = queue.removeFirst();
      var key = entry.key;
      var value = entry.value;
      var path = "";
      if (pathQueue.isNotEmpty) {
        path = pathQueue.removeFirst();
      }
      // Concatenate the current key to the path
      var currentPath = path.isEmpty ? key : path.contains("~@") ? key : '$path/$key';

      // Check if the value is a Map (i.e. another nested dictionary)
      if (value is Map) {
        // If it is a Map, create a new Map for the converted data
        Map<String, dynamic> currentData2 = {};

        // Add the metadata to the Map
        currentData2['_'] = {'#': currentPath, '>': {}};

        for (final entry in value.entries) {
          currentData2['_']['>'][entry.key] =
              DateTime.now().millisecondsSinceEpoch;
          if (entry.value is Map) {
            currentData2[entry.key] = {"#": currentPath.contains("~@") ? entry.key : "$currentPath/${entry.key}"};
          } else {
            currentData2[entry.key] = entry.value;
          }
        }

        // Add the Map to the converted data
        data2[currentPath] = GunNode.fromJson(currentData2);

        // Add the nested data to the queue
        queue.addAll(value.entries);
        for (var i = 0; i < value.entries.length; i++) {
          pathQueue.add(currentPath);
        }
      }
    }

    return data2;
  }

  /// Write graph data to a potentially multi-level deep path in the graph
  ///
  /// @param path The path to read
  /// @param data The value to write
  /// @param cb Callback function to be invoked for write acks
  /// @returns a promise
  Future<void> putPath(final List<String> fullPath, GunValue data, [GunMsgCb? cb,
    UUIDFuncType? uuidFn]) async {
    uuidFn ??= _internalUUIdFn;
    if (fullPath.isEmpty) {
      throw ("No path specified");
    }

    GunGraphData graph = _getPutPathGunGraph(fullPath, data);

    put(graph, cb);
  }

  Future<List<String>> getPathSouls(List<String> path) async {
    var completer = Completer<List<String>>();

    if (path.length == 1) {
      completer.complete(path);
    }

    List<String> lastSouls = [];

    updateQuery(GunNode? _, [dynamic __, dynamic ___]) {
      PathData getPathDataList = getPathData(path, _graph);

      List<String> souls = getPathDataList.souls;
      bool complete = getPathDataList.complete;

      // print('updateQuery: ${souls.toString()} -- $complete');

      final diffSetsList = diffSets(lastSouls, souls);

      dynamic added = diffSetsList[0];
      dynamic removed = diffSetsList[1];

      // print('diffSetsList:: ${added.toString()} -- ${removed.toString()}');

      end() {
        for (final soul in lastSouls) {
          _unlistenSoul(soul, updateQuery);
        }
        lastSouls = [];
      }

      if (complete) {
        end();
        if (!completer.isCompleted) {
          completer.complete(souls);
        }
        return;
      } else {
        for (final soul in added) {
          _requestSoul(soul, updateQuery);
        }

        for (final soul in removed) {
          _unlistenSoul(soul, updateQuery);
        }
      }

      lastSouls = souls;
    }

    updateQuery(null);

    return completer.future;
  }

  /// Request node data
  ///
  /// @param soul identifier of node to request
  /// @param cb callback for response messages
  /// @param msgId optional unique message identifier
  /// @returns a function to cleanup listeners when done
  VoidCallback get(String soul, [GunMsgCb? cb, String? msgId]) {
    String id = msgId ?? generateMessageId();

    events.get.trigger(FlutterGunGet(cb: cb, msgId: msgId, soul: soul));

    return () => events.off.trigger(id);
  }

  /// Write node data
  ///
  /// @param data one or more gun nodes keyed by soul
  /// @param cb optional callback for response messages
  /// @param msgId optional unique message identifier
  /// @returns a function to clean up listeners when done
  VoidCallback put(GunGraphData data, [GunMsgCb? cb, String? msgId]) {
    GunGraphData? diff = flattenGraphData(addMissingState(data));

    final String id = msgId ?? generateMessageId();
    (() async {
      for (final fn in _writeMiddleware) {
        if (diff == null) {
          return;
        }
        diff = await fn(diff!, _graph);
      }
      if (diff == null) {
        return;
      }
      
      // print('Data-->Encoded::Sent:: ${jsonEncode(diff)}');

      events.put.trigger(FlutterGunPut(graph: diff!, cb: cb, msgId: id));

      _receiveGraphData(diff!);
    })();

    return () => events.off.trigger(id);
  }

  /// Synchronously invoke callback function for each connector to this graph
  ///
  /// @param cb The callback to invoke
  GunGraph eachConnector(GraphConnectorFuncType cb) {
    for (final connector in _connectors) {
      cb(connector);
    }

    return this;
  }

  /// Update graph data in this flutter from some local or external source
  ///
  /// @param data node data to include
  FutureOr<void> _receiveGraphData(GunGraphData data, [String? id, String? replyToId]) async {
    GunGraphData? diff = data;

    for (final fn in _readMiddleware) {
      if (diff == null) {
        return;
      }
      diff = await fn(diff, _graph);
    }

    if (diff == null) {
      return;
    }

    for (final soul in diff.keys) {
      final node = _nodes[soul];
      if (node == null) {
        continue;
      }
      node.receive((_graph[soul] =
          mergeGunNodes(_graph[soul], diff[soul], mut: _opt.mutable!)));
    }

    events.graphData.trigger(diff, id, replyToId);
  }

  GunGraphNode _node(String soul) {
    return (_nodes[soul] = _nodes[soul] ??
        GunGraphNode(graph: this, soul: soul, updateGraph: _receiveGraphData));
  }

  GunGraph _requestSoul(String soul, GunNodeListenCb cb) {
    _node(soul).get(cb);
    return this;
  }

  GunGraph _unlistenSoul(String soul, GunNodeListenCb cb) {
    if (!_nodes.containsKey(soul)) {
      return this;
    }
    final node = _nodes[soul];
    if (node == null) {
      return this;
    }
    node.off(cb);
    if (node.listenerCount() <= 0) {
      node.off();
      _forgetSoul(soul);
    }
    return this;
  }

  GunGraph _forgetSoul(String soul) {
    if (!_nodes.containsKey(soul)) {
      return this;
    }
    final node = _nodes[soul];
    if (node != null) {
      node.off();
      _nodes.remove(soul);
    }

    _graph.remove(soul);
    return this;
  }

  void __onConnectorStatus(bool connected, [dynamic _, dynamic __]) {
    if (connected == true) {
      activeConnectors++;
    } else {
      activeConnectors--;
    }
  }
}
