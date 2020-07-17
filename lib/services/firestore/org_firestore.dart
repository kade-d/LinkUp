import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';

class OrgFireStore {

  static Stream<Organization> getOrganization(String userEmail, String orgId) {

    return Firestore.instance.collection('organizations').document(orgId).snapshots()
      .map((snapshot) => Organization.fromJson(snapshot.data))
      .handleError((e) => print("Get org error: " + e.toString()));

  }

  static Future<void> createOrganization(Organization org, User owner) async {
    await Firestore.instance.collection('organizations').document(org.ownerId).setData(
      org.toJson()
    ).catchError((e){
      print("Create org error: " + e.toString());
    });

    owner.orgId = owner.firebaseId;

    await UserFirestore.updateUser(owner);

  }

  static Future<void> updateOrg(Organization org) async {
    await Firestore.instance.collection('organizations').document(org.ownerId).setData(org.toJson(), merge: true);
  }

  static Stream<List<Organization>> getInvitedOrganizations(User user){

    print("Getting invs " + user.email);

    return Firestore.instance.collection("organizations").where("invited_user_emails", arrayContains: user.email).snapshots()
      .map((snapshots) => snapshots.documents.map((snapshot) => Organization.fromJson(snapshot.data)).toList())
      .handleError((e) => print("Get inv orgs error: " + e.toString()));

  }

}
