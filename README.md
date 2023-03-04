## Flutter GunDB

This library is a port of GunDB js for the Dart and Flutter. P2P encrypted Communication between multiple users.
Flutter GUN is an ecosystem of tools that let you build community run and encrypted applications - like an Open Source Firebase or a Decentralized Dropbox.

`Note: Some APIs like certify and user, not implemented completely (Trying to do so ;) )`
## Features

1. Multiplayer by default with realtime p2p state synchronization!
2. Graph data lets you use key/value, tables, documents, videos, & more!
3. Local-first, offline, and decentralized with end-to-end encryption.

Decentralized alternatives to Zoom, Reddit, Instagram, Slack, YouTube, Stripe, Wikipedia, Facebook Horizon and
more have already pushed terabytes of daily P2P traffic on GUN.

## Getting started

Add library to your app.

```
flutter pub add flutter_gundb
```

or

```yaml
.....
dependencies:
  flutter_gundb: ^0.0.1
....
```

## Usage

Short example is below. Added longer examples to `/example` folder.

```dart
import 'package:flutter_gundb/flutter_gundb.dart';

void main() {
    final chainGunClient = FlutterGunSeaClient();
    
    final getAditya = gun.get('aditya');
    getAditya.put({
      name: "Aditya Kumar Pandey",
      email: "janatig@janatig.com",
    });
    getAditya.on((a, [b, c]) {
      print('Getting Value:: $a');
    });
}

```

## Additional information

Some APIs like `certify` and `user`. If anyone wants to help, kindly send a PR. I would appreciate it. Thank you in advance :)

