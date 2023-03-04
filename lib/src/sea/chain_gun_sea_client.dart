
import '../client/chain_gun_client.dart';
import '../client/chain_gun_link.dart';
import '../sear/unpack.dart';
import '../types/gun.dart';
import 'chain_gun_user_api.dart';

class ChainGunSeaClient extends ChainGunClient {

  ChainGunUserApi? _user;
  ChainGunLink? linkClass;

  ChainGunSeaClient({ this.linkClass, ChainGunOptions? chainGunOptions }) {
    if (chainGunOptions == null) {
      var tempChainGunOptions = ChainGunOptions();
      tempChainGunOptions.peers = ["wss://gun-manhattan.herokuapp.com/gun"];
      chainGunOptions = tempChainGunOptions;
    }
    initializedClient(linkClass: linkClass, chainGunOptions: chainGunOptions);
    registerSearMiddleware();
  }

  ChainGunUserApi user() {
    return (_user ??= ChainGunUserApi(chainGunSeaClient: this));
  }

  void registerSearMiddleware() {
    graph!.use((GunGraphData updates, GunGraphData existingGraph) => unpackGraph(updates, graph!.getOpt().mutable!));
  }

}