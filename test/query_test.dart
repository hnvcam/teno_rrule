import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/src/utils.dart';
import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

main() {
  initializeTimeZones();

  final testData = [
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;COUNT=10',
      expected: [
        for (int i = 0; i < 10; i++)
          TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9)
              .addUnit(days: i)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
      expected: [
        for (DateTime date =
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9);
            date.isBeforeUnit(DateTime.utc(1997, 12, 24), unit: Unit.day);
            date = date.addUnit(days: 1))
          toTZDateTime(getLocation('America/New_York'), date)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;INTERVAL=2',
      expected: [
        for (DateTime date =
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9);
            date.isBeforeUnit(maxAllowedDate, unit: Unit.day);
            date = date.addUnit(days: 2))
          toTZDateTime(getLocation('America/New_York'), date)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
      expected: [
        TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9),
        TZDateTime(getLocation('America/New_York'), 1997, 9, 12, 9),
        TZDateTime(getLocation('America/New_York'), 1997, 9, 22, 9),
        TZDateTime(getLocation('America/New_York'), 1997, 10, 2, 9),
        TZDateTime(getLocation('America/New_York'), 1997, 10, 12, 9),
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19980101T090000\n'
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;'
          'BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
      expected: [
        for (int i = 0; i < 3; i++)
          for (int j = 1; j <= 31; j++)
            TZDateTime(getLocation('America/New_York'), 1998 + i, 1, j, 9)
      ]
    ),
  ];

  for (var data in testData) {
    test("RRule: ${data.rruleString} has correct instances", () {
      final rrule = RecurrenceRule.from(data.rruleString);
      expect(rrule!.allInstances, data.expected);
    });
  }
}
