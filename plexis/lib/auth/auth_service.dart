import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance of app
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // signin
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }

  //signup
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // signout
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  //errors 
}