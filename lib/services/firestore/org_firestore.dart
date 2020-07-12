import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';

class OrgFireStore {

  static Future<Organization> getOrganizationFromUser(FirebaseUser user) async {
    String orgId = await _getOrganizationIdForUser(user);
    if(orgId != null && orgId.length > 0){
      print("Getting org from id");
      return await _getOrganizationFromId(orgId);
    } else {
      print("No org id");
      return Organization.fromNothing();
    }
  }

  static Future<String> _getOrganizationIdForUser(FirebaseUser user) async {
    String orgId;
    await Firestore.instance.collection('users').document(user.uid).get()
      .then((snapshot){
        if(snapshot.data != null && snapshot.data.containsKey('org_id')){
          orgId = snapshot.data['org_id'];
        }
      }
    ).catchError((e){
      print("Get org id for user error: " + e.toString());
    });
    return orgId;
  }

  static Future<Organization> _getOrganizationFromId(String orgId) async {
    Organization org;
    await Firestore.instance.collection('organizations').document(orgId).get()
      .then((snapshot){
      if(snapshot.exists){
        org = Organization(
          snapshot.data['name'],
          snapshot.data['photo_url'],
          orgId,
          (snapshot.data['user_emails'] as List).cast<String>()
        );
      }
    })
      .catchError((e){
      print("Get org from id error: " + e.toString());
    });
    return org;
  }

  static Future<Organization> createOrganization(Organization org, User owner) async {
    await Firestore.instance.collection('organizations').document(org.ownerId).setData(
      {
        "name": org.name,
        "owner_id": org.ownerId,
        "photo_url": org.photoUrl,
        "user_emails": org.userEmails
      }
    ).catchError((e){
      print("Create org error: " + e.toString());
    });

    owner.orgId = owner.firebaseId;

    await UserFirestore.updateUser(owner);

    return org;
  }

  static Future<void> updateOrg(Organization org) async {
    await Firestore.instance.collection('organizations').document(org.ownerId).setData({
      "user_emails": org.userEmails,
      "photo_url": org.photoUrl,
    },
    merge: true
    );
  }

  static Future<List<String>> getCoworkerEmails(String orgId) async {

    List<String> emails = List();
    await Firestore.instance.collection('organizations').document(orgId).get()
      .then((snapshot){
        emails = snapshot.data["user_emails"].cast<String>();
    })
      .catchError((e){
      print("Get coworker emails error: " + e.toString());
    });
    return emails;
  }

}
