import 'dart:collection';
import 'dart:developer';

import 'event.dart';

class Schedule {

  List<Event> events;

  Schedule(this.events);

  Schedule.fromJson(List<dynamic> json) {
    events = List();
    if (json != null) {
      for (var event in json) {
        events.add(Event(event['name'], DateTime.parse(event['start_date']),
            DateTime.parse(event['end_date']), event['accepted_user_emails'].cast<String>(), event['invited_user_emails'].cast<String>()));
      }
    } else {
      log("User's schedule could not be converted from json (was null)");
    }
  }

  List<Map<String, Object>> toJson() {
    return events.map((event) {
        return {
          "name": event.name,
          "start_date": event.startDate.toIso8601String(),
          "end_date": event.endDate.toIso8601String(),
          "invited_user_emails" : event.invitedUserEmails,
          "accepted_user_emails" : event.acceptedUserEmails
        };
      }).toList();
  }

  List<Event> getEventsForDay(DateTime date) {
    return events.where((event) {
      bool startEqual = date.year == event.startDate.year &&
          date.month == event.startDate.month &&
          date.day == event.startDate.day;
      bool stopEqual = date.year == event.endDate.year &&
          date.month == event.endDate.month &&
          date.day == event.endDate.day;
      return startEqual && stopEqual;
    }).toList();
  }
}
