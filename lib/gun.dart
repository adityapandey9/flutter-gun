import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gundb/shim_utils.dart';
import 'package:flutter_gundb/state.dart';
import 'package:flutter_gundb/types/generic.dart';
import 'package:flutter_gundb/valid.dart';
import 'package:flutter_gundb/onto.dart';

import 'package:flutter_gundb/dup.dart';

import 'package:flutter_gundb/ask.dart';

import 'client/graph/gun_graph_utils.dart';

dynamic EMPTY([List? args]) {}

cut(s) {
  return " '${('' + s).substring(0, 9)}...' ";
}

cfFn() {
  if (C > 999 &&
      (C / -(CT - (CT = DateTime.now().millisecondsSinceEpoch)) > 1)) {
    if (kDebugMode) {
      print(
          "Warning: You're syncing 1K+ records a second, faster than DOM can update - consider limiting query.");
    }
    CF = () {
      C = 0;
    };
  }
}

obj_each(Map o, void Function(dynamic) f){
  o.keys.toList().forEach(f);
}

var C = 0;
var empty = {};
var ERR = "Error: Invalid graph!";
var L = jsonEncode, MD = 2147483647, _State = Gun.state;
var CT, CF = cfFn, turn = setTimeout.turn;

class Gun extends GenericCustomValueMap<String, dynamic> {
  static String version = '0.2020';
  static late Gun chain;

  static validFnType valid = validFn;
  static State state = State();
  static ontoFnType on = ontoFn;
  static DupFnType dup = DupFn;
  static askType ask = askFn;

  Gun() {
    Gun.on()['put'] = put;
    Gun.on()['get'] = onGet;
    Gun.on()['get'] = onGet;
    Gun.on()['get_ack'] = onAck;
    Gun.chain['opt'] = opt;
  }

  init([o]) {
    if (o is Gun) {
      return ({'\$': this} as Gun)['\$'];
    }
    if (o is! Gun) {
      return init(o);
    }
    return create({'\$': this, 'opt': o} as Gun);
  }

  isFn($) {
    return ($ is Gun) || ($ != null && $['_'] && ($ == $['_']['\$'])) || false;
  }

  create([at]) {
    at['root'] = at['root'] ?? at;
    at['graph'] = at['graph'] ?? {};
    at['on'] = at['on'] ?? Gun.on;
    at['ask'] = at['ask'] ?? Gun.ask;
    at['dup'] = at['dup'] || Gun.dup();
    var gun = at['\$'].opt(at['opt']);
    if (at['once'] == null) {
      at.on('in', universe, at);
      at.on('out', universe, at);
      at.on('put', map, at);
      Gun.on('create', at);
      at.on('create', at);
    }
    at.once = 1;
    return gun;
  }

  universe([msg]) {
    // TODO: BUG! msg.out = null being set!
    //if(!F){ var eve = this; setTimeout(function(){ universe.call(eve, msg,1) },Math.random() * 100);return; } // ADD F TO PARAMS!
    if (msg == null) {
      return null;
    }
    if (msg['out'] == universe) {
      // TODO `to` not defined
      Gun.on()['to'].next(msg);
      return null;
    }
    var eve = this,
        as = eve['as'],
        at = as['at'] ?? as,
        gun = at['\$'],
        dup = at['dup'],
        tmp,
        DBG = msg['DBG'];
    (tmp = msg['#']) ?? (tmp = msg['#'] = ''.random(9));
    if (dup['check'](tmp)) {
      return null;
    }
    dup['track'](tmp);
    tmp = msg['_'];
    msg['_'] = (tmp is Function) ? tmp : EMPTY;
    (msg['\$'] && (msg['\$'] == (msg['\$']['_'] ?? '')['\$'])) ||
        (msg['\$'] = gun);
    if (msg['@'] && !msg['put']) {
      ack(msg);
    }
    if (!at.ask(msg['@'], msg)) {
      // is this machine listening for an ack?
      DBG ? (DBG['u'] = DateTime.now().millisecondsSinceEpoch) : null;
      if (msg.put) {
        put(msg);
        return null;
      } else if (msg.get) {
        Gun.on()['get'](msg, gun);
      }
    }
    DBG ? (DBG['uc'] = DateTime.now().millisecondsSinceEpoch) : null;
    // TODO `to` not defined
    eve['to'].next(msg);
    DBG ? (DBG['ua'] = DateTime.now().millisecondsSinceEpoch) : null;
    // TODO: This shouldn't be in core, but fast way to prevent NTS spread. Delete this line after all peers have upgraded to newer versions.
    if (msg['nts'] || msg['NTS']) {
      return null;
    }
    msg['out'] = universe;
    at.on('out', msg);
    DBG ? (DBG['ue'] = DateTime.now().millisecondsSinceEpoch) : null;
  }

  put([msg]) {
    if (msg == null) {
      return null;
    }
    var ctx = msg['_'] ?? {},
        root = ctx['root'] = ((ctx['\$'] = msg['\$'] ?? {})['_'] ?? {})['root'];
    // TODO: AXE may split/route based on 'put' what should we do here? Detect @ in AXE?
    // TODO:  I think we don't have to worry, as DAM will route it on @.
    if (msg['@'] &&
        (ctx as Map).containsKey('faith') &&
        !ctx.containsKey('miss')) {
      msg['out'] = universe;
      root.on('out', msg);
      return null;
    }
    ctx['latch'] = root['hatch'];
    ctx['match'] = root['hatch'] = [];
    var put = msg['put'];
    var DBG = ctx['DBG'] = msg['DBG'],
        S = DateTime.now().millisecondsSinceEpoch;
    // TODO: where did CT = CT ?? S; CT came from?
    var CT = S;
    // TODO: BUG! This needs to call HAM instead.
    if (put['#'] && put['.']) {
      /*root && root.on('put', msg);*/
      return null;
    }
    DBG ? (DBG['p'] = S) : null;
    ctx['#'] = msg['#'];
    ctx['msg'] = msg;
    ctx['all'] = 0;
    ctx['stun'] = 1;
    // TODO: This is unbounded operation, large graphs will be slower.
    // TODO: Write our own CPU scheduled sort? Or somehow do it in below? Keys itself is not O(1) either,
    // TODO: create ES5 shim over ?weak map? or custom which is constant.
    var nl = (put as Map).keys.toList(); //.sort();
    if (kDebugMode) {
      print(
          "$S, ${((DBG ?? ctx)['pk'] = DateTime.now().millisecondsSinceEpoch) - S}, put sort");
    }
    var ni = 0, nj, kl, soul, node, states, err, tmp;
    pop([o]) {
      if (nj != ni) {
        nj = ni;
        if (!(soul = nl[ni])) {
          if (kDebugMode) {
            print(
                "$S, ${((DBG ?? ctx)['pd'] = DateTime.now().millisecondsSinceEpoch) - S}, put");
          }
          fire(ctx);
          return;
        }

        if (!(node = put[soul])) {
          err = cut(soul) + "no node.";
        } else if (!(tmp = node['_'])) {
          err = cut(soul) + "no meta.";
        } else if (soul != tmp['#']) {
          err = cut(soul) + "soul not same.";
        } else if (!(states = tmp['>'])) {
          err = cut(soul) + "no state.";
        }
        kl = ((node ?? {}) as Map).keys.toList(); // TODO: .keys( is slow
      }

      if (err) {
        msg['err'] =
            ctx['err'] = err; // invalid data should error and stun the message.
        fire(ctx);
        //console.log("handle error!", err) // handle!
        return null;
      }
      var i = 0, key;
      o = o ?? 0;
      while (o++ < 9 && (key = kl[i++])) {
        if ('_' == key) {
          continue;
        }
        var val = node[key], state = states[key];
        if (u == state) {
          err = cut(key) + "on" + cut(soul) + "no state.";
          break;
        }
        if (!valid(val)) {
          err = cut(key) +
              "on" +
              cut(soul) +
              "bad " +
              (val.runtimeType.toString()) +
              cut(val);
          break;
        }
        ham(val, key, soul, state, msg);
        ++C; // courtesy count;
      }
      if ((kl = kl.slice(i)).length) {
        turn(pop);
        return null;
      }
      ++ni;
      kl = null;
      pop(o);
    }

    pop();
  }

  ham([val, key, soul, state, msg]) {
    var ctx = msg['_'] ?? {},
        root = ctx['root'],
        graph = root['graph'],
        lot,
        tmp;
    var vertex = graph[soul] ?? empty,
        was = Gun.state.is_(vertex, key, 1),
        known = vertex[key];
    var DBG = ctx['DBG'];
    if (tmp = kDebugMode) {
      if (!graph[soul] || !known) {
        tmp['has'] = (tmp['has'] ?? 0) + 1;
      }
    }
    var now = State(), u;
    if (state > now) {
      setTimeout(() {
        ham(val, key, soul, state, msg);
      }, (tmp = state - now) > MD ? MD : tmp); // Max Defer 32bit. :(
      if (kDebugMode) {
        print(
            "${((DBG ?? ctx)['Hf'] = DateTime.now().millisecondsSinceEpoch)}, $tmp future");
      }
      return null;
    }
    // TODO: Improve in future. // for AXE this would reduce rebroadcast, but GUN does it on message forwarding.
    // TODO: TURNS OUT CACHE MISS WAS NOT NEEDED FOR NEW CHAINS ANYMORE!!! DANGER DANGER DANGER, ALWAYS RETURN! (or am I missing something?)
    if (state < was) {
      /*old;*/
      return null;
      // if (true || !ctx['miss']) {
      //   return null;
      // }
    } // but some chains have a cache miss that need to re-fire.
    // TODO: BUG? Can this be used for cache miss as well?
    // TODO: Yes this was a bug, need to check cache miss for RAD tests,
    //  TODO: but should we care about the faith check now? Probably not.
    if (ctx['faith'] == null) {
      if (state == was && (val == known || L(val) <= L(known))) {
        /*console.log("same");*/ /*same;*/
        if (!ctx['miss']) {
          return null;
        }
      } // same
    }

    // TODO: 'forget' feature in SEA tied to this, bad approach, but hacked in for now. Any changes here must update there.
    ctx['stun']++;
    var aid = msg['#'] + ctx['all']++,
        id = {
          'toString': () {
            return aid;
          },
          '_': ctx
        };
    id['toJSON'] = id
        .toString; // this *trick* makes it compatible between old & new versions.
    root.dup['track'](id)['#'] =
        msg['#']; // fixes new OK acks for RPC like RTC.
    DBG ? (DBG['ph'] = DBG.ph ?? DateTime.now().millisecondsSinceEpoch) : null;
    root.on('put', {
      '#': id,
      '@': msg['@'],
      'put': {'#': soul, '.': key, ':': val, '>': state},
      'ok': msg.ok,
      '_': ctx
    });
  }

  mapFn([msg]) {
    var DBG;
    if (DBG = (msg['_'] ?? {})['DBG']) {
      DBG['pa'] = DateTime.now().millisecondsSinceEpoch;
      DBG['pm'] = DBG.pm ?? DateTime.now().millisecondsSinceEpoch;
    }

    var eve = this,
        root = eve['as'],
        graph = root['graph'],
        ctx = msg['_'],
        put = msg['put'],
        soul = put['#'],
        key = put['.'],
        val = put[':'],
        state = put['>'],
        id = msg['#'],
        tmp;

    if ((tmp = ctx.msg) && (tmp = tmp.put) && (tmp = tmp[soul])) {
      Gun.state.ify(tmp, key, state, val, soul);
    } // necessary! or else out messages do not get SEA transforms.
    //var bytes = ((graph[soul]||'')[key]||'').length||1;
    graph[soul] = Gun.state.ify(graph[soul], key, state, val, soul);
    if (tmp = (root['next'] ?? {})[soul]) {
      //tmp.bytes = (tmp.bytes||0) + ((val||'').length||1) - bytes;
      //if(tmp.bytes > 2**13){ Gun.log.once('byte-limit', "Note: In the future, GUN peers will enforce a ~4KB query limit. Please see https://gun.eco/docs/Page") }
      tmp.on('in', msg);
    }
    fire(ctx);
    eve['to'].next(msg);
  }

  fire([ctx, msg]) {
    var root;
    if (ctx['stop']) {
      return null;
    }
    // TODO: 'forget' feature in SEA tied to this, bad approach, but hacked in for now. Any changes here must update there.
    if (ctx['err'] == null && 0 < --ctx['stun']) {
      return null;
    }
    ctx['stop'] = true;
    if (!(root = ctx['root'])) {
      return null;
    }
    var tmp = ctx['match'];
    tmp['end'] = 1;
    if (tmp == root['hatch']) {
      if (!(tmp = ctx['latch']) || tmp['end']) {
        (root as Map).remove('hatch');
      } else {
        root['hatch'] = tmp;
      }
    }
    ctx['hatch'] != null
        ? ctx['hatch']()
        : null; // TODO: rename/rework how put & this interact.
    setTimeout.each(ctx.match, (cb) {
      cb ?? cb();
    });
    if (!(msg = ctx['msg']) || ctx['err'] || msg['err']) {
      return null;
    }
    msg['out'] = universe;
    ctx['root'].on('out', msg);

    CF(); // courtesy check;
  }

  ack([msg]) {
    // aggregate ACKs.
    var id = msg['@'] ?? {}, ctx, ok, tmp;
    if (!(ctx = id['_'])) {
      var dup = msg['\$'];
      (dup = dup['_']) && (dup = dup['root']) && (dup = dup['dup']);
      if (!(dup = dup['check'](id))) {
        return null;
      }
      msg['@'] = dup['#'] ??
          msg['@']; // This doesn't do anything anymore, backtrack it to something else?
      return null;
    }
    ctx['acks'] = (ctx['acks'] ?? 0) + 1;
    if (ctx['err'] = msg['err']) {
      msg['@'] = ctx['#'];
      // TODO: BUG? How it skips/stops propagation of msg if any 1 item is error, this would assume a whole batch/resync has same malicious intent.
      fire(ctx);
    }

    ctx['ok'] = msg['ok'] ?? ctx['ok'];
    // handle synchronous acks. NOTE: If a storage peer ACKs synchronously then
    // the PUT loop has not even counted up how many items need to be processed,
    // so ctx.STOP flags this and adds only 1 callback to the end of the PUT loop.
    if (!ctx['stop'] && ctx['crack'] == null) {
      ctx['crack'] = ctx['match'] &&
          ctx['match'].push(() {
            back(ctx);
          });
    }
    back(ctx);
  }

  back([ctx]) {
    if (ctx == null || ctx['root'] == null) {
      return null;
    }
    if (ctx['stun'] || ctx['acks'] != ctx['all']) {
      return null;
    }
    ctx['root'].on('in', {
      '@': ctx['#'],
      'err': ctx['err'],
      'ok': ctx['err'] ? u : ctx['ok'] ?? {'': 1}
    });
  }

  onGet([msg, gun]) {
    var root = gun['_'],
        get = msg['get'],
        soul = get['#'],
        node = root['graph'][soul],
        has = get['.'];
    var next = root['next'] ?? (root['next'] = {}), at = next[soul];

    // queue concurrent GETs?
    // TODO: consider tagging original message into dup for DAM.
    // TODO: ^ above? In chat app, 12 messages resulted in same peer asking for `#user.pub` 12 times. (same with #user GET too, yipes!) // DAM note: This also resulted in 12 replies from 1 peer which all had same ##hash but none of them deduped because each get was different.
    // TODO: Moving quick hacks fixing these things to axe for now.
    // TODO: a lot of GET #foo then GET #foo."" happening, why?
    // TODO: DAM's ## hash check, on same get ACK, producing multiple replies still, maybe JSON vs YSON?
    // TMP note for now: viMZq1slG was chat LEX query #.
    /*if(gun !== (tmp = msg.$) && (tmp = (tmp||'')._)){
			if(tmp.Q){ tmp.Q[msg['#']] = ''; return } // chain does not need to ask for it again.
			tmp.Q = {};
		}*/
    /*if(u === has){
			if(at.Q){
				//at.Q[msg['#']] = '';
				//return;
			}
			at.Q = {};
		}*/

    var ctx = msg['_'] ?? {}, DBG = ctx['DBG'] = msg['DBG'];

    DBG ? (DBG['g'] = DateTime.now().millisecondsSinceEpoch) : null;

    if (node == null) {
      return root.on('get', msg);
    }
    if (has) {
      if (has is! String || u == node[has]) {
        return root.on('get', msg);
      }
      node = Gun.state.ify({}, has, Gun.state.is_(node, has), node[has], soul);
      // If we have a key in-memory, do we really need to fetch?
      // Maybe... in case the in-memory key we have is a local write
      // we still need to trigger a pull/merge from peers.
    }

    //Gun.window? Gun.obj.copy(node) : node; // HNPERF: If !browser bump Performance?
    // Is this too dangerous to reference root graph?
    // Copy / shallow copy too expensive for big nodes. Gun.obj.to(node);
    // 1 layer deep copy // Gun.obj.copy(node); // too slow on big nodes

    node ? onAck(msg, node) : null;
    root.on('get', msg); // send GET to storage adapters.
  }

  onAck([msg, node]) {
    var S = DateTime.now().millisecondsSinceEpoch,
        ctx = msg['_'] ?? {},
        DBG = ctx['DBG'] = msg['DBG'];

    var to = msg['#'],
        id = ''.random(9),
        keys = ((node ?? {}) as Map).keys.toList(),
        soul = ((node ?? {})['_'] ?? {})['#'];
    keys.sort();
    var kl = keys.length,
        j = 0,
        root = msg['\$']['_']['root'],
        F = (node == root.graph[soul]);

    if (kDebugMode) {
      print(
          "$S, ${((DBG ?? ctx)['gk'] = DateTime.now().millisecondsSinceEpoch) - S}, put keys");
    }

    // PERF: Consider commenting this out to force disk-only reads for perf testing?
    // TODO: .keys( is slow

    go() {
      S = DateTime.now().millisecondsSinceEpoch;

      var i = 0, k, put = {}, tmp;
      while (i < 9 && (k = keys[i++])) {
        Gun.state.ify(put, k, Gun.state.is_(node, k), node[k], soul);
      }
      keys = keys.sublist(i);
      (tmp = {})[soul] = put;
      put = tmp;
      var faith;
      // HNPERF: We're testing performance improvement by skipping going through security again,
      // but this should be audited.
      if (F) {
        faith = () {};
        faith.ram = faith.faith = true;
      }

      tmp = keys.length;

      if (kDebugMode) {
        print(
            "$S, ${-(S - (S = DateTime.now().millisecondsSinceEpoch))}, got copied some");
      }

      DBG ? (DBG['ga'] = DateTime.now().millisecondsSinceEpoch) : null;

      root.on('in', {
        '@': to,
        '#': id,
        'put': put,
        '%': (tmp ? (id = ''.random(9)) : u),
        '\$': root['\$'],
        '_': faith,
        DBG: DBG
      });
      if (kDebugMode) {
        print("$S, ${DateTime.now().millisecondsSinceEpoch - S}, got in");
      }

      if (!tmp) {
        return null;
      }
      setTimeout.turn(go);
    }

    node != null ? go() : null;

    // TODO: I don't think I like this, the default lS adapter uses this but "not found" is a sensitive issue,
    // TODO: so should probably be handled more carefully/individually.
    if (node == null) {
      root.on('in', {'@': msg['#']});
    }
  }

  opt(opt) {
    opt = opt ?? {};
    var gun = this, at = gun['_'], tmp = opt['peers'] ?? opt;
    if (!isMap(opt)) {
      opt = {};
    }
    if (!isMap(at['opt'])) {
      at['opt'] = opt;
    }

    if (tmp is String) {
      tmp = [tmp];
    }

    if (!isMap(at['opt']['peers'])) {
      at['opt']['peers'] = {};
    }

    if(tmp is List){
      opt['peers'] = {};
      for (var url in tmp) {
        var p = {};
        p['id'] = p['url'] = url;
        opt['peers'][url] = at['opt']['peers'][url] = at['opt']['peers'][url] ?? p;
      }
    }

    each(k) {
      var v = opt[k];
      if((opt.containsKey(k)) || v is String){
        opt[k] = v;
        return;
      }
      if(v != null && v is! Map && v is! List){
        return;
      }
      obj_each(v, each);
    }

    obj_each((opt as Map), each);
    at['opt']['from'] = opt;
    Gun.on('opt', at);
    at['opt']['uuid'] = at['opt']['uuid'] ?? generateMessageId;
    return gun;
  }
}
