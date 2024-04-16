import 'package:teno_datetime/teno_datetime.dart';
import 'package:teno_rrule/teno_rrule.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_10y.dart';

void main() {
  initializeTimeZones();

  final testData = [
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
}
