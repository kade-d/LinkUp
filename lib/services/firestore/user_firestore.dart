import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:techpointchallenge/model/user.dart';

class UserFirestore {

  static Future<void> createUser(FirebaseUser firebaseUser) async {
    User user = User.fromNothing();
    user.firebaseId = firebaseUser.uid;
    user.email = firebaseUser.email;
    user.photoUrl = firebaseUser.photoUrl;
    user.name = firebaseUser.displayName;

    if (await getUser(firebaseUser.uid) == null) {
      if(user != null){
        await Firestore.instance.collection('users').document(firebaseUser.uid).setData(user.toJson(), merge: true);
      }
    }

  }

  static Future<User> getUser(String userId) async {
    dynamic userJson;
    await Firestore.instance.collection('users').document(userId).get().then(
        (snapshot) {
        if(snapshot.exists && snapshot.data != null){
          userJson = snapshot.data;
        }
      })
      .catchError((e) {
        print("Get user error: " + e.toString());
      }
    );
    return userJson == null ? null : User.fromJson(userJson, userId);
  }

  static Stream<User> getUserAsStream(String userId){

    //TODO func being called too much ?
    return Firestore.instance.collection('users').document(userId).snapshots().map((snapshot){
      return User.fromJson(snapshot.data, userId);
    });
  }

  static Future<List<User>> getUsersForOrg(String orgId, List<String> orgEmails) async {

    List<User> users = List();
    for(int i = 0; i < orgEmails.length; i += 10){
      int chunkEnd = [i+9, orgEmails.length].reduce(min);
      List<User> tempUsers = await Firestore.instance.collection('users')
        .where("personal_info.email", whereIn: orgEmails.sublist(i, chunkEnd))
        .where("org_id", isEqualTo: orgId)
        .getDocuments()
        .then((snapshot) {
          return snapshot.documents.map((document) {
            return User.fromJson(document.data, document.documentID);
          }).toList();
      }).catchError((e) => print("Get users for org error: " + e.toString() + "\nEmails: " + orgEmails.toString()));

      tempUsers.forEach((user) => users.add(user));
    }
    return users;
  }

  static Future<void> updateUser(User user) async {

    await Firestore.instance.collection('users').document(user.firebaseId).setData(
      user.toJson(),
      merge: true)
      .catchError((e) {
        print("Update user error: " + e.toString());
      }
    );

  }
}