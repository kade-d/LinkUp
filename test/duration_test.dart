import 'package:duration/duration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:techpointchallenge/services/duration_helper.dart';

void main() {

  test('Human Duration Parse Test, 15 minutes', () {

    Duration actualDuration = Duration(minutes: 15);

    expect(actualDuration, DurationHelper.parseHumanDuration("15 minutes"));

    expect(actualDuration, DurationHelper.parseHumanDuration("15 min"));

    expect(actualDuration, DurationHelper.parseHumanDuration("15 m"));

  });

  test('Human Duration Parse Test, 2 hours', () {

    Duration actualDuration = Duration(hours: 2);

    expect(actualDuration, DurationHelper.parseHumanDuration("2 h"));

    expect(actualDuration, DurationHelper.parseHumanDuration("2 hours"));

    expect(actualDuration, DurationHelper.parseHumanDuration("2 hour      "));

  });


}
