class Organization {

  String name;
  String photoUrl;

  String ownerId;
  List<String> invitedUserEmails;

  Organization(this.name, this.photoUrl, this.ownerId, this.invitedUserEmails);

  Organization.fromNothing();

  Organization.fromJson(dynamic json){
    assert (json != null);

    name = json['name'];
    photoUrl = json['photo_url'];
    ownerId = json['owner_id'];
    invitedUserEmails = json['invited_user_emails'].cast<String>().toList();
  }

  dynamic toJson(){
    return Map.of(
      {
        "name" : name,
        "owner_id" : ownerId,
        "photo_url" : photoUrl,
        "invited_user_emails" : invitedUserEmails
      }
    );
  }

}
