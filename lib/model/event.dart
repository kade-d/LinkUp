class Event {

  String name;
  DateTime startDate;
  DateTime endDate;
  String creatorId;
  List<String> acceptedUserIds;
  List<String> invitedUserIds;

  Event(this.name, this.startDate, this.endDate);

  Event.fromNothing();

}