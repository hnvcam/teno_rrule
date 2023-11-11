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
            startDate: DateTime(1997, 9, 2, 9, 0, 0).copyWith(isUtc: true),
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
            endDate: DateTime(2000, 1, 1, 0, 0, 0).copyWith(isUtc: true)),
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
          endDate: DateTime(2000, 1, 31, 9, 0, 0).copyWith(isUtc: true),
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
}
