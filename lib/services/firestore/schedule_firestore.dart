import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/services/duration_helper.dart';

class ScheduleFirestore {

  static Future<void> addScheduleItem(Event event, String userId) async {

    List<Event> schedule = await getSchedule(userId);
    schedule.add(event);

    await Firestore.instance.collection('users').document(userId).setData(
      {
        "schedule": schedule.map((event){
          return {
            "name" : event.name,
            "start_date" : event.startDate.toIso8601String(),
            "end_date" : event.endDate.toIso8601String()
          };
        })
      }, merge: true)
      .catchError((e) {
        print("Add schedule item error: " + e.toString());
      }
    );
  }

  static Future<List<Event>> getSchedule(String userId) async {
    List<dynamic> scheduleJson = List();
    await Firestore.instance.collection('users').document(userId).get().then(
      (snapshot) {
        if(snapshot.exists && snapshot.data.containsKey('schedule')){
          scheduleJson = snapshot.data['schedule'];
        }
      })
      .catchError((e) {
        print("Add schedule item error: " + e.toString());
      }
    );
    List<Event> schedule = List();

    for(dynamic event in scheduleJson){
      schedule.add(
        Event(
          event['name'],
          DateTime.parse(event['start_date']),
          DateTime.parse(event['end_date'])
        )
      );
    }

    return schedule;
  }

}
