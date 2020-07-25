import 'package:duration/duration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:techpointchallenge/services/calendar_helper.dart';
import 'package:techpointchallenge/services/duration_helper.dart';

void main() {

  test('Calendar Test', () {
    CalendarHelper calendarHelper = CalendarHelper();

    expect(calendarHelper.getDaysInCurrentMonth(2020, DateTime.january), 31, reason: "31 days in january");

    expect(calendarHelper.getDaysInCurrentMonth(2020, DateTime.december), 31, reason: "31 days in december");

    expect(calendarHelper.getDaysInCurrentMonth(2020, DateTime.february), 29, reason: "29 days in february (leap year)");

    expect(calendarHelper.getDaysInCurrentMonth(2021, DateTime.february), 28, reason: "28 days in february - no leap");

  });

  test('Get days in view test', () {
    CalendarHelper calendarHelper = CalendarHelper();

    print(DateTime(2019, 11, 3).add(Duration(days: 1)));

  });

}
