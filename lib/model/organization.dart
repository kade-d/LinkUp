class Organization {

  String name;
  String photoUrl;

  String ownerId;
  List<String> userEmails;

  Organization(this.name, this.photoUrl, this.ownerId, this.userEmails);

  Organization.fromNothing();

}