import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';

class UserFirestore {

  static Future<void> createUser(FirebaseUser user) async {
    if(await getUser(user.uid) == null) {
      await Firestore.instance.collection('users').document(user.uid).setData(
        {
          "personal_info":  {
            "name" : user.displayName,
            "email" : user.email,
            "photo_url" : user.photoUrl,
            "bio" : null,
            "job_title" : null,
          },
        },
        merge: true
      );
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

  static Stream<List<User>> getUsersForOrg(String orgId, List<String> orgEmails){

    return Firestore.instance.collection('users').where("personal_info.email", whereIn: orgEmails).where("org_id", isEqualTo: orgId).snapshots().map((snapshots) {
      return snapshots.documents.map((snapshot) {
        return User.fromJson(snapshot.data, snapshot.documentID);
      }).toList();
    }).handleError((e) => print("Get users for org error: " + e.toString() + "\nEmails: " + orgEmails.toString()));
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