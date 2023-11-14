import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/standalone.dart';

import 'testUtils.dart';

main() {
  initializeTimeZones();

  final testData = [
    (
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate: DateTime(1997, 9, 2, 9, 0, 0)),
      rfc5545String: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY'
    ),
    (
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate: DateTime.utc(1997, 9, 2, 9, 0, 0),
          isLocal: false),
      rfc5545String: 'DTSTART:19970902T090000Z\nRRULE:FREQ=WEEKLY'
    ),
    (
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9, 0, 0),
          isLocal: false),
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY'
    ),
    (
      rrule: RecurrenceRule(
        frequency: Frequency.weekly,
        startDate: DateTime(1997, 9, 2, 9, 0, 0),
      ),
      rfc5545String: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY'
    ),
    (
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate: DateTime(1997, 9, 2, 9, 0, 0),
          byWeekDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday}),
      rfc5545String: 'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR'
    ),
    (
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          startDate: DateTime(1997, 9, 2, 9, 0, 0),
          endDate: DateTime.utc(2000, 1, 1, 0, 0, 0)),
      rfc5545String:
          'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=20000101T000000Z'
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;COUNT=10',
      rrule: RecurrenceRule(
          frequency: Frequency.daily,
          count: 10,
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;UNTIL=19971224T000000Z',
      rrule: RecurrenceRule(
          frequency: Frequency.daily,
          endDate: DateTime.utc(1997, 12, 24),
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;INTERVAL=2',
      rrule: RecurrenceRule(
          frequency: Frequency.daily,
          interval: 2,
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=DAILY;INTERVAL=10;COUNT=5',
      rrule: RecurrenceRule(
          frequency: Frequency.daily,
          interval: 10,
          count: 5,
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19980101T090000\n'
          'RRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;'
          'BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
      rrule: RecurrenceRule(
          frequency: Frequency.yearly,
          endDate: DateTime.utc(2000, 1, 31, 9),
          isLocal: false,
          byMonths: {DateTime.january},
          byWeekDays: {
            WeekDay.sunday,
            WeekDay.monday,
            WeekDay.tuesday,
            WeekDay.wednesday,
            WeekDay.thursday,
            WeekDay.friday,
            WeekDay.saturday
          },
          startDate: TZDateTime(getLocation('America/New_York'), 1998, 1, 1, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;COUNT=10',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          count: 10,
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=19971224T000000Z',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          endDate: DateTime.utc(1997, 12, 24),
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;INTERVAL=2;WKST=SU',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          interval: 2,
          weekStart: DateTime.sunday,
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970902T090000\nRRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          endDate: DateTime.utc(1997, 10, 7),
          weekStart: DateTime.sunday,
          byWeekDays: {WeekDay.tuesday, WeekDay.thursday},
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String:
          'DTSTART:19970902T090000\nRRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          count: 10,
          weekStart: DateTime.sunday,
          byWeekDays: {WeekDay.tuesday, WeekDay.thursday},
          isLocal: true,
          startDate: DateTime(1997, 9, 2, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;'
          'BYDAY=MO,WE,FR',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          endDate: DateTime.utc(1997, 12, 24),
          interval: 2,
          weekStart: DateTime.sunday,
          byWeekDays: {WeekDay.monday, WeekDay.wednesday, WeekDay.friday},
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH',
      rrule: RecurrenceRule(
          frequency: Frequency.weekly,
          interval: 2,
          count: 8,
          weekStart: DateTime.sunday,
          byWeekDays: {WeekDay.tuesday, WeekDay.thursday},
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          count: 10,
          byMonthDays: {2, 15},
          isLocal: false,
          startDate: TZDateTime(getLocation('America/New_York'), 1997, 9, 2, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970910T090000\n'
          'RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          interval: 18,
          count: 10,
          byMonthDays: {10, 11, 12, 13, 14, 15},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 9, 10, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970610T090000\nRRULE:FREQ=YEARLY;COUNT=10;BYMONTH=6,7',
      rrule: RecurrenceRule(
          frequency: Frequency.yearly,
          count: 10,
          byMonths: {6, 7},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 6, 10, 9))
    ),
    (
      rfc5545String:
          'DTSTART;TZID=America/New_York:19970512T090000\nRRULE:FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO',
      rrule: RecurrenceRule(
          frequency: Frequency.yearly,
          byWeeks: {20},
          byWeekDays: {WeekDay.monday},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 5, 12, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19961105T090000\n'
          'RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8',
      rrule: RecurrenceRule(
          frequency: Frequency.yearly,
          interval: 4,
          byMonths: {11},
          byWeekDays: {WeekDay.tuesday},
          byMonthDays: {2, 3, 4, 5, 6, 7, 8},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1996, 11, 05, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970905T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYDAY=1FR',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          count: 10,
          byWeekDays: {WeekDay.friday.withOccurrence(1)},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 05, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970907T090000\n'
          'RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          interval: 2,
          count: 10,
          byWeekDays: {
            WeekDay.sunday.withOccurrence(1),
            WeekDay.sunday.withOccurrence(-1)
          },
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 07, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970928T090000\n'
          'RRULE:FREQ=MONTHLY;BYMONTHDAY=-3',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          byMonthDays: {-3},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 28, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970930T090000\n'
          'RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          count: 10,
          byMonthDays: {1, -1},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 30, 9))
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'EXDATE;TZID=America/New_York:19970902T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          byMonthDays: {13},
          byWeekDays: {WeekDay.friday},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 02, 9),
          excludedDates: {
            TZDateTime(getLocation('America/New_York'), 1997, 09, 02, 9)
          })
    ),
    (
      rfc5545String: 'DTSTART;TZID=America/New_York:19970902T090000\n'
          'EXDATE;TZID=America/New_York:19970902T090000,19980213T090000\n'
          'RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13',
      rrule: RecurrenceRule(
          frequency: Frequency.monthly,
          byMonthDays: {13},
          byWeekDays: {WeekDay.friday},
          isLocal: false,
          startDate:
              TZDateTime(getLocation('America/New_York'), 1997, 09, 02, 9),
          excludedDates: {
            TZDateTime(getLocation('America/New_York'), 1997, 09, 02, 9),
            TZDateTime(getLocation('America/New_York'), 1998, 02, 13, 9),
          })
    ),
  ];

  group("Serialize to RFC5545 string collection", () {
    for (var data in testData) {
      test('RRule is serialized to ${data.rfc5545String} correctly', () {
        expect(data.rrule.rfc5545String,
            isSameRFC5545StringAs(data.rfc5545String));
      });
    }
  });

  group("Parse from RFC5545 string correctly", () {
    for (var data in testData) {
      test('${data.rfc5545String} is parsed correctly', () {
        expect(parseRFC5545String(data.rfc5545String), data.rrule);
      });
    }
  });
}
