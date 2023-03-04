import '../../types/chain_gun.dart';
import '../../types/generic.dart';
import '../../types/gun.dart';
import '../../types/gun_graph_adapter.dart';
import '../graph/gun_graph_utils.dart';
import 'gun_graph_connector.dart';

class CallBacksMap extends GenericCustomValueMap<String, GunMsgCb> {}

abstract class GunGraphWireConnector extends GunGraphConnector {
  late final CallBacksMap _callbacks;
  final String name;

  GunGraphWireConnector({this.name = 'GunWireProtocol'}) {
    _callbacks = CallBacksMap();
    super.inputQueue.completed.on(_onProcessedInput);
  }

  @override
  GunGraphWireConnector off(String msgId, [dynamic _, dynamic __]) {
    super.off(msgId);
    _callbacks.remove(msgId);
    return this;
  }

  /// Send graph data for one or more nodes
  ///
  /// @returns A function to be called to clean up callback listeners
  @override
  VoidCallback put(ChainGunPut chainGunPut, [dynamic _, dynamic __]) {
    final GunMsg msg = GunMsg(put: chainGunPut.graph);
    if (!isNull(chainGunPut.msgId)) {
      msg.key = chainGunPut.msgId;
    }
    if (!isNull(chainGunPut.replyTo)) {
      msg.pos = chainGunPut.replyTo;
    }

    return req(msg, chainGunPut.cb);
  }

  /// Request data for a given soul
  ///
  /// @returns A function to be called to clean up callback listeners
  @override
  VoidCallback get(ChainGunGet chainGunGet, [dynamic _, dynamic __]) {
    final GunMsgGet get = GunMsgGet(key: chainGunGet.soul);
    final GunMsg msg = GunMsg(get: get);
    if (!isNull(chainGunGet.msgId)) {
      msg.key = chainGunGet.msgId;
    }

    return req(msg, chainGunGet.cb);
  }

  /// Send a message that expects responses via @
  ///
  /// @param msg
  /// @param cb
  VoidCallback req(GunMsg msg, GunMsgCb? cb) {
    final String reqId = msg.key = msg.key ?? generateMessageId();
    if (!isNull(cb)) {
      _callbacks[reqId] = cb!;
    }
    send([msg]);
    return () {
      off(reqId);
    };
  }

  void _onProcessedInput(GunMsg? msg, [dynamic _, dynamic __]) {
    if (isNull(msg)) {
      return;
    }
    final id = msg?.key;
    final replyTo = msg?.pos;

    if (!isNull(msg?.put)) {
      events.graphData.trigger(msg!.put!, id, replyTo);
    }

    if (!isNull(replyTo)) {
      final cb = _callbacks[replyTo];
      if (!isNull(cb)) {
        cb!(msg!);
      }
    }

    events.receiveMessage.trigger(msg!);
  }
}
