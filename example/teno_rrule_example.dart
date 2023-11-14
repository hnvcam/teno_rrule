import 'package:teno_rrule/teno_rrule.dart';
import 'package:timezone/data/latest_10y.dart';

void main() {
  initializeTimeZones();

  // Create rrule instance programmatically
  final rrule = RecurrenceRule(
      frequency: Frequency.weekly,
      startDate: DateTime(1997, 9, 2, 9),
      byWeekDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday});
  for (var instance
      in rrule.between(DateTime(1997, 9, 2, 9), DateTime(1997, 10, 2, 9))) {
    print(instance);
  }

  // Parse from string
  final rruleString = 'DTSTART;TZID=America/New_York:19970902T090000\n'
      'RRULE:FREQ=DAILY;INTERVAL=2';
  final rruleFromString = RecurrenceRule.from(rruleString);

  // Get all instances
  // if there is no UNTIL nor COUNT, then this will return all instances before 2100-12-31
  print(rruleFromString!.allInstances);
}
