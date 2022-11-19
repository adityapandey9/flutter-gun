import 'dart:async';

import 'package:flutter_gundb/types/gun_graph_adapter.dart';

import '../types/chain_gun.dart';
import '../types/gun.dart';
import 'chain_gun_client.dart';
import 'control_flow/gun_event.dart';
import 'graph/gun_graph_utils.dart';
import 'interfaces.dart';

class ChainGunLink {
  final String key;
  late String? soul;

  late GunChainOptions _opt;
  late final GunEvent<GunValue?, String, dynamic> _updateEvent;
  late final ChainGunClient _chain;
  ChainGunLink? _parent;
  VoidCallback? _endQuery;
  GunValue? _lastValue;
  late bool _hasReceived;

  ChainGunLink(
      {required this.key,
      required ChainGunClient chain,
      ChainGunLink? parent}) {
    if (isNull(parent)) {
      soul = key;
    }
    _opt = GunChainOptions();
    _chain = chain;
    _parent = parent;
    _hasReceived = false;
    _updateEvent =
        GunEvent<GunValue?, String, dynamic>(name: getPath().join('|'));
  }

  /// @returns path of this node
  List<String> getPath() {
    if (!isNull(_parent)) {
      return [...?_parent?.getPath(), key];
    }

    return [key];
  }

  /// Traverse a location in the graph
  ///
  /// @param key Key to read data from
  /// @param cb
  /// @returns New chain context corresponding to given key
  ChainGunLink get(String key, [GunMsgCb? cb]) {
    return ChainGunLink(key: key, chain: _chain, parent: this);
  }

  /// Move up to the parent context on the chain.
  ///
  /// Every time a new chain is created, a reference to the old context is kept to go back to.
  ///
  /// @param amount The number of times you want to go back up the chain. {-1} or {Infinity} will take you to the root.
  /// @returns a parent chain context
  dynamic back([amount = 1]) {
    if (amount < 0 || amount == double.maxFinite.toInt()) {
      return _chain;
    }
    if (amount == 1) {
      return _parent ?? _chain;
    }
    return back(amount - 1);
  }

  /// Save data into gun, syncing it with your connected peers.
  ///
  /// You do not need to re-save the entire object every time, gun will automatically
  /// merge your data into what already exists as a "partial" update.
  ///
  /// @param value the data to save
  /// @param cb an optional callback, invoked on each acknowledgment
  /// @returns same chain context
  ChainGunLink put(GunValue value, [GunMsgCb? cb]) {
    _chain.graph.putPath(getPath(), value, cb, opt().uuid);
    return this;
  }

  /// Add a unique item to an unordered list.
  ///
  /// Works like a mathematical set, where each item in the list is unique.
  /// If the item is added twice, it will be merged.
  /// This means only objects, for now, are supported.
  ///
  /// @param data should be a gun reference or an object
  /// @param cb The callback is invoked exactly the same as .put
  /// @returns chain context for added object
  ChainGunLink set(dynamic data, [GunMsgCb? cb]) {
    if (data is ChainGunLink && !isNull(data.soul)) {
      put({
        data.soul: {'#': data.soul}
      }, cb);
    } else if (data is GunNode) {
      put({data.nodeMetaData?.key: data}, cb);
    } else {
      throw ('set() is only partially supported');
    }

    return this;
  }

  /// Register a callback for when it appears a record does not exist
  ///
  /// If you need to know whether a property or key exists, you can check with .not.
  /// It will consult the connected peers and invoke the callback if there's reasonable certainty that none of them have the data available.
  ///
  /// @param cb If there's reason to believe the data doesn't exist, the callback will be invoked. This can be used as a check to prevent implicitly writing data
  /// @returns same chain context
  ChainGunLink not(void Function(String key) cb) {
    promise().then((val) {
      if (isNull(val)) {
        cb(key);
      }
    });
    return this;
  }

  /// Change the configuration of this chain link
  ///
  /// @param options
  /// @returns current options
  GunChainOptions opt([GunChainOptions? options]) {
    if (!isNull(options)) {
      _opt = options!;
    }
    if (!isNull(_parent)) {
      return _opt;
    }
    return _opt;
  }

  /// Get the current data without subscribing to updates. Or undefined if it cannot be found.
  ///
  /// @param cb The data is the value for that chain at that given point in time. And the key is the last property name or ID of the node.
  /// @returns same chain context
  ChainGunLink once(GunOnCb cb) {
    promise().then((val) => cb(val, key));
    return this;
  }

  /// Subscribe to updates and changes on a node or property in realtime.
  ///
  /// Triggered once initially and whenever the property or node you're focused on changes,
  /// Since gun streams data, the callback will probably be called multiple times as new chunk comes in.
  ///
  /// To remove a listener call .off() on the same property or node.
  ///
  /// @param cb The callback is immediately fired with the data as it is at that point in time.
  /// @returns same chain context
  ChainGunLink on(GunOnCb cb) {
    if (key == '') {
      // TODO: "Map logic"
    }

    _updateEvent.on(cb);
    if (isNull(_endQuery)) {
      _endQuery = _chain.graph.query(getPath(), _onQueryResponse);
    }
    if (_hasReceived) {
      cb(_lastValue, key);
    }
    return this;
  }

  /// Unsubscribe one or all listeners subscribed with on
  ///
  /// @returns same chain context
  ChainGunLink off(GunOnCb? cb) {
    if (!isNull(cb)) {
      _updateEvent.off(cb!);
      if (!isNull(_endQuery) && _updateEvent.listenerCount() == 0) {
        _endQuery!();
      }
    } else {
      if (!isNull(_endQuery)) {
        _endQuery!();
      }
      _updateEvent.reset();
    }
    return this;
  }

  Future<GunValue> promise([timeout = 0]) {
    var completer = Completer<GunValue>();

    cb(GunValue val, [String? _, dynamic __]) {
      completer.complete(val);
      off(cb);
    }
    on(cb);

    if (timeout > 0) {
      Timer(Duration(milliseconds: timeout), () { completer.complete(null); });
    }

    return completer.future;
  }

  Future<dynamic> then(dynamic Function(GunValue gunValue) fn) {
    return promise().then(fn);
  }

  /// Iterates over each property and item on a node, passing it down the chain
  ///
  /// Not yet supported
  ///
  /// Behaves like a forEach on your data.
  /// It also subscribes to every item as well and listens for newly inserted items.
  ///
  /// @returns a new chain context holding many chains simultaneously.
  ChainGunLink map() {
    throw ("map() isn't supported yet");
  }

  /// No plans to support this
  ChainGunLink path(String path) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  ChainGunLink open(dynamic cb) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  ChainGunLink load(dynamic cb) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  ChainGunLink bye() {
    throw ('No plans to support this');
  }

  /// No plans to support this
  ChainGunLink later() {
    throw ('No plans to support this');
  }

  /// No plans to support this
  ChainGunLink unset(GunNode node) {
    throw ('No plans to support this');
  }

  void _onQueryResponse(GunValue? value, [String? _, dynamic __]) {
    _updateEvent.trigger(value, key);
    _lastValue = value;
    _hasReceived = true;
  }
}
