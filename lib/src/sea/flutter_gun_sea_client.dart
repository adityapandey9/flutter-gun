
import '../client/flutter_gun_client.dart';
import '../client/flutter_gun_link.dart';
import '../sear/unpack.dart';
import '../types/gun.dart';
import 'flutter_gun_user_api.dart';

class FlutterGunSeaClient extends FlutterGunClient {

  FlutterGunUserApi? _user;
  FlutterGunLink? linkClass;

  FlutterGunSeaClient({ this.linkClass, FlutterGunOptions? flutterGunOptions }) {
    if (flutterGunOptions == null) {
      var tempFlutterGunOptions = FlutterGunOptions();
      tempFlutterGunOptions.peers = ["wss://gun-manhattan.herokuapp.com/gun"];
      flutterGunOptions = tempFlutterGunOptions;
    }
    initializedClient(linkClass: linkClass, flutterGunOptions: flutterGunOptions);
    registerSearMiddleware();
  }

  FlutterGunUserApi user() {
    return (_user ??= FlutterGunUserApi(flutterGunSeaClient: this));
  }

  void registerSearMiddleware() {
    graph!.use((GunGraphData updates, GunGraphData existingGraph) => unpackGraph(updates, graph!.getOpt().mutable!));
  }

}