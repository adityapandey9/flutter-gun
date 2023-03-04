import 'generic.dart';

/// Timestamp of last change for each attribute
class GunNodeState extends GenericCustomValueMap<String, num> {}

/// Soul and State of a Gun Node
class GunNodeMeta {
  String? key; // #
  GunNodeState? forward; // >

  GunNodeMeta({this.key, this.forward});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'#': key, '>': forward?.toMap()};

  factory GunNodeMeta.fromJson(Map<String, dynamic> parsedJson) {
    GunNodeState gunNodeState = GunNodeState();
    if (parsedJson.containsKey('>')) {
      gunNodeState.merge(parsedJson['>']);
    }
    return GunNodeMeta(
      key: parsedJson['#'].toString(),
      forward: gunNodeState,
    );
  }
}

/// A node (or partial node data) in a Gun Graph
class GunNode extends GenericCustomValueMap<String, dynamic> {
  late GunNodeMeta? nodeMetaData; // _

  GunNode({this.nodeMetaData});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'_': nodeMetaData?.toJson(), ...toMap()};

  factory GunNode.fromJson(Map<String, dynamic> parsedJson) {
    GunNodeMeta gunNodeMeta = GunNodeMeta();
    if (parsedJson.containsKey('_')) {
      gunNodeMeta = GunNodeMeta.fromJson(parsedJson['_']);
      parsedJson.remove('_');
    }
    GunNode gunNode = GunNode(
      nodeMetaData: gunNodeMeta,
    );
    gunNode.merge(parsedJson);
    return gunNode;
  }
}

/// Gun Graph Data consists of one or more full or partial nodes
class GunGraphData extends GenericCustomValueMap<String, GunNode?> {
  GunGraphData();

  factory GunGraphData.fromJson(Map<String, dynamic> parsedJson) {
    GunGraphData gunGraphData = GunGraphData();
    gunGraphData.addAll(parsedJson.map<String, GunNode?>(
        (key, value) => MapEntry(key, GunNode.fromJson(value))));
    return gunGraphData;
  }
}

class GunMsgGet {
  String? key; // #

  GunMsgGet({this.key});

  Map<String, dynamic> toJson() => <String, dynamic>{'#': key};

  factory GunMsgGet.fromJson(Map<String, dynamic> parsedJson) {
    return GunMsgGet(
      key: parsedJson['#'].toString(),
    );
  }
}

/// A standard Gun Protocol Message
class GunMsg {
  String? key; // #
  String? pos; // @
  bool? ack;
  dynamic err;
  dynamic ok;
  GunGraphData? put;
  GunMsgGet? get;

  GunMsg({this.key, this.pos, this.put, this.get, this.ack, this.err, this.ok});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      '#': key,
      '@': pos,
      'ack': ack,
      'err': err,
      'ok': ok,
      'get': get?.toJson(),
      'put': put?.toMap().map<String, dynamic>(
              (key, value) => MapEntry(key, value?.toJson())),
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  factory GunMsg.fromJson(Map<String, dynamic> parsedJson) => GunMsg(
      key: parsedJson['#']?.toString(),
      pos: parsedJson['@']?.toString(),
      ack: parsedJson['ack']?.toString() == 'true',
      ok: parsedJson['ok'],
      err: parsedJson['err']?.toString(),
      get: parsedJson.containsKey('get')
          ? GunMsgGet.fromJson(parsedJson['get'])
          : null,
      put: parsedJson.containsKey('put')
          ? GunGraphData.fromJson(parsedJson['put'])
          : null);
}

typedef GunValue = dynamic;
