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
        // ==> (1997 9:00 AM EDT) September 2-11
        for (int i = 0; i < 10; i++)
          TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9)
              .addUnit(days: i)
      ]
    ),
    (
      rruleString: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
      expected: [
        // ==> (1997 9:00 AM EDT) September 2-30;October 1-25
        //     (1997 9:00 AM EST) October 26-31;November 1-30;December 1-23
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
        // ==> (1997 9:00 AM EDT) September 2,4,6,8...24,26,28,30;
        //                        October 2,4,6...20,22,24
        //     (1997 9:00 AM EST) October 26,28,30;
        //                        November 1,3,5,7...25,27,29;
        //                        December 1,3,...
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
        // ==> (1997 9:00 AM EDT) September 2,12,22;
        //                        October 2,12
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
        // => (1998 9:00 AM EST)January 1-31
        //    (1999 9:00 AM EST)January 1-31
        //    (2000 9:00 AM EST)January 1-31
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

  test('Custom', () {
    final data = (
      rruleString: 'DTSTART;TZID=America/New_York:19980101T090000\n'
          'RRULE:FREQ=YEARLY;UNTIL=20000131T140000Z;'
          'BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
      expected: [
        // => (1998 9:00 AM EST)January 1-31
        //    (1999 9:00 AM EST)January 1-31
        //    (2000 9:00 AM EST)January 1-31
        for (int i = 0; i < 3; i++)
          for (int j = 1; j <= 31; j++)
            TZDateTime(getLocation('America/New_York'), 1998 + i, 1, j, 9)
      ]
    );

    final rrule = RecurrenceRule.from(data.rruleString);
    expect(rrule!.allInstances, data.expected);
  });
}
