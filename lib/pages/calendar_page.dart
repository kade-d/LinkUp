import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/schedule.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/calendar_helper.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/services/duration_helper.dart';
import 'package:techpointchallenge/services/firestore/org_firestore.dart';
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

  bool addingEvent = false;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<Authentication>(context).firebaseUser;

    DateFormat formatter = DateFormat('yMMMM');

    return Consumer<User>(
      builder: (context, user, child) {
        if (user != null) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () => setState(() {
                      viewDate = viewDate.subtract(Duration(
                          days: calendarHelper.getDaysInCurrentMonth(
                              now.year, now.month)));
                    }),
                  ),
                  Text(
                    viewDate == now
                        ? formatter.format(now)
                        : formatter.format(viewDate),
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () => setState(() {
                      viewDate = viewDate.add(Duration(
                          days: calendarHelper.getDaysInCurrentMonth(
                              now.year, now.month)));
                    }),
                  ),
                ],
              ),
              GridView.count(
                childAspectRatio: 1.5,
                crossAxisCount: 7,
                primary: false,
                shrinkWrap: true,
                children: viewDate == now
                    ? getMonthGridViewChildren(user, now, true, user.schedule)
                    : getMonthGridViewChildren(
                        user, viewDate, false, user.schedule),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> getMonthGridViewChildren(
      User user, DateTime selectedMonth, bool isCurrent, Schedule schedule) {
    List<Widget> children = List();

    for (int x = 1; x <= calendarHelper.getDaysInCurrentMonth(selectedMonth.year, selectedMonth.month); x++) {
      DateTime childDate = DateTime(selectedMonth.year, selectedMonth.month, x);

      List<Event> childDateEvents = schedule.getEventsForDay(childDate);

      children.add(Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => showDialog<void>(
              context: context,
              builder: (context) {
                return DayDialog(schedule, childDate, user);
              }),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5),
                child: Text(x.toString()),
              ),
              x == selectedMonth.day && isCurrent
                  ? Center(
                      child: Icon(
                        Icons.star,
                        color: Colors.blue,
                      ),
                    )
                  : Container(),
              childDateEvents.length == 0
                  ? Container()
                  : Flexible(
                      child: Center(
                          child: AutoSizeText(
                        childDateEvents.length.toString() + " Event(s)",
                        maxLines: 1,
                      )),
                    )
            ],
          ),
        ),
      ));
    }
    return children;
  }
}

class DayDialog extends StatefulWidget {
  final Schedule schedule;
  final DateTime selectedDate;
  final User user;

  DayDialog(this.schedule, this.selectedDate, this.user);

  @override
  _DayDialogState createState() => _DayDialogState();
}

class _DayDialogState extends State<DayDialog> {
  bool addEventMode = false;
  bool addingCoworker = false;

  Event event = Event.fromNothing();

  @override
  Widget build(BuildContext context) {
    event.startDate = widget.selectedDate;

    GlobalKey<FormState> formKey = GlobalKey();

    var formatter = DateFormat(DateFormat.YEAR_MONTH_DAY);

    List<Event> eventList =
        widget.schedule.getEventsForDay(widget.selectedDate);

    return AlertDialog(
      title: Text(formatter.format(widget.selectedDate)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            addEventMode
                ? Column(
                    children: [
                      addingCoworker
                          ? Container(
                              constraints: BoxConstraints.tight(
                                  MediaQuery.of(context).size * .33),
                              child: FutureBuilder<List<String>>(
                                  future: OrgFireStore.getCoworkerEmails(
                                      widget.user.orgId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          String coworkerEmail =
                                              snapshot.data[index];
                                          return ListTile(
                                            title: Text(coworkerEmail),
                                            trailing: event.invitedUserEmails
                                                    .contains(coworkerEmail)
                                                ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.check, color: Colors.green,),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: IconButton(
                                                        splashRadius: 16,
                                                        icon: Icon(Icons.delete, color: Colors.red,),
                                                        onPressed: () => setState(() => event.invitedUserEmails.remove(coworkerEmail)),
                                                      ),
                                                    )
                                                  ],
                                                )
                                                : RaisedButton(
                                                    child: Text("Add"),
                                                    onPressed: () => setState(() => event.invitedUserEmails.add(coworkerEmail))
                                                  ),
                                          );
                                        },
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }))
                          : Container(),
                      TextFormField(
                        onSaved: (value) => event.name = value,
                        decoration: InputDecoration(labelText: "Title"),
                      ),
                      TextFormField(
                        onSaved: (value) => event.endDate = event.startDate
                            .add(DurationHelper.parseHumanDuration(value)),
                        decoration: InputDecoration(
                            labelText: "Duration (e.g. 15m or 2 hours)"),
                      ),
                    ],
                  )
                : eventList.length == 0
                    ? Center(
                        child: Text("No events for today"),
                      )
                    : Container(
                        constraints: BoxConstraints.tight(
                            MediaQuery.of(context).size * .25),
                        child: EventList(eventList)),
          ],
        ),
      ),
      actions: [
        addEventMode
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        setState(() {
                          addingCoworker = !addingCoworker;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Add coworker"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        formKey.currentState.save();
                        await ScheduleFirestore.addScheduleItem(
                            event, widget.user.firebaseId);
                        Navigator.of(context).pop();
                        setState(() {
                          addEventMode = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Complete"),
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    setState(() {
                      addEventMode = true;
                    });
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
}

class EventList extends StatelessWidget {
  final List<Event> events;
  final bool shrinkWrap;

  EventList(this.events, {this.shrinkWrap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: shrinkWrap ?? true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(events[index].name),
          leading: Text(DateFormat('jm').format(events[index].startDate)),
        );
      },
    );
  }
}
