import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/model/schedule.dart';

class ScheduleFirestore {

  static Future<void> addScheduleItem(Event event, String userId) async {

    Schedule schedule = await getSchedule(userId);
    schedule.events.add(event);

    await Firestore.instance.collection('users').document(userId).setData(
     {
       "schedule": schedule.toJson()
     },
      merge: true)
      .catchError((e) {
        print("Add schedule item error: " + e.toString());
      }
    );
  }

  static Future<Schedule> getSchedule(String userId) async {
    List<dynamic> scheduleJson = List();
    await Firestore.instance.collection('users').document(userId).get().then(
      (snapshot) {
        if(snapshot.exists && snapshot.data.containsKey('schedule')){
          scheduleJson = snapshot.data['schedule'];
        }
      })
      .catchError((e) {
        print("Get schedule error: " + e.toString());
      }
    );
    return Schedule.fromJson(scheduleJson);
  }

  static Stream<Schedule> getScheduleAsStream(String userId){

    var stream = Firestore.instance.collection('users').document(userId).snapshots().map((snapshot){
      return Schedule.fromJson(snapshot.data['schedule']);
    });

    return stream;

  }

}
