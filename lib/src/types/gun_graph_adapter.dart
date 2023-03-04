
import 'generic.dart';
import 'gun.dart';

typedef ChangeSetEntry = Tuple<String, GunGraphData>;
typedef ChangeSetEntryFunc = Future<ChangeSetEntry?> Function();
typedef VoidCallback = void Function();
typedef SetChangeSetEntryFunc = void Function(ChangeSetEntry change);

class GunGetOpts {
  final String? point; // .
  final String? forward; // >
  final String? backward; // <
  final String? modulo; // %

  GunGetOpts(this.point, this.forward, this.backward, this.modulo);
}

abstract class GunGraphAdapter {
    void close();
    Future<GunNode?> get(String soul, [GunGetOpts opts]);
    Future<String> getJsonString(String soul, [GunGetOpts opts]);
    String getJsonStringSync(String soul, [GunGetOpts opts]);
    GunNode? getSync(String soul, [GunGetOpts opts]);
    Future<GunGraphData?> put(GunGraphData graphData);
    GunGraphData? putSync(GunGraphData graphData);

    Future<void> pruneChangelog(num before);

    ChangeSetEntryFunc getChangesetFeed(String from);

    VoidCallback onChange(SetChangeSetEntryFunc handler, [String from]);
}