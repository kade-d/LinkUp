

class CalendarHelper {

  List<DateTime> getDaysInCurrentView(int year, int month){

    List<DateTime> dates = List();
    DateTime startIndex = DateTime(year, month);

    while(startIndex.weekday != 1){
      startIndex = DateTime(startIndex.year, startIndex.month, startIndex.day - 1);
    }

    startIndex = DateTime(startIndex.year, startIndex.month, startIndex.day - 1);

    while(startIndex.isBefore(DateTime(year, month, getDaysInCurrentMonth(year, month)))){
      startIndex = DateTime(startIndex.year, startIndex.month, startIndex.day + 1);
      dates.add(startIndex);
    }

    while(startIndex.weekday < 7) {
      startIndex = DateTime(startIndex.year, startIndex.month, startIndex.day + 1);
      dates.add(startIndex);
    }

    return dates;
  }


  int getDaysInCurrentMonth(int year, int month){
    DateTime firstOfNextMonth;
    if(month == 12) {
      firstOfNextMonth = DateTime(year+1, 1, 1, 12);//year, month, day, hour
    }
    else {
      firstOfNextMonth = DateTime(year, month+1, 1, 12);
    }
    return firstOfNextMonth.subtract(Duration(days: 1)).day;
  }

}