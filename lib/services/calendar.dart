class CalendarHelper {

  int getDaysInCurrentMonth(int year, int month){

    DateTime firstOfNextMonth;
    if(month == 12) {
      firstOfNextMonth = DateTime(year+1, 1, 1, 12);//year, month, day, hour
    }
    else {
      firstOfNextMonth = DateTime(year, month+1, 1, 12);
    }

    int numberOfDaysInMonth = firstOfNextMonth.subtract(Duration(days: 1)).day;

    return numberOfDaysInMonth;
  }

}