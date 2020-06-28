import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/calendar.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/services/duration_helper.dart';
import 'package:techpointchallenge/services/firestore/schedule_firestore.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CalendarView(),
            )
          ],
        ),
      ),
    );
  }
}

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {

  CalendarHelper calendarHelper = CalendarHelper();
  DateTime now = DateTime.now();
  DateTime viewDate = DateTime.now();
  FirebaseUser user;

  @override
  Widget build(BuildContext context) {

    user = Provider.of<Authentication>(context).firebaseUser;

    DateFormat formatter = DateFormat('yMMMM');

    return FutureBuilder<List<Event>>(
      future: ScheduleFirestore.getSchedule(user.uid),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(child: Icon(Icons.arrow_back), onPressed: () => setState(() {
                    viewDate = viewDate.subtract(Duration(days: calendarHelper.getDaysInCurrentMonth(now.year, now.month)));
                  }),),
                  Text(viewDate == now ? formatter.format(now) : formatter.format(viewDate), style: Theme.of(context).textTheme.headline2,),
                  RaisedButton(child: Icon(Icons.arrow_forward), onPressed: () => setState(() {
                    viewDate = viewDate.add(Duration(days: calendarHelper.getDaysInCurrentMonth(now.year, now.month)));
                  }),),
                ],
              ),
              GridView.count(
                childAspectRatio: 1.5,
                crossAxisCount: 7,
                primary: false,
                shrinkWrap: true,
                children: viewDate == now ? getMonthGridViewChildren(now, true, snapshot.data) : getMonthGridViewChildren(viewDate, false, snapshot.data),
              ),
            ],
          );
        } else if(snapshot.hasError) {
          return Text("Could not load your schedule");
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }

  List<Widget> getMonthGridViewChildren(DateTime selectedMonth, bool isCurrent, List<Event> schedule){
    List<Widget> children = List();
    DateFormat formatter = DateFormat('jm');

    for(int x = 1; x <= calendarHelper.getDaysInCurrentMonth(selectedMonth.year, selectedMonth.month); x++){

      DateTime childDate = DateTime(selectedMonth.year, selectedMonth.month, x);

      List<Event> childDateEvents = schedule.where((event) {
        bool startEqual = childDate.year == event.startDate.year && childDate.month == event.startDate.month && childDate.day == event.startDate.day;
        bool stopEqual = childDate.year == event.endDate.year && childDate.month == event.endDate.month && childDate.day == event.endDate.day;
        return startEqual && stopEqual;
      }).toList();

      children.add(
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => showDateDetails(childDate, user.uid),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(x.toString()),
                ),
                x == selectedMonth.day && isCurrent ? Center(
                  child: Icon(Icons.star, color: Colors.blue,),
                ) : Container(),
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: childDateEvents.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      title: Text(childDateEvents[index].name),
                      leading: Text(formatter.format(childDateEvents[index].startDate)),
                    );
                  },
                )
              ],
            ),
          ),
        ));
    }

    return children;
  }

  void showDateDetails(DateTime selectedDate, String userId){

    GlobalKey<FormState> formKey = GlobalKey();

    Event event = Event.fromNothing();

    event.startDate = selectedDate;

    var formatter = DateFormat(DateFormat.YEAR_MONTH_DAY);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(formatter.format(selectedDate)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onSaved: (value) =>  event.name = value,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                TextFormField(
                  onSaved: (value) =>  event.endDate = event.startDate.add(DurationHelper.parseHumanDuration(value)),
                  decoration: InputDecoration(labelText: "Duration (e.g. 15m or 2 hours)"),
                ),
              ],
            ),
          ),
          actions: [
            Material(
              color: Theme.of(context).buttonColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  formKey.currentState.save();
                  await ScheduleFirestore.addScheduleItem(event, userId);
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Add event"),
                ),
              ),
            )
          ],
        );
      }
    );
  }

}


