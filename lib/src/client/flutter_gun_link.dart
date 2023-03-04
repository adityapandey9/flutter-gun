import 'dart:async';

import '../types/gun_graph_adapter.dart';

import '../types/flutter_gun.dart';
import '../types/gun.dart';
import 'flutter_gun_client.dart';
import 'control_flow/gun_event.dart';
import 'graph/gun_graph_utils.dart';
import 'interfaces.dart';

class FlutterGunLink {
  final String key;
  late String? soul;

  late GunFlutterOptions _opt;
  late final GunEvent<GunValue?, String, dynamic> _updateEvent;
  late final FlutterGunClient _flutter;
  FlutterGunLink? _parent;
  VoidCallback? _endQuery;
  GunValue? _lastValue;
  late bool _hasReceived;

  FlutterGunLink(
      {required this.key,
      required FlutterGunClient flutter,
      FlutterGunLink? parent}) {
    if (isNull(parent)) {
      soul = key;
    }
    _opt = GunFlutterOptions();
    _flutter = flutter;
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
  /// @returns New flutter context corresponding to given key
  FlutterGunLink get(String key, [GunMsgCb? cb]) {
    return FlutterGunLink(key: key, flutter: _flutter, parent: this);
  }

  /// Move up to the parent context on the flutter.
  ///
  /// Every time a new flutter is created, a reference to the old context is kept to go back to.
  ///
  /// @param amount The number of times you want to go back up the flutter. {-1} or {Infinity} will take you to the root.
  /// @returns a parent flutter context
  dynamic back([amount = 1]) {
    if (amount < 0 || amount == double.maxFinite.toInt()) {
      return _flutter;
    }
    if (amount == 1) {
      return _parent ?? _flutter;
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
  /// @returns same flutter context
  FlutterGunLink put(GunValue value, [GunMsgCb? cb]) {
    _flutter.graph!.putPath(getPath(), value, cb, opt().uuid);
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
  /// @returns flutter context for added object
  FlutterGunLink set(dynamic data, [GunMsgCb? cb]) {
    if (data is FlutterGunLink && !isNull(data.soul)) {
      final temp = {};
      temp[data.soul] = {'#': data.soul};
      put(temp, cb);
    } else if (data is GunNode) {
      final temp = {};
      temp[data.nodeMetaData?.key] = data;
      put(temp, cb);
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
  /// @returns same flutter context
  FlutterGunLink not(void Function(String key) cb) {
    promise().then((val) {
      if (isNull(val)) {
        cb(key);
      }
    });
    return this;
  }

  /// Change the configuration of this flutter link
  ///
  /// @param options
  /// @returns current options
  GunFlutterOptions opt([GunFlutterOptions? options]) {
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
  /// @param cb The data is the value for that flutter at that given point in time. And the key is the last property name or ID of the node.
  /// @returns same flutter context
  FlutterGunLink once(GunOnCb cb) {
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
  /// @returns same flutter context
  FlutterGunLink on(GunOnCb cb) {
    if (key == '') {
      // TODO: "Map logic"
    }

    _updateEvent.on(cb);
    if (isNull(_endQuery)) {
      _endQuery = _flutter.graph!.query(getPath(), _onQueryResponse);
    }
    if (_hasReceived) {
      cb(_lastValue, key);
    }
    return this;
  }

  /// Unsubscribe one or all listeners subscribed with on
  ///
  /// @returns same flutter context
  FlutterGunLink off([GunOnCb? cb]) {
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

  /// Iterates over each property and item on a node, passing it down the flutter
  ///
  /// Not yet supported
  ///
  /// Behaves like a forEach on your data.
  /// It also subscribes to every item as well and listens for newly inserted items.
  ///
  /// @returns a new flutter context holding many flutters simultaneously.
  FlutterGunLink map() {
    throw ("map() isn't supported yet");
  }

  /// No plans to support this
  FlutterGunLink path(String path) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  FlutterGunLink open(dynamic cb) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  FlutterGunLink load(dynamic cb) {
    throw ('No plans to support this');
  }

  /// No plans to support this
  FlutterGunLink bye() {
    throw ('No plans to support this');
  }

  /// No plans to support this
  FlutterGunLink later() {
    throw ('No plans to support this');
  }

  /// No plans to support this
  FlutterGunLink unset(GunNode node) {
    throw ('No plans to support this');
  }

  void _onQueryResponse(GunValue? value, [String? _, dynamic __]) {
    _updateEvent.trigger(value, key);
    _lastValue = value;
    _hasReceived = true;
  }
}
