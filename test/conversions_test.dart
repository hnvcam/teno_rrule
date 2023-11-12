import 'package:teno_rrule/src/conversions.dart';
import 'package:teno_rrule/src/models/Frequency.dart';
import 'package:teno_rrule/src/models/RecurrenceRule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

main() {
  initializeTimeZones();

  group("Serialize to RFC2445 String correctly", () {
    final testData = [
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            startDate: DateTime(1997, 9, 2, 9, 0, 0)),
        expected: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            startDate: DateTime.utc(1997, 9, 2, 9, 0, 0),
            isLocal: false),
        expected: 'DTSTART:19970902T090000Z\nRRULE:FREQ=WEEKLY'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            startDate: TZDateTime(
                getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
            isLocal: false),
        expected:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY'
      ),
      (
        rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
        ),
        expected: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            startDate: DateTime(1997, 9, 2, 9, 0, 0),
            byWeekDays: {DateTime.monday, DateTime.wednesday, DateTime.friday}),
        expected: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            startDate: DateTime(1997, 9, 2, 9, 0, 0),
            endDate: DateTime.utc(2000, 1, 1, 0, 0, 0)),
        expected:
            'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=20000101T000000Z'
      ),
      // Examples from RFC2445
      (
        rrule: RecurrenceRule(
            frequency: Frequency.daily,
            isLocal: false,
            startDate: TZDateTime(
                getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
            count: 10),
        expected:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=10'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.daily,
            isLocal: false,
            startDate: TZDateTime(
                getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
            interval: 10,
            count: 5),
        expected:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=5;INTERVAL=10'
      ),
      (
        rrule: RecurrenceRule(
            frequency: Frequency.weekly,
            isLocal: false,
            startDate: TZDateTime(
                getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
            interval: 2,
            weekStart: DateTime.sunday),
        expected:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU'
      ),
      (
        rrule: RecurrenceRule(
          frequency: Frequency.yearly,
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1998, 1, 1, 9, 0, 0),
          endDate: DateTime.utc(2000, 1, 31, 9, 0, 0),
          byMonths: {DateTime.january},
          byWeekDays: {
            DateTime.sunday,
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday
          },
        ),
        expected: 'DTSTART;TZID=America/New_York:19980101T090000\n'
            'RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYMONTH=1'
      ),
    ];

    for (var data in testData) {
      test('RecurrenceRule is serialized to ${data.expected}', () {
        expect(data.rrule.rfc2445String, data.expected);
      });
    }
  });

  group("Parse from RFC2445 string correctly", () {
    final testData = [
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=10',
        expected: RecurrenceRule(
            frequency: Frequency.daily,
            count: 10,
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
        expected: RecurrenceRule(
            frequency: Frequency.daily,
            endDate: DateTime.utc(1997, 12, 24),
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;INTERVAL=2',
        expected: RecurrenceRule(
            frequency: Frequency.daily,
            interval: 2,
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
        expected: RecurrenceRule(
            frequency: Frequency.daily,
            interval: 10,
            count: 5,
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19980101T090000\n'
            'RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;'
            'BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
        expected: RecurrenceRule(
            frequency: Frequency.yearly,
            endDate: DateTime.utc(2000, 1, 31, 9),
            isLocal: false,
            byMonths: {DateTime.january},
            byWeekDays: {
              DateTime.sunday,
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday,
              DateTime.friday,
              DateTime.saturday
            },
            startDate:
                TZDateTime(getLocation('America/New_York'), 1998, 1, 1, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;COUNT=10',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            count: 10,
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            endDate: DateTime.utc(1997, 12, 24),
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            interval: 2,
            weekStart: DateTime.sunday,
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            endDate: DateTime.utc(1997, 10, 7),
            weekStart: DateTime.sunday,
            byWeekDays: {DateTime.tuesday, DateTime.thursday},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value:
            'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            count: 10,
            weekStart: DateTime.sunday,
            byWeekDays: {DateTime.tuesday, DateTime.thursday},
            isLocal: true,
            startDate: DateTime(1997, 9, 2, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19970902T090000\n'
            'RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;'
            'BYDAY=MO,WE,FR',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            endDate: DateTime.utc(1997, 12, 24),
            interval: 2,
            weekStart: DateTime.sunday,
            byWeekDays: {DateTime.monday, DateTime.wednesday, DateTime.friday},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19970902T090000\n'
            'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH',
        expected: RecurrenceRule(
            frequency: Frequency.weekly,
            interval: 2,
            count: 8,
            weekStart: DateTime.sunday,
            byWeekDays: {DateTime.tuesday, DateTime.thursday},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19970902T090000\n'
            'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
        expected: RecurrenceRule(
            frequency: Frequency.monthly,
            count: 10,
            byMonthDays: {2, 15},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19970910T090000\n'
            'RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15',
        expected: RecurrenceRule(
            frequency: Frequency.monthly,
            interval: 18,
            count: 10,
            byMonthDays: {10, 11, 12, 13, 14, 15},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 9, 10, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970610T090000\nRRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
        expected: RecurrenceRule(
            frequency: Frequency.yearly,
            count: 10,
            byMonths: {6, 7},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 6, 10, 9))
      ),
      (
        value:
            'DTSTART;TZID=America/New_York:19970512T090000\nRRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO',
        expected: RecurrenceRule(
            frequency: Frequency.yearly,
            byWeeks: {20},
            byWeekDays: {DateTime.monday},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1997, 5, 12, 9))
      ),
      (
        value: 'DTSTART;TZID=America/New_York:19961105T090000\n'
            'RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8',
        expected: RecurrenceRule(
            frequency: Frequency.yearly,
            interval: 4,
            byMonths: {11},
            byWeekDays: {DateTime.tuesday},
            byMonthDays: {2, 3, 4, 5, 6, 7, 8},
            isLocal: false,
            startDate:
                TZDateTime(getLocation('America/New_York'), 1996, 11, 05, 9))
      ),
    ];

    for (var data in testData) {
      test('${data.value} is parsed correctly', () {
        expect(parseRFC2445String(data.value), data.expected);
      });
    }
  });
}
