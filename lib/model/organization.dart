class Organization {

  String name;
  String photoUrl;

  String ownerId;
  List<String> userIds;

  Organization(this.name, this.photoUrl, this.ownerId, this.userIds);

  Organization.fromNothing();

}