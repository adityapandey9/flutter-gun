
import 'package:flutter_gundb/shim_utils.dart';

import 'gun.dart';

typedef askType = dynamic Function([dynamic, dynamic]);

askFn([cb, as]) {
  // TODO: Logic not clear
  // if(!this.on){ return null; }
  // TODO: this.opt is not clear where did it came from
  var lack = 9000;
  if (cb is! Function) {
    if (cb == null) {
      return null;
    }
    var id = cb['#'] ?? cb;
    // TODO: check here as well
    // var tmp = (tag ?? '')[id];
    var tmp;
    if(as){
      // TODO: implement `on` function and import
      tmp = Gun.on(id, as);
      Future.delayed(Duration(milliseconds: lack), (){ tmp.off(); });
    }
    return true;
  }
  var id = as != null ? as['#'] : ''.random(9);
  if(cb == null){ return id; }
  // TODO: implement `on` function and import
  var to = Gun.on(id, cb, as);
  Future.delayed(Duration(milliseconds: lack), (){
    to.off();
    to.next({'err': "Error: No ACK yet.", 'lack': true});
  });
  return id;
}