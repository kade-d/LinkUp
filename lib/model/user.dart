import 'package:techpointchallenge/model/recognition.dart';
import 'package:techpointchallenge/model/schedule.dart';

class User {

  Schedule schedule;
  String bio;
  String email;
  String firebaseId;
  String jobTitle;
  String name;
  String orgId;
  String photoUrl;

  User(this.schedule, this.bio, this.email, this.firebaseId, this.jobTitle,
    this.name, this.orgId, this.photoUrl);

  User.fromNothing();

  User.fromJson(dynamic json, String uid){
    assert (json != null);

    name = json['personal_info']['name'];
    email = json['personal_info']['email'];
    bio = json['personal_info']['bio'];
    photoUrl = json['personal_info']['photo_url'];
    jobTitle = json['personal_info']['job_title'];
    orgId = json['org_id'];
    schedule = Schedule.fromJson(json['schedule']);
    firebaseId = uid;
  }

  dynamic toJson(){
    return Map.of(
      {
        "personal_info": {
          "name" : name,
          "email" : email,
          "bio" : bio,
          "photo_url" : photoUrl,
          "job_title" : jobTitle
        },
        "schedule" : schedule.toJson(),
        "org_id" : orgId
      }
    );
  }

}