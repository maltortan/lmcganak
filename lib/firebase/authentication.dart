import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService{
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> signIn({required String email, required String password}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e){
      return e.message;
    }
    return "Success";
  }

  Future<String?> signUp({required name, required String email, required String password}) async{
    try {
      await   _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      userSetup(name);
    }on FirebaseAuthException catch(e){
      return e.message;
    }
    return "Success";
  }
}

Future<void> userSetup(String name) async{
  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth auth= FirebaseAuth.instance;
  String? uid = auth.currentUser?.uid.toString();
  print(uid);
  print(name);
  print('user setup');
  userRef.doc(uid).set({'displayName':name, 'uid': uid});
  return;
}