import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../types/gun.dart';
import '../graph/gun_graph_utils.dart';
import 'gun_graph_wire_connector.dart';

class WebSocketGraphConnector extends GunGraphWireConnector {
  final String url;
  late WebSocketChannel _ws;
  late bool isLocalConnected;

  WebSocketGraphConnector({required this.url}) {
    super.outputQueue.completed.on(_onOutputProcessed);
    _ws = _connectWebSocket();
    isLocalConnected = false;
  }

  _connectWebSocket() {
    final ws = WebSocketChannel.connect(Uri.parse(url));

    ws.stream.listen((event) {
      if (!isLocalConnected) {
        events.connection.trigger(true);
      }
      isLocalConnected=true;
      _onReceiveSocketData(event);
    }, onError: (_, __) {
      events.connection.trigger(false);
    }, onDone: () {
      isLocalConnected=false;
      events.connection.trigger(false);
      _ws = _connectWebSocket();
    });

    return ws;
  }

  List<GunMsg> _sendToWebsocket(List<GunMsg> msgs) {
    if (msgs.isEmpty) {
      return msgs;
    }
    print('Sending It:: ${msgs.length} ${jsonEncode(msgs[0])}');
    if (msgs.length == 1) {
      _ws.sink.add(jsonEncode(msgs[0]));
    } else if (msgs.length > 1) {
      _ws.sink.add(jsonEncode(msgs));
    }
    return msgs;
  }

  void _onOutputProcessed(GunMsg msg, [dynamic _, dynamic __]) {
    if (!isNull(msg)) {
      _sendToWebsocket([msg]);
    }
  }

  void _onReceiveSocketData(dynamic msg) {
    print('Received Msg: $msg');
    final json = jsonDecode(msg);
    // print('\n\nReceived Msg:---:: $json');

    if (isArray(json)) {
      ingest((json as List).map<GunMsg>((e) => GunMsg.fromJson(e)).toList());
    } else {
      ingest([GunMsg.fromJson(json)]);
    }
  }
}
