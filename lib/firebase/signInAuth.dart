
import 'package:firebase_auth/firebase_auth.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/homeScreen.dart';
import '../screens/signIn.dart';
import '../screens/signUp.dart';



class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomeScreen();
    }
    return LoginScreen();
  }
}

class SignupWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return HomeScreen();
    }
    return SignupScreen();
  }
}
