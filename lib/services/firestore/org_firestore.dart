
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:techpointchallenge/model/organization.dart';

class OrgFireStore {

  static Future<Organization> getOrganizationFromUser(FirebaseUser user) async {
    String orgId = await _getOrganizationIdForUser(user);
    if(orgId.length > 0){
      return await _getOrganizationFromId(orgId);
    } else {
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
            (snapshot.data['user_ids'] as List).cast<String>()
          );
        }
      })
    .catchError((e){
      print("Get org from id error: " + e.toString());
    });
    return org;
  }

  static Future<Organization> createOrganization(Organization org) async {
    await Firestore.instance.collection('organizations').document(org.ownerId).setData(
      {
        "name": org.name,
        "owner_id": org.ownerId,
        "photo_url": org.photoUrl,
        "user_ids": org.userIds
      }
    ).catchError((e){
      print("Create org error: " + e.toString());
    });

    updateUsersOrg(org.ownerId, org.ownerId);

    return org;
  }

  static Future<void> updateOrg(Organization org) async {

    await Firestore.instance.collection('organizations').document(org.ownerId).setData({
      "user_ids": org.userIds
    },
    merge: true
    );

  }

  static Future<void> createUser(FirebaseUser user) async {

    await Firestore.instance.collection('users').document(user.uid).setData(
      {
        "name": user.displayName
      },
      merge: true
    );
  }

  static Future<void> updateUsersOrg(String userId, String orgId) async{
    await Firestore.instance.collection('users').document(userId).setData(
      {
        "org_id" : orgId
      },
      merge: true
    );
  }


}
