import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/schedule.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/calendar_helper.dart';
import 'package:techpointchallenge/model/event.dart';
import 'package:techpointchallenge/services/duration_helper.dart';
import 'package:techpointchallenge/services/firestore/schedule_firestore.dart';
import 'package:techpointchallenge/services/validator.dart';
import 'package:techpointchallenge/services/globals.dart' as globals;


class CalendarPage extends StatefulWidget {

  final bool aliasMode;

  const CalendarPage({Key key, @required this.aliasMode}) : super(key: key);

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
              padding: EdgeInsets.all(globals.useMobileLayout ? 5: 20),
              child: CalendarView(aliasMode: widget.aliasMode),
            )
          ],
        ),
      ),
    );
  }
}

class CalendarView extends StatefulWidget {

  final bool aliasMode;

  const CalendarView({Key key, @required this.aliasMode}) : super(key: key);

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
                padding: EdgeInsets.only(bottom: widget.aliasMode ? 8 : 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: Colors.white,
                      shape: StadiumBorder(),
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
                    Flexible(
                      child: AutoSizeText(
                        viewDate == now
                            ? formatter.format(now)
                            : formatter.format(viewDate),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      shape: StadiumBorder(),
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
                children: getMonthGridViewChildren(user, viewDate, true, user.schedule),
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

    children.add(Expanded(child: Text("Mon"),));
    children.add(Expanded(child: Text("Tue"),));
    children.add(Expanded(child: Text("Wed"),));
    children.add(Expanded(child: Text("Thu"),));
    children.add(Expanded(child: Text("Fri"),));
    children.add(Expanded(child: Text("Sat"),));
    children.add(Expanded(child: Text("Sun"),));

    return children;
  }

  List<Widget> getMonthGridViewChildren(User user, DateTime selectedMonth, bool isCurrent, Schedule schedule) {

    DateTime now = DateTime.now();

    List<Widget> children = List();
    
    for (DateTime childDate in calendarHelper.getDaysInCurrentView(selectedMonth.year, selectedMonth.month)) {

      List<Event> childDateEvents = schedule.getEventsForDay(childDate);

      Color color;

      if (childDate.month != selectedMonth.month){
        color = Colors.grey[200];
      } else {
        color = Colors.white;
      }

      children.add(Container(
        decoration: BoxDecoration(
          border: Border.all(color: childDate.isBefore(now) && now.isBefore(childDate.add(Duration(days: 1))) ? Theme.of(context).accentColor : color, width: 2)
        ),
        child: Material(
          color: color,
          child: InkWell(
            onTap: () => showDialog<void>(
                context: context,
                builder: (context) {
                  return DayDialog(schedule, childDate, user, widget.aliasMode);
                }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(childDate.day.toString(), style: Theme.of(context).textTheme.bodyText1,)
                    ],
                  ),
                ),
                childDateEvents.length == 0
                    ? Container()
                    : Flexible(
                        child: Center(
                          child: AutoSizeText(
                          childDateEvents.length.toString() + " Events", style: Theme.of(context).textTheme.bodyText1,
                          maxLines: 1,
                            minFontSize: 10,
                        )),
                      )
              ],
            ),
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
  final bool aliasMode;

  DayDialog(this.schedule, this.selectedDate, this.user, this.aliasMode);

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

    var size = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(formatter.format(widget.selectedDate), style: Theme.of(context).textTheme.bodyText1,),
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
                        validator: (value) => Validator.validateDuration(value),
                        onSaved: (value) => event.endDate = event.startDate.add(DurationHelper.parseHumanDuration(value)),
                        decoration: InputDecoration(labelText: "Duration (e.g. 15m or 2h)"),
                      ),
                    ],
                  )
                : eventList.length == 0
                    ? Center(child: Text("No events for today", style: Theme.of(context).textTheme.bodyText1,))
                    : Container(constraints: BoxConstraints.tight(globals.useMobileLayout ? Size(size.width * .9, size.height * .5) : Size(size.width * .25, size.height * .3)),
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
                      onPressed: () async => await submitForm(formKey),
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
                child: widget.aliasMode ? Container() : MaterialButton(
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

  Future<void> submitForm(GlobalKey<FormState> formKey) async {
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      await ScheduleFirestore.addScheduleItem(
        event, widget.user.firebaseId);
      Navigator.of(context).pop();
      setState(() {
        addEventMode = false;
      });
    }
  }
}

class EventList extends StatelessWidget {
  final List<Event> events;
  final bool shrinkWrap;

  EventList(this.events, {this.shrinkWrap});

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      child: ListView.builder(
        controller: scrollController,
        primary: false,
        shrinkWrap: shrinkWrap ?? true,
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];
          int minuteLength = event.endDate.difference(event.startDate).inMinutes;
          double logLength = log(minuteLength)/log(10);
          return ColumnSuper(
            innerDistance: -30,
            children: [
              ListTile(
                leading: Text(DateFormat('jm').format(event.startDate)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 10, right: 15),
                child: ListTile(
                  leading: Container(width: 5, height: 20 * logLength, color: Theme.of(context).accentColor,),
                  title: Text(event.name),
                  trailing: Text(minuteLength.toString() + " Minutes"),
                ),
              ),
              ListTile(
                leading: Text(DateFormat('jm').format(event.endDate)),
              ),
            ],
          );
        },
      ),
    );
  }
}
