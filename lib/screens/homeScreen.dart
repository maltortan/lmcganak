import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lmcganak/firebase/authentication.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Home');

    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: (){
            AuthenticationService(FirebaseAuth.instance).signOut();
          },
          child: Text(
              'Now Minimize App',
            style: TextStyle(
              fontSize: 40
            ),
          ),
        ),
      ),
    );
  }
}
