import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/schedule.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/calendar_helper.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/services/duration_helper.dart';
import 'package:techpointchallenge/services/firestore/schedule_firestore.dart';
import 'package:techpointchallenge/services/validator.dart';

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

  bool addingEvent = false;

  @override
  Widget build(BuildContext context) {

    DateFormat formatter = DateFormat('yMMMM');

    return Consumer<User>(
      builder: (context, user, child) {
        if (user != null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: Colors.white,
                      shape: CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back),
                      ),
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
                    MaterialButton(
                      shape: CircleBorder(),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward),
                      ),
                      onPressed: () => setState(() {
                        viewDate = viewDate.add(Duration(
                            days: calendarHelper.getDaysInCurrentMonth(
                                now.year, now.month)));
                      }),
                    ),
                  ],
                ),
              ),
              Row(
                children: getDaysOfWeekAbbr(viewDate),
              ),
              GridView.count(
                childAspectRatio: MediaQuery.of(context).size.aspectRatio * .9,
                crossAxisCount: 7,
                primary: false,
                shrinkWrap: true,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                children: viewDate == now
                    ? getMonthGridViewChildren(user, now, true, user.schedule)
                    : getMonthGridViewChildren(user, viewDate, false, user.schedule),
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

  List<Widget> getDaysOfWeekAbbr(DateTime selectedMonth){

    List<Widget> children = List();

    var formatter = DateFormat(DateFormat.ABBR_WEEKDAY);

    for(int x = 1; x <= 7; x++){
      DateTime childDate = DateTime(selectedMonth.year, selectedMonth.month, x);
      children.add(Expanded(child: Text(formatter.format(childDate))));
    }

    return children;
  }

  List<Widget> getMonthGridViewChildren(User user, DateTime selectedMonth, bool isCurrent, Schedule schedule) {
    List<Widget> children = List();
    
    for (int x = 1; x <= calendarHelper.getDaysInCurrentMonth(selectedMonth.year, selectedMonth.month); x++) {
      DateTime childDate = DateTime(selectedMonth.year, selectedMonth.month, x);

      List<Event> childDateEvents = schedule.getEventsForDay(childDate);

      children.add(Material(
        color: x == selectedMonth.day && isCurrent ? Theme.of(context).accentColor : Colors.white,
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
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(x.toString(), style: Theme.of(context).textTheme.bodyText1,)
                  ],
                ),
              ),
              childDateEvents.length == 0
                  ? Container()
                  : Flexible(
                      child: Center(
                        child: Text(
                        childDateEvents.length.toString() + " Event(s)", style: Theme.of(context).textTheme.bodyText1,
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

  Event event = Event.fromNothing();

  @override
  Widget build(BuildContext context) {

    GlobalKey<FormState> formKey = GlobalKey();

    var formatter = DateFormat(DateFormat.YEAR_MONTH_DAY);
    var timeFormatter = DateFormat(DateFormat.HOUR_MINUTE);

    List<Event> eventList = widget.schedule.getEventsForDay(widget.selectedDate);

    TimeOfDay selectedTime;

    TextEditingController timeController = TextEditingController();

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
                      TextFormField(
                        validator: (value) => Validator.validateShortLength(value),
                        onSaved: (value) => event.name = value,
                        decoration: InputDecoration(labelText: "Title"),
                      ),
                      TextFormField(
                        validator: (value) => Validator.validateShortLength(value),
                        controller: timeController,
                        readOnly: true,
                        onTap: () async {
                          event.startDate = widget.selectedDate;
                          selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now()
                          );
                          if(selectedTime != null){
                            event.startDate = event.startDate.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute));
                            timeController.text = (timeFormatter.format(event.startDate));
                          }
                        },
                        decoration: InputDecoration(labelText: "Start time"),
                      ),
                      TextFormField(
                        onSaved: (value) => event.endDate = event.startDate.add(DurationHelper.parseHumanDuration(value)),
                        decoration: InputDecoration(labelText: "Duration (e.g. 15m or 2 hours)"),
                      ),
                    ],
                  )
                : eventList.length == 0
                    ? Center(child: Text("No events for today"),)
                    : Container(constraints: BoxConstraints.tight(MediaQuery.of(context).size * .25),
                        child: EventList(eventList)
            ),
          ],
        ),
      ),
      actions: [
        addEventMode
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      shape: StadiumBorder(),
                      onPressed: () async {
                        if(formKey.currentState.validate()){
                          formKey.currentState.save();
                          await ScheduleFirestore.addScheduleItem(
                            event, widget.user.firebaseId);
                          Navigator.of(context).pop();
                          setState(() {
                            addEventMode = false;
                          });
                        }
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
                child: MaterialButton(
                  shape: StadiumBorder(),
                  onPressed: () async {
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
