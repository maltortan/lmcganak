import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class SetLocation{
  Position userLocation;

  SetLocation(this.userLocation);
  setLocation(){
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
  }
}