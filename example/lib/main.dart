import 'package:flutter/material.dart';
import 'package:flutter_gundb/flutter_gundb.dart';

void main() async {

  await initializeFlutterGun();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String gundbText = '';
  TextEditingController gunDBTestingController = TextEditingController();
  late FlutterGunLink copy;

  @override
  void initState() {
    super.initState();
    FlutterGunOptions flutterGunOptions = FlutterGunOptions();
    const isLocal = true;
    flutterGunOptions.peers = [ isLocal ? 'ws://localhost:8080/gun' : 'wss://gun-manhattan.herokuapp.com/gun'];
    final chainGunClient = FlutterGunSeaClient(flutterGunOptions: flutterGunOptions, registerStorage: true);

    copy = chainGunClient.get('filegot2');

    final pasteJust = copy.get('paste').get('just');
    final doingMaybe = copy.get('doing');

    pasteJust.on((a, [b, c]) {
      print('pasteJust:::: $a');
      setState(() {
        if (a != null) {
          gundbText = a;
          if (gundbText != gunDBTestingController.text) {
            gunDBTestingController.text = gundbText;
          }
        }
      });
    });

    doingMaybe.on((a, [b, c]) async {
      print('doingMaybe:: $a');

      /** Below is just an basic example **/

      final pairVar = await pair();
      var enc = await encrypt('hello self', pairVar);
      print('encrypt:: $enc');
      var data = await sign(enc, pairVar);
      print('signed:: $data');

      var msg = await verify(data, pairVar);
      print('verify:: $msg');
      var dec = await decrypt(msg, pairVar);
      var proof = await work(dec, pairVar);
      var check = await work('hello self', pairVar);
      print('Decrypt MSG:: $dec');
      print('Check:: ${proof == check} -- $proof -- $check');

      /** Below code is for the sharing data encrypted between two users **/

      var alice = await pair();
      var bob = await pair();
      var shared = await secret(bob.epub, alice);
      print('shared secret:: $shared');
      var shared_enc = await encrypt('shared data', shared);
      print('shared_enc :: $shared_enc');

      var decryptKey = await secret(alice.epub, bob);
      print('decryptKey:: $decryptKey');

      var dec2 = await decrypt(shared_enc, decryptKey);
      print('Decrypted Data:: $dec2');

      /** Below Example code not yet done, Currently implementing it  **/

      // var certificate = await certify(alice.pub, ["^AliceOnly.*"], bob);

      // final user = await chainGunClient.user().create(alice.pub, alice.epriv);

      // print('Got User:: ${jsonEncode(user)}');

      // await chainGunClient.user().auth(alias: alice.pub, password: alice.epriv);

      // final testKey = chainGunClient.get('~${bob.pub}').get('AliceOnly').get('do-not-tell-anyone');
      //
      // testKey.put({ 'data': shared_enc, 'cert': certificate });
      //
      // testKey.once((a, [b, c]) {
      //   print('Getting Once the data:: $a, $b, $c');
      // });

      if (a != null && a['maybe'] == false) {
        copy.put({
          'doing': {
            'maybe': true
          }
        });
      }
    });

    copy.on((a, [b, c]) {
      print('ASD:: $a');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              gundbText,
              style: Theme.of(context).textTheme.headline4,
            ),
            TextFormField(
              controller: gunDBTestingController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter text to display",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(),
                ),
                //fillColor: Colors.green
              ),
              onChanged: (val) {
                copy.put({ 'paste': {
                    'just': val,
                    'more': { 'no': 2 }
                  },
                  'doing': {
                    'maybe': false
                  }
                });
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
