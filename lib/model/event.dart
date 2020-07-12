class Event {

  int id;
  String name;
  DateTime startDate;
  DateTime endDate;
  List<String> acceptedUserEmails;
  List<String> invitedUserEmails;

  Event(this.name, this.startDate, this.endDate, this.acceptedUserEmails,
    this.invitedUserEmails);

  Event.fromNothing(){
    this.acceptedUserEmails = List();
    this.invitedUserEmails = List();
  }

}