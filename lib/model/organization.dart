class Organization {

  String name;
  String photoUrl;
  String bannerPhotoUrl;

  String ownerId;
  List<String> invitedUserEmails;

  Organization.fromNothing();

  Organization.fromJson(dynamic json){
    assert (json != null);

    name = json['name'];
    photoUrl = json['photo_url'];
    ownerId = json['owner_id'];
    invitedUserEmails = json['invited_user_emails'].cast<String>().toList();
    bannerPhotoUrl = json['banner_photo_url'];
  }

  dynamic toJson(){
    return Map.of(
      {
        "name" : name,
        "owner_id" : ownerId,
        "photo_url" : photoUrl,
        "invited_user_emails" : invitedUserEmails,
        "banner_photo_url" : bannerPhotoUrl
      }
    );
  }

}
