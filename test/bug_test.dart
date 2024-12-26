import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';

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

  test('https://github.com/hnvcam/teno_rrule/issues/2', () {
    RecurrenceRule tester = RecurrenceRule.from('FREQ=WEEKLY;BYDAY=FR,SA;INTERVAL=1;COUNT=10')!
        .copyWith(startDate: DateTime.parse('2024-12-20 16:00:00.000'));

    final instances = tester.allInstances;
    final expectedInstances = ['2024-12-20 16:00:00.000', '2024-12-21 16:00:00.000', '2024-12-27 16:00:00.000', '2024-12-28 16:00:00.000',
    '2025-01-03 16:00:00.000', '2025-01-04 16:00:00.000', '2025-01-10 16:00:00.000', '2025-01-11 16:00:00.000',
    '2025-01-17 16:00:00.000', '2025-01-18 16:00:00.000'];
    for (int i = 0; i < expectedInstances.length; i++) {
      expect(instances[i], DateTime.parse(expectedInstances[i]));
    }
  });
}
