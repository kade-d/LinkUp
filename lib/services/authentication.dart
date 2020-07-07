import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:techpointchallenge/services/firestore/org_firestore.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';

class Authentication extends ChangeNotifier {

  FirebaseUser firebaseUser;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> initializeCurrentUser() async {

    _firebaseAuth.onAuthStateChanged.listen((user) async {
      if(user != null){
        if(firebaseUser == null){
          firebaseUser = user;
          await UserFirestore.createUser(user);
          notifyListeners();
        }
      }
    });

    firebaseUser = await _firebaseAuth.currentUser();
    if(firebaseUser != null){
      await UserFirestore.createUser(firebaseUser);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signInWithGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;
    } on PlatformException catch(e) {
      log("Caught: $e");
      await signOut();
    }

    notifyListeners();

  }

  Future<void> signInWithEmail(String email, String password, GlobalKey<ScaffoldState> scaffoldKey) async{
    try {
      firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
    } on PlatformException catch(e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message),));
    }

    notifyListeners();

  }

  Future<void> createAndSignInWithEmail(String email, String password, GlobalKey<ScaffoldState> scaffoldKey) async{
    try{
      firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;
    } on PlatformException catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message),));
    }

    notifyListeners();
  }

  Future<void> signOut() async{
    GoogleSignIn _googleSignIn = GoogleSignIn();
    _firebaseAuth.signOut().then((function){
      log("Signed out of firebase" );
    }, onError: (error){
      log("Could not log out of firebase " + error);
    });
    if(await _googleSignIn.isSignedIn()){
      await _googleSignIn.disconnect();
      log("Signed out of google");
    }
    firebaseUser = null;

    notifyListeners();
  }

}