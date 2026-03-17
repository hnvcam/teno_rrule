import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';
import 'testUtils.dart';

void main() {
  initializeTimeZones();

  final testData = [
    (
      rruleString: 'DTSTART:20241226T113900\n'
          'RRULE:FREQ=MONTHLY;UNTIL=20250224T105000Z;BYDAY=1TH',
      expected: [
        DateTime(2025, 1, 2, 11, 39, 0, 0, 0),
        DateTime(2025, 2, 6, 11, 39, 0, 0, 0),
      ]
    ),
    (
      rruleString: 'DTSTART:20241226T113900\n'
          'RRULE:FREQ=MONTHLY;UNTIL=20250124T105000Z;BYDAY=TH',
      expected: [
        for (int week = 0; week < 5; week++)
          DateTime(2024, 12, 26, 11, 39, 0, 0, 0).addUnit(weeks: week)
      ]
    ),
    (
      rruleString: 'DTSTART:20241226T113900\n'
          'RRULE:FREQ=WEEKLY;UNTIL=20250624T105000Z;BYDAY=TH',
      expected: [
        for (int week = 0; week < 26; week++)
          DateTime(2024, 12, 26, 11, 39, 0, 0, 0).addUnit(weeks: week)
      ]
    ),
    (
      rruleString: 'DTSTART:20240226T080000\n'
          'EXDATE:20240227T000000\n'
          'RRULE:FREQ=WEEKLY;UNTIL=20240824T000000Z;BYDAY=MO,TU,WE',
      expected: [
        for (int week = 0; week < 26; week++)
          for (int day = 0; day < 3; day++)
            DateTime(2024, 02, 26, 8, 0, 0, 0, 0)
                .addUnit(weeks: week, days: day)
      ]..removeAt(1)
    )
  ];

  for (var data in testData) {
    test("RRule: ${data.rruleString} has correct instances", () {
      final rrule = RecurrenceRule.from(data.rruleString);
      expect(rrule!.allInstances, data.expected);
    });
  }

  test('https://github.com/hnvcam/teno_rrule/issues/1', () {
    RecurrenceRule tester = RecurrenceRule.from('RRULE:FREQ=WEEKLY;BYDAY=FR')!
        .copyWith(startDate: DateTime.utc(2024, 3, 20));

    print(tester.startDate);

    final instances = tester.allInstances;
    for (int i = 0; i < 10; i++) {
      expect(instances[i], DateTime.utc(2024, 03, 22).addUnit(weeks: i));
    }
  });

  // https://github.com/hnvcam/teno_rrule/issues/4
  // DST transition causes time to shift because addUnit uses Duration (absolute hours)
  // instead of calendar-based day arithmetic.
  test('DAILY preserves time across fall-back DST (issue #4)', () {
    final rrule =
        RecurrenceRule.from('DTSTART;TZID=America/New_York:20251101T100000\n'
            'RRULE:FREQ=DAILY;COUNT=4')!;
    expect(rrule.allInstances, [
      newYorkDateTime(2025, 11, 1, 10), // EDT
      newYorkDateTime(
          2025, 11, 2, 10), // EST - DST ends Nov 2, time must stay 10:00
      newYorkDateTime(2025, 11, 3, 10), // EST
      newYorkDateTime(2025, 11, 4, 10), // EST
    ]);
  });

  test('WEEKLY BYDAY preserves time across fall-back DST (issue #4)', () {
    final rrule =
        RecurrenceRule.from('DTSTART;TZID=America/New_York:20251027T100000\n'
            'RRULE:FREQ=WEEKLY;BYDAY=MO,FR;COUNT=4')!;
    expect(rrule.allInstances, [
      newYorkDateTime(2025, 10, 27, 10), // Mon EDT
      newYorkDateTime(2025, 10, 31, 10), // Fri EDT
      newYorkDateTime(2025, 11, 3, 10), // Mon EST - must stay 10:00
      newYorkDateTime(2025, 11, 7, 10), // Fri EST - must stay 10:00
    ]);
  });

  // Exact rrule from issue #4: reporter saw Nov 16 instead of Nov 23
  test('MONTHLY BYDAY=4SU;WKST=SU across DST boundary (issue #4)', () {
    final rrule =
        RecurrenceRule.from('DTSTART;TZID=America/New_York:20250928T100000\n'
            'RRULE:FREQ=MONTHLY;BYDAY=4SU;WKST=SU;COUNT=4')!;
    expect(rrule.allInstances, [
      newYorkDateTime(2025, 9, 28, 10), // Sep 28 (4th Sunday, EDT)
      newYorkDateTime(2025, 10, 26, 10), // Oct 26 (4th Sunday, EDT)
      newYorkDateTime(
          2025, 11, 23, 10), // Nov 23 (4th Sunday, EST) - was Nov 16
      newYorkDateTime(2025, 12, 28, 10), // Dec 28 (4th Sunday, EST)
    ]);
  });

  test('DAILY preserves time across spring-forward DST (issue #4)', () {
    final rrule =
        RecurrenceRule.from('DTSTART;TZID=America/New_York:20250308T100000\n'
            'RRULE:FREQ=DAILY;COUNT=4')!;
    expect(rrule.allInstances, [
      newYorkDateTime(2025, 3, 8, 10), // EST
      newYorkDateTime(
          2025, 3, 9, 10), // EDT - DST starts Mar 9, time must stay 10:00
      newYorkDateTime(2025, 3, 10, 10), // EDT
      newYorkDateTime(2025, 3, 11, 10), // EDT
    ]);
  });

  test('https://github.com/hnvcam/teno_rrule/issues/2', () {
    RecurrenceRule tester =
        RecurrenceRule.from('FREQ=WEEKLY;BYDAY=FR,SA;INTERVAL=1;COUNT=10')!
            .copyWith(startDate: DateTime.parse('2024-12-20 16:00:00.000'));

    final instances = tester.allInstances;
    final expectedInstances = [
      '2024-12-20 16:00:00.000',
      '2024-12-21 16:00:00.000',
      '2024-12-27 16:00:00.000',
      '2024-12-28 16:00:00.000',
      '2025-01-03 16:00:00.000',
      '2025-01-04 16:00:00.000',
      '2025-01-10 16:00:00.000',
      '2025-01-11 16:00:00.000',
      '2025-01-17 16:00:00.000',
      '2025-01-18 16:00:00.000'
    ];
    for (int i = 0; i < expectedInstances.length; i++) {
      expect(instances[i], DateTime.parse(expectedInstances[i]));
    }
  });
}
