var onto = {};

typedef ontoFnType = dynamic Function([dynamic, dynamic, dynamic]);

ontoFn([tag, arg, as]) {
  if (tag == null) {
    return {'to': ontoFn};
  }
  var u = arg is Function;
  var f = tag = (tag ?? (tag = {}))[tag] ??
      (tag[tag] = {
        tag: tag,
        'to': (onto['_'] = {
          'next': (arg) {
            var tmp;
            if ((tmp = tag[tag]['to'])) {
              tmp['next'](arg);
            }
          },
        })
      });
  if (f != null) {
    var be = {'back': tag['last'] ?? tag};
    be['back']['to'] = be;
    be['next'] = arg;
    be['the'] = tag;
    be['as'] = as;
    be['to'] = onto['_'];
    be['on'] = ontoFn;
    be = {
      ...be,
      'off': onto['off'] ??
          (onto['off'] = () {
            if (arg == onto['_']['next']) {
              return true;
            }
            if (be == tag['last']) {
              tag['last'] = be['back'];
            }
            onto['_']['back'] = be['back'];
            be['next'] = onto['_']['next'];
            be['back']['to'] = onto['_'];
            if (be['the']['last'] == be['the']) {
              // TODO: From where `on` came from
              tag.remove(tag.tag);
            }
          })
    };
    return tag['last'] = be;
  }
  if ((tag = tag['to']) && u != arg) {
    tag['next'](arg);
  }
  return tag;
}