import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'firebase/authentication.dart';
import 'firebase/signInAuth.dart';
import 'getLocation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
void onIosBackground() {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
}

void onStart() {
  WidgetsFlutterBinding.ensureInitialized();

  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    print('timer');

    determinePosition().then((value) {
      Firebase.initializeApp().then((va) {
        FirebaseAuth auth= FirebaseAuth.instance;
        String? uid = auth.currentUser?.uid.toString();
        CollectionReference userRef = FirebaseFirestore.instance.collection(uid!);
        print(value.latitude);
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        final String formatted = formatter.format(now);
        String formattedTime = DateFormat.Hms().format(now);
        userRef.doc(formatted).collection(formattedTime).add({'time_stamp':formattedTime, 'lat': value.latitude, 'long': value.longitude});
        return;
      });
    });
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.sendData(
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final service = FlutterBackgroundService();
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {

    FlutterBackgroundService()
        .sendData({"action": "setAsBackground"});
    service.start();
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
            context.read<AuthenticationService>().authStateChanges, initialData: null,
          ),
        ],
        child: MaterialApp(

          title: 'Flutter Demo',
          initialRoute: '/',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/login': (context) => FutureBuilder(
              future: _initialization,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('You have an error! ${snapshot.error.toString()}');
                  return const Text('Something went wrong!');
                } else if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return AuthenticationWrapper();
                }
              },
            ),
            // When navigating to the "/second" route, build the SecondScreen widget.
            '/signup': (context) => FutureBuilder(
              future: _initialization,
              builder: (context, snapshot) {
                final data = snapshot.data;

                if (snapshot.hasError) {
                  print('You have an error! ${snapshot.error.toString()}');
                  return Text('Something went wrong!');
                } else {
                  return SignupWrapper();
                }
              },
            ),
            '/': (context) => AuthenticationWrapper(),

          },

        ));
  }
}