class DurationHelper {

  static Duration parseHumanDuration(String input){

    int days;
    int hours;
    int minutes;

    final match = RegExp(r'^(\d+)[ ]*(d|h|m)[a-z| ]*$').matchAsPrefix(input);
    if (match == null) throw FormatException('Invalid duration format');

    int value = int.parse(match.group(1));
    String unit = match.group(2)[0];

    switch (unit) {
      case 'd':
        if (days != null) {
          throw FormatException('Days specified multiple times');
        }
        days = value;
        break;
      case 'h':
        if (hours != null) {
          throw FormatException('Hours specified multiple times');
        }
        hours = value;
        break;
      case 'm':
        if (minutes != null) {
          throw FormatException('Minutes specified multiple times');
        }
        minutes = value;
        break;
      default:
        throw FormatException('Invalid duration unit $unit');
    }

    return Duration(
      days: days ?? 0,
      hours: hours ?? 0,
      minutes: minutes ?? 0);
  }

}