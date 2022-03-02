import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lmcganak/firebase/setLocation.dart';
import 'package:lmcganak/notification.dart' as notif;
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase/authentication.dart';
import 'firebase/signInAuth.dart';
import 'package:intl/intl.dart';


const fetchBackground = "fetchBackground";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('firebase samma aayo');
    Firebase.initializeApp().then((va) {
      FirebaseAuth auth= FirebaseAuth.instance;
      String? uid = auth.currentUser?.uid.toString();
      CollectionReference userRef = FirebaseFirestore.instance.collection(uid!);
      print(userLocation.longitude);
      print(uid);
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(now);
      String formattedTime = DateFormat.Hms().format(now);
      userRef.doc(formatted).collection(formattedTime).add({'time_stamp':formattedTime, 'lat': userLocation.latitude, 'long': userLocation.longitude});
      return;
    });
    switch (task) {
      case "fetchBackground":
        Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        print('firebase samma aayo');
        Firebase.initializeApp().then((va) {
          FirebaseAuth auth= FirebaseAuth.instance;
          String? uid = auth.currentUser?.uid.toString();
          CollectionReference userRef = FirebaseFirestore.instance.collection(uid!);
          print(userLocation.longitude);
          print(uid);
          final DateTime now = DateTime.now();
          
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          final String formatted = formatter.format(now);
          String formattedTime = DateFormat.Hms().format(now);
          userRef.doc(formatted).collection(formattedTime).add({'time_stamp':formattedTime, 'lat': userLocation.latitude, 'long': userLocation.longitude});
          return;
        });
        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();


  @override
  void initState() {
    super.initState();
    // this._determinePosition();
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    Workmanager().registerPeriodicTask(
      "1",
      "fetchBackground",
      frequency: Duration(seconds: 15),
    );
  }


  @override
  Widget build(BuildContext context) {


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
                  return const Center(
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