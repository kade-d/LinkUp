import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:techpointchallenge/model/schedule.dart';

class User {

  Schedule schedule = Schedule.fromNothing();
  String bio;
  String email;
  String firebaseId;
  String jobTitle;
  String name;
  String orgId;
  String photoUrl;
  String bannerPhotoUrl;
  Status status;
  HashMap<String, String> surveyResponses = HashMap();

  User.fromNothing(){
    status = Status.fromString("Away");
    bannerPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/techpoint-sos-challenge.appspot.com/o/hosting%2FLinkedin-Backgrounds-20-1400-x-425.jpg?alt=media&token=83b3896b-64ba-47dd-939f-f1fa91f344d3";
  }

  User.fromJson(dynamic json, String uid){
    assert (json != null);

    name = json['personal_info']['name'];
    email = json['personal_info']['email'];
    bio = json['personal_info']['bio'];
    photoUrl = json['personal_info']['photo_url'];
    bannerPhotoUrl = json['personal_info']['banner_photo_url'];
    jobTitle = json['personal_info']['job_title'];
    orgId = json['org_id'];
    schedule = Schedule.fromJson(json['schedule']);
    firebaseId = uid;
    status = Status.fromString(json['status'] ?? "Offline");
    surveyResponses = HashMap.from(json['survey_responses']);
  }

  dynamic toJson(){
    return Map.of(
      {
        "personal_info": {
          "name" : name,
          "email" : email,
          "bio" : bio,
          "photo_url" : photoUrl,
          "banner_photo_url" : bannerPhotoUrl,
          "job_title" : jobTitle
        },
        "status" : status.text,
        "schedule" : schedule.toJson(),
        "org_id" : orgId,
        "survey_responses" : surveyResponses
      }
    );
  }

}

class Status {

  String text;

  Status.fromString(this.text);

  Color toColor(){
    switch (text){
      case "Available":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

}